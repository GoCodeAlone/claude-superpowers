Add an `Inspect(req Request) error` method to `Dispatcher` mirroring the existing
`Create` and `Delete` shape. The new method must produce a Send call whose args
match the same convention as siblings.
