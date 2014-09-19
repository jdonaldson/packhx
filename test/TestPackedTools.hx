using packhx.PackedTools;
class TestPackedTools extends haxe.unit.TestCase{
    public function testMaskClear(){
        var x = -1;
        x = x.maskClear(1,1);
        trace(x.bitArray());
        trace(x);
        var mask = ~(~(~0 << 1) << 1);
        trace(mask.bitArray());
        trace((-1 << 8 | (1 << 4)-1 ).bitArray());
        assertTrue(true);
    }
}
