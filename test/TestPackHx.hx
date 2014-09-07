import packhx.IntArray;

class TestPackHx extends haxe.unit.TestCase {
    static inline var bitsize = 12;
    public function testArraytoStringEquality() {
        var arr = new Array<Int>();
        var iarr = new IntArray(bitsize);
        for (i in 0...10){
            arr[i] = Std.int(Math.random() * Math.pow(2, bitsize));
            iarr[i] = arr[i];
        }
        assertEquals(arr.toString(), iarr.toString());
    }
    public function testPop(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, bitsize); 
        iarr.pop();
        arr.pop();
        assertEquals(arr.toString(), iarr.toString());
    }
    public function testConcat(){
        var arr = [1,2,3];
        var iarr1 = IntArray.fromArray(arr, 6); 
        var iarr2 = IntArray.fromArray(arr, 12); 
        var iarr3 = iarr1.concat(iarr2);
        trace(iarr3.cellSize());
        trace(iarr1.cellSize());
        trace(iarr2.cellSize());
        assertTrue(iarr3.cellSize() == Std.int(Math.max(iarr1.cellSize(), iarr2.cellSize())));
    }
}
