package packhx;
class PackedTools {
    public static function bitArray(val:Int){
        var arr = [];
        var bit = 1;
        for (i in 0...32){
            arr.unshift(val & bit);
            val >>= 1;
        }
        return arr;
    }
    public static inline function maskExtract(value : Int, offset : Int, length : Int){
        return (value >>> offset)  & ~(~0 << length);
    }
    public static inline function maskSet(getvalue : Int, offset : Int, length : Int, setvalue : Int){
        return (getvalue & maskClear(offset, length)) | (setvalue << offset); 
    }
    public static inline function maskClear( offset : Int, length : Int){
        return (~0 << length + offset) | ~(~0 << offset);
    }
}
