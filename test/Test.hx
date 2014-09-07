import packhx.IntArray;
class Test {
    static function main(){
        var r = new haxe.unit.TestRunner();
        r.add(new TestPackHx());
        r.run();
    }
}
