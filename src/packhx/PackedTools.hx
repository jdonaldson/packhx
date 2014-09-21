package packhx;
class PackedTools {
    public static function toInteger(arr:Array<Int>){
        var val = 0;
        var unit = 0x80000000;
        for (i in 0...32){

            if (arr[i] > 0){
                val |= unit ;
            }
            unit >> 1;
        }
        return val;

    }
    public static function bitArray(val:Int){
        var arr = [];
        var bit = 1;
        for (i in 0...32){
            arr.unshift(val & bit);
            val >>= 1;
        }
        return arr;
    }
    /**
      This routine will extract the value of [value] at [offset] with [length]
      and return it as if that were a binary number.
     **/
    public static inline function maskExtract(value : Int, offset : Int, length : Int){
        return (value >>> offset)  & ~(~0 << length);
    }
    /**
      This routine will first clear the value [getvalue] at [offset] with
      [length], and then set that same range to the value of [setvalue].

      Note that we need to use maskExtract on setvalue to handle negative
      integers.
     **/
    public static inline function maskSet(getvalue : Int, offset : Int, length : Int, setvalue : Int){
        return (maskClear(getvalue, offset, length))
            | maskExtract(setvalue, 0, length)  << offset;
    }
    /**
      This routine will clear a range of bits on [getvalue] at [offset] with
      [length], and return the result.
     **/
    public static inline function maskClear( getvalue : Int, offset : Int, length : Int){
        return getvalue & ~(((1 << length)-1) << offset);
    }
    /**
      This routine will extract [value] at [offset] with [length] into a signed
      Integer.  E.g. with expanded range of bits as ...[bits]... :
      ...100... -> 1111111111111111111111111111100
      ...011... -> 0000000000000000000000000000011
     **/
    public static function maskExtractSigned(value: Int, offset : Int, length: Int){
        return value << 32 - offset - length >> 32 - length;
    }
}
