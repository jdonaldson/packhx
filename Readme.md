# Packhx

Packhx is a bit packed array abstract implementation for Haxe.  It is considered alpha 
level, use at your own risk!


Bit packing is useful in situations where you need an array of integers, but do 
not need to use the entire maximum integer value range ( around 4 billion).

By specifying a new max size, Packhx can use a given Int32 array cell for more
than one value. In the example below, we are storing the 9 bit packed values i{0-9} in
the 32 bit array cell values b{0-2}.  Note that values can overlap.

<table class="monospace">
  <tr>
    <td colspan="32">b0</td>
    <td colspan="32">b1</td>
    <td colspan="32">b2</td>
    <td style="border-style: dashed; border-right: none;">...</td>
  </tr>
  <tr>
    <td colspan="9">i0</td>
    <td colspan="9">i1</td>
    <td colspan="9">i2</td>
    <td colspan="9">i3</td>
    <td colspan="9">i4</td>
    <td colspan="9">i5</td>
    <td colspan="9">i6</td>
    <td colspan="9">i7</td>
    <td colspan="9">i8</td>
    <td colspan="9">i9</td>
    <td style="border-style: dashed; border-right: none;">...</td>
  </tr>
</table>

To create packed IntArray, you must specify the maximum bit size you want:

```haxe
var parr = new packhx.IntArray(9);
```

You can iterate over it normally : 

```haxe
for (p in parr){ trace(p); }
```

You can set and access the packed values using normal array accessors :

```haxe
parr[3] = 4;
trace(parr[3]);
```

If you're curious, you can access the raw underlying array value : 

```haxe
trace(parr.dump());
//[44,65536]
```

The packed array value is often much smaller than the equivalent native array:

```haxe
   var k = new IntArray(12); // 12 bit maximum number
   var l = new Array<Int>();
   for (i in 0...1000){ l[i] = Std.int(Math.random() * 500); k[i] = l[i]; }
   trace(l.length); // size is 1000
   trace(k.dump().length); // size is 376... ***>60% reduction!***
```

The total array size savings will be roughly equivalent to the ratio of your bit
size argument to 32 bits, minus a small amount of space used for packhx internals.



You can use a packed int array whenever you need a normal int array.  The Haxe
abstract will convert it for you (note that this will make a copy an incur some
overhead.  Consider using the IntArray iterator method instead.)

```haxe
   var f = function(iarr : Array<Int>){
      trace(Std.is(iarr, Array));
   }
   f(parr); // call an array argument function with an IntArray
```
# Caveats

The IntArray type allows for aribtrary array access.  However, unlike normal
array access an unset cell will return 0 instead of null.


# Future work
1. Negative integers
2. Full array interface support

# Acknowledgements

* I used some markdown table and examples from [Gregory Paskoz's PackedArray library][gpaskoz].
* I learned about some basic performance characteristics from [Daniel Lemire's
recent blog post on the
subject][lemire].

[gpaskoz]: https://github.com/gpakosz/PackedArray
[lemire]: http://lemire.me/blog/archives/2012/03/06/how-fast-is-bit-packing/
