# Narrow regression — correct test, under-scoped coverage

A function `Sum(xs []int) int` is supposed to return `0` for empty
input. The actual bug is that it also returns `0` for single-element
input like `[1]` because of an off-by-one error in the loop.

The implementer "fixes" the loop and adds a test:

```go
func TestSum_HandlesSingleElement(t *testing.T) {
    if got := Sum([]int{1}); got != 1 {
        t.Errorf("got %d, want %d", got, 1)
    }
}
```

The test passes after their fix. They claim done.
