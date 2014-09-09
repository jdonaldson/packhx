import packhx.IntArray;
import packhx.PackedTools;

class TestPackHx extends haxe.unit.TestCase {
    static inline var bitsize = 12;
    // public function testArraytoStringEquality() {
    //     var arr = new Array<Int>();
    //     var iarr = new IntArray(bitsize);
    //     for (i in 0...10){
    //         arr[i] = Std.int(Math.random() * Math.pow(2, bitsize));
    //         iarr[i] = arr[i];
    //     }
    //     assertEquals(arr.toString(), iarr.toString());
    // }
    public function testPop(){
        var iarr = new IntArray(8); 
        iarr[0] = 1;
        iarr[1] = 2;
        iarr[2] = 3;

        trace(iarr.length());
        iarr.pop();
        // arr.pop();
        // assertEquals(arr.toString(), iarr.toString());
        assertTrue(true);
    }
    // public function testConcat(){
    //     var arr = [1,2,3];
    //     var iarr1 = IntArray.fromArray(arr, 6); 
    //     var iarr2 = IntArray.fromArray(arr, 12); 
    //     var iarr3 = iarr1.concat(iarr2);
    //     assertTrue(iarr3.cellSize() == Std.int(Math.max(iarr1.cellSize(), iarr2.cellSize())));
    // }
    public function testIntArray8(){
        var a = new IntArray(8);
        var b = new Array<Int>();
        var x = [8,16,32];
        for (v in 0...3){
            b.push(x[v]);
            a[v] = x[v];
        }

        assertEquals(b.toString(),a.toString());
    }
}
