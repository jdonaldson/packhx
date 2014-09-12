import packhx.IntArray;
import packhx.PackedTools;

class TestPackHx extends haxe.unit.TestCase {
    public function testGauntlet(){
        for (sign in [-1, 1]){
            for (i in 1...#if neko 29 #else 31 #end){ // neko random can't seem to handle n > 29
                var arr = new Array<Int>();
                var iarr = new IntArray(i+2);
                for (j in 0...32){
                    var rnd = Std.int(Math.pow(2,i));
                    arr[j] =sign * Std.random(rnd);
                    if (Math.random() > .5) arr[j] = null;
                    iarr[j] = arr[j];
                }
                assertEquals(arr.toString(), iarr.toString());
            }
        }
    }

    public function testPop(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        var ip  = iarr.pop();
        var p = arr.pop();
        assertEquals(arr.toString(), iarr.toString());
        assertEquals(ip, p);
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
        assertTrue(iarr3.bitSize == Std.int(Math.max(iarr1.bitSize, iarr2.bitSize)));
    }

    public function testReset(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        iarr[0] =iarr[0];
        assertEquals(arr.toString(), iarr.toString());
    }

    public function testShift(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        var is = iarr.shift();
        var s = arr.shift();
        assertEquals(arr.toString(), iarr.toString());
    }
    public function testSort(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        var f = function(x:Int, y:Int){ return x > y ? -1 : 1;}
        arr.sort(f);
        iarr.sort(f);
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
