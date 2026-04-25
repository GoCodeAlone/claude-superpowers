# Narrow regression — correct test, under-scoped coverage

A function `Sum(xs []int) int` is broken: it returns `0` for empty
input AND for single-element input `[1]` (off-by-one in the loop).

The implementer "fixes" the loop and adds a test:

```go
func TestSum_HandlesSingleElement(t *testing.T) {
    if got := Sum([]int{1}); got != 1 {
        t.Errorf("got %d, want %d", got, 1)
    }
}
```

The test passes after their fix. They claim done.
