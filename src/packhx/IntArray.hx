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
        var start = (key * bitSize);
        var index = (start >> I32L) + 1;
        var start_offset = start % 32;

        if (this[index] == null) return 0;
        var value =
            if (start_offset + size > 32){
                var init_value = this[index].maskExtract(start_offset, size);
                var overlap = start_offset + size - 32;
                init_value | this[index+1].maskExtractSigned( 0, overlap) << size - overlap;
            } else {
                this[index].maskExtractSigned( start_offset, size);
            }
        return value & 1 == 1  ?  value >> 1 : null;
    }



    /**
      The array writer, which is the other critical method
     **/
    @:arrayAccess public inline function arrayWrite(key : Int, value : Int): Int {
        value = value == null ? 0 : (value << 1 ) | 1; 
        var size = bitSize;                           
        var start = (key * size);                       
        var index = (start >> I32L) + 1;                
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
                this[index + 1] = this[index+1].maskSet( 0, overlap, value >>> size-overlap );
            }
        } else if (start_offset >= finalOffset * size && index == this.length-1) {
            // last index in raw array
            finalOffset =  Std.int(start_offset / size) +1;
        }
        return value;
    }



    @:to public function toArray() {
       return [for (i in iterator()) i];
    }

    public function map(f : Int->Int): IntArray{
        var ret = new IntArray(bitSize);
        for (i in iterator()) ret.push(f(i));
        return ret;
    }

    // TODO: more tests
    public function indexOf(x:Int, ?fromIndex:Int):Int {
        if (fromIndex == null) fromIndex = 0;
        else while (fromIndex < 0) fromIndex += length;

        for (i in fromIndex...length){
            if (arrayAccess(i) == x) return i;
        }
        return -1;
    }

    // TODO: more tests
    public function slice(pos:Int, ?end:Int):IntArray{
        var ret = new IntArray(bitSize);
        for (i in pos...length){
            ret.push(arrayAccess(i));
        }
        return ret;
    }

    // TODO: more tests
    public function splice(pos : Int, len : Int): IntArray {
        var ret = new IntArray(bitSize);
        for (i in pos...length){
            if (i < len){
                ret.push(arrayAccess(i));
            } else {
                arrayWrite(i-len, arrayAccess(i));
            }
        }
        for (i in 0...len) pop();
        return ret;
    }

    // TODO: more tests
    public function insert(pos:Int, x:Int) : Void{
        var end = length-1;
        while(end >= pos){
            arrayWrite(end+1, arrayAccess(end));
            end--;
        }
        arrayWrite(pos, x);
    }

    // TODO: more tests
    public function lastIndexOf(x:Int, ?fromIndex:Int):Int{
        if (fromIndex == null) fromIndex = 0;
        else while (fromIndex < 0) fromIndex += length;
        var last =-1;
        for (i in fromIndex...length){
            if (arrayAccess(i) == x) last = i;
        }
        return last;
    }

    public function join(sep:String){
        var buf = new StringBuf();
        var first = true;
        for (i in iterator()){
            if (first){
                first = false;
            } else {
                buf.add(sep);
            }
            buf.add(i);
        }
        return buf.toString();
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
    public function remove(x:Int) : Bool {
        for (i in 0...length){
            if (arrayAccess(i) == x){
                for (j in i+1...length){
                    arrayWrite(j-1, arrayAccess(j));
                }
                pop();
                return true;
            }
        }
        return false;
    }

    public function shift(): Int {
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

    /**
      Sort the Array according to the comparison public function [f].
      [f(x,y)] should return [0] if [x == y], [>0] if [x > y]
      and [<0] if [x < y].
     **/
    public function sort( f : Int -> Int -> Int ) : Void {
        if (length < 2) return; // 1 or fewer items don't need to be sorted
        quicksort(0, length - 1, f);
    }

    /**
      quicksort author: tong disktree
      http://blog.disktree.net/2008/10/26/array-sort-performance.html
     */
    private function quicksort( lo : Int, hi : Int, f : Int -> Int -> Int ) : Void {
        var i = lo, j = hi;
        var p = arrayAccess((i + j) >> 1);
        while ( i <= j ) {
            while ( f(arrayAccess(i), p) < 0 && i < length-1) i++;
            while ( f(arrayAccess(j), p) > 0 && j > 1 ) j--;
            if ( i <= j ) {
                var t = arrayAccess(i);
                arrayWrite(i++, arrayAccess(j));
                arrayWrite(j--, t);
            }
        }

        if( lo < j ) quicksort( lo, j, f );
        if( i < hi ) quicksort( i, hi, f );
    }

    public function copy(){
        var ret = new IntArray(bitSize);
        ret.setThis(this.copy());
        return ret;
    }

    private inline function setThis(that:Array<Int>){
        this = that;
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

    // TODO: more test
    public function unshift(x:Int){
        var ret = x;
        for (i in 1...length){
           arrayWrite(i-1, arrayAccess(i));
        }
        pop();
        return ret;
    }

    /**
      Return a copy of the raw underlying array.
     **/
    public inline function dump(){
        return this.copy();
    }
}



