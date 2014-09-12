package packhx;
using packhx.PackedTools;

/**
  IntArray is a compressed array type that allows the efficient construction of
  an array containing Integer numbers smaller than the conventional 32 bit limit.
  For instance, if a developer only needed to use 8 bits to store the nubmers
  in a given case, IntArray could fit around 4 numbers per 32 bit array location.

  IntArray provides normal array access via overloaded @:arrayAccess methods,
  so, it can behave more or less like a normal array.  However, rather than
  having an instance length field, it has an instance length method.
 **/
abstract IntArray(Array<Int>) {
    static inline var SEGMENT = 0.03125; // 1/32
    static inline var I32L = 5; // It takes 5 bits to express the number 32

    public var length(get, never) : Int;
    public var bitSize(get, never) : Int;
    private var finalOffset(get, set) : Int;

    /**
      Constructs a new packed IntArray with the given cell size
     **/
    public function new(bitSize:Int){
        this = [bitSize];
    }

    /**
      This function returns the current bit size for elements in the array.  
      This number is given in the constructor.
     **/
    public function get_bitSize() : Int {
        return this[0] & 31;
    }

    /**
      This function returns the final cell offset, which contains the position of
      the final value in the last array position.
     **/
    private function get_finalOffset() : Int {
        return this[0].maskExtract(I32L, I32L);
    }

    private function set_finalOffset(val : Int) : Int {
        this[0] = this[0].maskSet( I32L, I32L, val);
        return val;
    }



    /**
      Calculates the length given the current cell size, and the final cell
      offset.
     **/
    public function get_length(){
        if (this.length <=2){
            // the second cell is the first "data" cell.  If that's the only cell,
            // then just return the offset of the final packed int.
            return finalOffset;
        } else {
            // else we need to calculate out how many packed ints per
            // array cell, and add the final offset to that.
            return Math.ceil(((this.length-2) * 32) / bitSize) + finalOffset;
        }
    }


    /**
      The array accessor, which has most of the critical logic.
     **/
    @:arrayAccess public inline function arrayAccess(key : Int): Int {
        var size = bitSize;
        var start = (key * size);
        var index = Std.int(start * SEGMENT) + 1;
        var start_offset = start % 32;
        if (this[index] == null) return 0;
        var init_value = 
        if (start_offset + size > 32){
            var init_value = this[index].maskExtract( start_offset, size);
            var overlap = start_offset + size - 32;
            init_value | this[index+1].maskExtractSigned( 0, start_offset + size  - 32) << size -overlap;
        } else {
            this[index].maskExtractSigned( start_offset, size);
        }
        return init_value & 1 == 1  ?  init_value >> 1 : null;
    }

    /**
      The array writer, which is the other critical method
     **/
    @:arrayAccess public inline function arrayWrite(key : Int, value : Int): Int {
        if (value == null){
            value = 0;
        } else {
            value <<= 1;
            value |= 1;
        }
        var size = bitSize;
        var start = (key * size);
        var index = Std.int(start * SEGMENT) + 1;
        var start_offset = start % 32;
        if (this[index] == null) this[index] = 0;
        this[index] = this[index].maskSet(start_offset, size, value);
        if (start_offset + size > 32){
            if (this[index + 1] == null){
                this[index + 1] = 0;
                finalOffset = 0;
            }
            var overlap = start_offset + size - 32;
            if (overlap > 0) {
                this[index + 1] =this[index+1].maskSet( 0, overlap, value >>> size-overlap );
            }
        } else if (start_offset >= finalOffset * bitSize && index == this.length-1) {
            // last index in raw array
            finalOffset =  Std.int(start_offset / bitSize) +1;
        } 
        return value;
    }

    @:to public function toArray() {
       return [for (i in iterator()) i];
    }

    public function filter(f : Int->Bool){
        var ret = new IntArray(bitSize);
        for (i in iterator()) if (f(i)) ret.push(i) ;
        return ret;
    }

    /**
      The concat method is a little different than the standard array concat.
      It will set the bit size of the returned IntArray based on the maximum
      of the two concatted bit size lengths.
     **/
    public function concat(a : IntArray): IntArray {
       var s = bitSize;
       var as = a.bitSize;
       var ret = new packhx.IntArray(s > as ? s : as);
       for (v in 0...length) ret.push(arrayAccess(v));
       for (v in 0...a.length) ret.push(a.arrayAccess(v));
       return ret;
    }

    public function push(val:Int){
       arrayWrite(length,val);
    }

    public function pop():Int{
       var ret = arrayAccess(length-1);
       if (finalOffset > 0){
           finalOffset-=1;
       } else {
          if (this.length > 1) this.pop();
          else return null;
          finalOffset = bitSize -1;
       }
       return ret;
    }

    public function shift():Int{
        var ret = arrayAccess(0);
        for (i in 0...length-1){
            arrayWrite(i, arrayAccess(i+1));
        }
        pop();
        return ret;
    }

    /**
      Reverses the packed array in place
     **/
    public function reverse(){
       var left= 0;
       var right=length-1;
       while(left < right) {
          var tmp = arrayAccess(left);
          arrayWrite(left, arrayAccess(right));
          arrayWrite(right, tmp);
          left++; right--;
       }
    }


    public function toString(){
       return '[${[for (i in iterator()) i].join(',')}]';
    }

    public static function fromArray(arr:Array<Int>, bitSize:Int) : IntArray{
        var ret = new IntArray(bitSize);
        for (a in arr) ret.push(a);
        return ret;
    }

    public function iterator(){
        var index = 0;
        return {
            hasNext : function(){
                return index != length;
            },
            next : function(){
               return arrayAccess(index++);
            }
        }
    }
    /**
      Return a copy of the raw underlying array.
     **/
    public inline function dump(){
        return this.copy();
    }
}



