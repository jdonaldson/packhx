import packhx.IntArray;
class Test {
    static function main() {
        test();
    }
    public static function test() {
        var k = new IntArray(12);
        var l = new Array<Int>();
        k[3] = 4;
        trace(k.dump());
        for (i in 0...1000){
            l[i] = Std.int(Math.random() * 500);
            k[i] = l[i];
        }
        for (i in 0...1000){
            if (k[i] != l[i]) {
                trace('index $i');
                trace(k[i]);
                trace(l[i]);
            }
            if (k.length() != l.length){
                trace('index $i');
                trace(k[i]);
                trace(l[i]);
            }
        }
        trace('test complete');
        trace(k);
        trace(l.length);
        trace(k.dump().length);
        k.concat(k);
        arr(k);
        
    }
    public static function arr(arr:Array<Int>){
       trace(Std.is(arr,Array));
    }
}
