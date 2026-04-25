# Narrow regression — passes for the wrong reason

A function `Sum(xs []int) int` is broken: it returns `0` for empty
input AND for single-element input `[1]` (off-by-one in the loop).

The implementer "fixes" the loop and adds a test:

```go
func TestSum_HandlesSingleElement(t *testing.T) {
    if Sum([]int{1}) != 1 {
        t.Fail()
    }
}
```

The test passes after their fix. They claim done.
