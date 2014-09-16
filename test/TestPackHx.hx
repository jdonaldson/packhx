import packhx.IntArray;
import packhx.PackedTools;

class TestPackHx extends haxe.unit.TestCase {
    public function testGauntlet(){
        // test signs, nulls, and a range of numbers
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
        var iarr1 = IntArray.fromArray(arr, 7);
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
        var arr = [5,1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        var f = function(x:Int, y:Int){ return x > y ? -1 : 1;}
        arr.sort(f);
        iarr.sort(f);
        assertEquals(arr.toString(), iarr.toString());
    }
    public function testFilter(){
        var arr = [5,1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        var f = function(x:Int){ return x == 2;}
        assertEquals(  arr.filter(f).toString(),
                      iarr.filter(f).toString());
    }

    public function testCopy(){
        var arr = [5,1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        var iarr2 = iarr.copy();
        iarr[0] = 1;
        assertFalse(iarr[0] == iarr2[0]);
        assertEquals(iarr2.toString(), arr.toString());
    }

    public function testJoin(){
        var arr = [5,1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        assertEquals(arr.join('!'), iarr.join('!'));

    }

    public function testReverse(){
        var arr = [1,2,3];
        var iarr = IntArray.fromArray(arr, 6);
        arr.reverse();
        iarr.reverse();
        assertEquals(arr.toString(), iarr.toString());
    }

    public function testIndexOf(){
        var arr = [1,2,3,2];
        var iarr = IntArray.fromArray(arr, 6);

        // test found
        assertEquals(iarr.indexOf(2), 1);
        assertEquals(arr.indexOf(2), 1);

        // test found at offset
        assertEquals(iarr.indexOf(2,2), 3);
        assertEquals(arr.indexOf(2,2), 3);

        // test not found
        assertEquals(iarr.indexOf(9), -1);
        assertEquals(arr.indexOf(9), -1);

        // test negative fromIndex
        assertEquals(iarr.indexOf(2,-2), 3);
        assertEquals(arr.indexOf(2,-2), 3);

        // test index greater than length
        assertEquals(iarr.indexOf(2,5), -1);
        assertEquals(arr.indexOf(2,5), -1);
    }

    public function lastIndexOf(){
        var arr = [1,2,3,2];
        var iarr = IntArray.fromArray(arr, 6);
        // test found
        assertEquals(iarr.lastIndexOf(2), 3);
        assertEquals(arr.lastIndexOf(2), 3);

        // test found at offset
        assertEquals(iarr.lastIndexOf(2,2), 1);
        assertEquals(arr.lastIndexOf(2,2), 1);

        // test not found
        assertEquals(iarr.lastIndexOf(9), -1);
        assertEquals(arr.lastIndexOf(9), -1);

        // test negative fromIndex
        assertEquals(iarr.lastIndexOf(2,-2), 3);
        assertEquals(arr.lastIndexOf(2,-2), 3);

        // test index greater than length
        assertEquals(iarr.lastIndexOf(2,5), -1);
        assertEquals(arr.lastIndexOf(2,5), -1);
    }

    public function testRemove(){
        var arr = [1,2,3,2,4];
        var iarr = IntArray.fromArray(arr, 6);
        arr.remove(4);
        iarr.remove(4);
        assertEquals(arr.toString(), iarr.toString());

    }


    public function testInsert(){
        var arr = [1,2,3,4];
        var iarr = IntArray.fromArray(arr, 6);

        // test negative pos < -length
        iarr.insert(-20, 5);
        arr.insert(-20, 5);
        assertEquals(arr.toString(), iarr.toString());

        // test basic insert
        iarr.insert(1,2);
        arr.insert(1,2);
        assertEquals(arr.toString(), iarr.toString());

        // test pos > length
        iarr.insert(1,iarr.length + 1);
        arr.insert(1,arr.length + 1);
        assertEquals(arr.toString(), iarr.toString());

        // test negative pos
        iarr.insert(-1, 5);
        arr.insert(-1, 5);
        assertEquals(arr.toString(), iarr.toString());


    }
}
