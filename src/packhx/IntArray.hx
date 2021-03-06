package packhx;
using packhx.PackedTools;

/**
  IntArray is a compressed array type that allows the efficient construction of
  an array containing Integer numbers smaller than the conventional 32 bit limit.

  IntArray provides normal array access via overloaded @:arrayAccess methods,
  so, it can behave more or less like a normal array.
 **/
abstract IntArray(Array<Int>) {
    static inline var I32L = 5; // It takes 5 bits to express the number 32
    static inline var NULLABLE_BIT = 1 << I32L * 2;

    public var length(get, never) : Int;
    public var bitSize(get, never) : Int;
    private var finalOffset(get, set) : Int;
    public var nullable(get, never) : Bool;

    /**
      Constructs a new packed IntArray with the given cell size
     **/
    public function new(bitSize:Int, ?nullable = true){
        this = [bitSize];

#if (js || php || neko)
        if (nullable) this[0] |= NULLABLE_BIT;
#end
    }

    /**
      This function returns the current bit size for elements in the array.
      This number is given in the constructor.
     **/
    public function get_bitSize() : Int {
        return this[0] & 31;
    }
    private function get_nullable() : Bool {
        return this[0] & NULLABLE_BIT > 0;
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
    @:arrayAccess public function arrayAccess(key : Int): Int {
        var size = bitSize;
        var start = (key * bitSize);
        var index = (start >> I32L) + 1;
        var start_offset = start % 32;

#if (js || neko || php)
        if (this[index] == null) return 0;
#end
        var value =
            if (start_offset + size > 32){
                var init_value = this[index].maskExtract(start_offset, size);
                var overlap = start_offset + size - 32;
                init_value | this[index+1].maskExtractSigned( 0, overlap) << size - overlap;
            } else {
                this[index].maskExtractSigned( start_offset, size);
            }
#if (js || neko || php)
        return nullable ? {value & 1 == 1  ?  value >> 1 : null;} : value;
#else
        return value;
#end
    }



    /**
      The array writer, which is the other critical method
     **/
    @:arrayAccess public function arrayWrite(key : Int, value : Int): Int {
#if (js || neko || php)
        if (nullable){
            value = value == null ? 0 : (value << 1 ) | 1;
        } else {
            if (value == null) value = 0;
        }
#end

        var size = bitSize;
        var start = (key * size);
        var index = (start >> I32L) + 1;
        var start_offset = start % 32;

        if (index >= this.length) {
            this[index] = 0;
            finalOffset = 0;
        }

        this[index] = this[index].maskSet(start_offset, size, value);

        if (start_offset + size > 32){
            if (index + 1 >= this.length){
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
        var ret = new IntArray(bitSize, nullable);
        for (i in iterator()) ret.push(f(i));
        return ret;
    }

    public function indexOf(x:Int, ?fromIndex:Int):Int {
        if (fromIndex > length) return -1;
        else if (fromIndex == null) fromIndex = 0;
        else while (fromIndex < 0) fromIndex += length;

        for (i in fromIndex...length){
            if (arrayAccess(i) == x) return i;
        }
        return -1;
    }

    public function slice(pos:Int, ?end:Int):IntArray{
        var ret = new IntArray(bitSize, nullable);

        if (end == null) end = length;
        else if (end < 0) end += length;
        if (end < 0) end = 0;

        if (pos < 0) pos += length;
        if (pos < 0) pos = 0;

        for (i in pos...end){
            ret.push(arrayAccess(i));
        }
        return ret;
    }

    public function splice(pos : Int, len : Int): IntArray {
        var ret = new IntArray(bitSize, nullable);

        if (len < 0) return ret;

        if (pos < 0) pos += length;
        if (pos < 0) pos = 0;
        if (pos > length-1) return ret;

        if (pos + len > length) len = length - pos;

        for (i in pos...length){
            if (i < pos + len ){
                ret.push(arrayAccess(i));
            } else {
                arrayWrite(i-len, arrayAccess(i));
            }
        }

        for (i in 0...len) pop();

        return ret;
	}

    public function insert(pos:Int, x:Int) : Void{
        if (pos < 0){
            pos = length + pos;
            if (pos < 0) pos = 0;
        }
        var end = length-1;
        while(end >= pos){
            arrayWrite(end+1, arrayAccess(end));
            end--;
        }
        arrayWrite(pos, x);
    }

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
        var ret = new IntArray(bitSize, nullable);
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

    public function pop():Null<Int>{
       if (length == 0){
           return null;
       }
       var ret = arrayAccess(length-1);

       if (finalOffset > 0){
           finalOffset-=1;
       } else {
           if (this.length <= 1) return null;
           this.pop();
           finalOffset = Std.int(32 / (bitSize -1)) -1;
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

    public function shift(): Null<Int> {
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
#if js
       return '${[for (i in iterator()) i].join(',')}';
#else
       return '[${[for (i in iterator()) i].join(',')}]';
#end
    }

    public static function fromArray(arr:Array<Int>, bitSize:Int, ?nullable : Bool) : IntArray{
        var ret = new IntArray(bitSize, nullable);
        for (a in arr) {
            ret.push(a);
        }
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
        var ret = new IntArray(bitSize, nullable);
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

    public function unshift(x:Int){
        var ret = x;
        var tmplength = length;
        for (i in 0...tmplength){
            var j = tmplength-i-1;
            arrayWrite(j+1, arrayAccess(j));
        }
        arrayWrite(0, x);
        return ret;
    }

    /**
      Return a copy of the raw underlying array.
     **/
    public inline function dump(){
        return this.copy();
    }
}



