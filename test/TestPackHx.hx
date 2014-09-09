import packhx.IntArray;
import packhx.PackedTools;

class TestPackHx extends haxe.unit.TestCase {
    static inline var bitsize = 12;
    public function testArraytoStringEquality() {
        var arr = new Array<Int>();
        var iarr = new IntArray(14);
        for (i in 0...10){
            arr[i] = i;
            iarr[i] = arr[i];
        }
        assertEquals(arr.toString(), iarr.toString());
         
    }
    public function testPop(){
        var iarr = new IntArray(8);
        iarr.push(1);
        iarr.pop();
        assertTrue(iarr.length() == 0);
    }
    public function testConcat(){
        var arr = [1,2,3];
        var iarr1 = IntArray.fromArray(arr, 6); 
        var iarr2 = IntArray.fromArray(arr, 12); 
        var iarr3 = iarr1.concat(iarr2);
        assertTrue(iarr3.cellSize() == Std.int(Math.max(iarr1.cellSize(), iarr2.cellSize())));
    }
    public function testIntArray8(){
        var a = new IntArray(8);
        var b = new Array<Int>();
        for (v in [8,16,32,64,128]){
            b.push(v);
            a.push(v);
        }
        assertEquals(b.toString(),a.toString());
    }
}
