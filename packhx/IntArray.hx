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
    /**
      Constructs a new packed IntArray with the given cell size
     **/
    public function new(cellSize:Int){
        this = [cellSize];
    }
    /**
      This function returns the current "cell" size for the array.  This number
      is given in the constructor.
     **/
    public function cellSize() : Int {
        return this[0] & 31;
    }
    /**
      This function returns the final cell offset, which contains the position of
      the final value in the last array position.
     **/
    public function final_offset() : Int {
        return this[0].maskExtract(I32L, I32L);
    }

    @:arrayAccess public inline function arrayAccess(key : Int): Int {
        var size = cellSize();
        var start = (key * size) + 10;
        var index = Std.int(start * SEGMENT);
        var start_offset = start % 32;
        if (this[index] == null) return 0;
        var init_value = this[index].maskExtract( start_offset, size);
        if (start_offset + size > 32){
            var overlap = start_offset + size - 32;
            var addmask = this[index+1].maskExtract(0, start_offset + size  - 32) << size -overlap;
            return init_value | this[index+1].maskExtract( 0, start_offset + size  - 32) << size -overlap;
        } else {
            return init_value;
        }
    }

    @:arrayAccess public inline function arrayWrite(key : Int, value : Int): Int {
        var size = cellSize();
        var start = (key * size) + 10;
        var index = Std.int(start * SEGMENT);
        var start_offset = start % 32;
        if (this[index] == null) this[index] = 0;
        this[index] = this[index].maskSet(start_offset, size, value);
        if (start_offset + size > 32){
            if (this[index + 1] == null){
                this[index + 1] = 0;
                this[0] = this[0].maskSet( I32L, I32L, 0);
            }
            var overlap = start_offset + size - 32;
            this[index + 1] =this[index+1].maskSet( 0, overlap, value >>> size-overlap );
        } else if (index == this.length - 1) {
            if (final_offset() < start_offset){
                this[0] = this[0].maskSet( I32L, I32L, final_offset() + 1);
            }
        }
        return value;
    }

    @:to public function toArray() {
       return [for (i in 0...length()) arrayAccess(i)];
    }

    /**
      The concat method is a little different than the standard array concat.
      It will set the bit size of the returned IntArray based on the maximum
      of the two concatted bit size lengths.
     **/
    public function concat(a : IntArray): IntArray {
       var l = length();
       var al = a.length();
       var ret = new packhx.IntArray(l > al ? l : al);
       for (v in 0...length()) ret.push(arrayAccess(v));
       for (v in 0...a.length()) ret.push(a.arrayAccess(v));
       return ret;
    }

    public function push(val:Int){
       arrayWrite(length(),val);
    }

    public function pop():Int{
       var ret = arrayAccess(length()-1);
       if (final_offset() > 0){
          this[0] = this[0].maskSet( I32L, I32L, final_offset() - 1);
       } else {
          if (this.length > 1) this.pop();
          else return null;
          this[0] = this[0].maskSet( I32L, I32L, Std.int(I32L/cellSize())-1);
       }
       return ret;
    }

    public function reverse(){
       var left= 0;
       var right=length() -1;
       while(left < right) {
          var temporary = arrayAccess(left);
          arrayWrite(left, arrayAccess(right));
          arrayWrite(right, temporary);
          left++; right--;
       }
    }

    /**
      Calculates the length given the current cell size, and the final cell
      offset.
     **/
    public function length(){
        return Std.int((this.length-1) * (32 / cellSize())) + final_offset();
    }
    public function toString(){
       return '[${[for (i in 0...length()) arrayAccess(i)].join(', ')}]';
    }

    public function iterator(){
        var index = 0;
        return {
            hasNext : function(){
                return index + 1 != length();
            },
            next : function(){
               index += 1;
               return arrayAccess(index);
            }
        }
    }
    /**
      Return the raw underlying array.
     **/
    public inline function dump(){
        return this;
    }
}



