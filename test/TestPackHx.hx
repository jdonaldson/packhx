import packhx.IntArray;
import packhx.PackedTools;

class TestPackHx extends haxe.unit.TestCase {
    public function testGauntlet(){
#if neko
        for (i in 1...30){ // neko random can't seem to handle n > 29
#else
        for (i in 1...32){
#end
            var arr = new Array<Int>();
            var iarr = new IntArray(i);
            for (j in 0...32){
                var rnd = Std.int(Math.pow(2,i));
                arr[j] =Std.random(rnd);
                iarr[j] = arr[j];
            }
            assertEquals(arr.toString(), iarr.toString());
        }
    }
    public function testPop(){
        var iarr = new IntArray(8);
        iarr.push(1);
        iarr.pop();
        assertTrue(iarr.length() == 0);
    }
    public function testIterator(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        var parr = [];
        for (i in iarr){
            parr.push(i);
        }
        assertEquals(arr.toString(), parr.toString());

    }
    public function testConcat(){
        var arr = [1,2,3];
        var iarr1 = IntArray.fromArray(arr, 6);
        var iarr2 = IntArray.fromArray(arr, 12);
        var iarr3 = iarr1.concat(iarr2);
        assertTrue(iarr3.cellSize() == Std.int(Math.max(iarr1.cellSize(), iarr2.cellSize())));
    }
    public function testReset(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        iarr[0] =iarr[0];
        assertEquals(arr.toString(), iarr.toString());

    }
    public function testReverse(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        arr.reverse();
        iarr.reverse();
        assertEquals(arr.toString(), iarr.toString());
    }
}
