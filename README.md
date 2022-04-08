# ThreadedArrays: A proof-of-concept implementation for easy parallelism injection

**IMPORTANT**: This approach is [broken](#limitations).  However, it may be useful for
limited cases until a more principled approach like
[ParallelMagics.jl](https://github.com/JuliaFolds/ParallelMagics.jl) is available.

ThreadedArrays.jl provides a way to inject parallelism in the code that is already written
and is happened to be parallelizable.  It uses the "vanilla" multiple dispatch mechanism to
route certain `Base` APIs (e.g., `sum`) to use JuliaFolds-based implementation.

```julia
julia> using ThreadedArrays  # exports ThreadedArray

julia> a = [1:2^20;];

julia> b = ThreadedArray(a);

julia> using 0.21667559252431068

julia> Threads.nthreads()
4

julia> @btime sum(sin, a);
  22.324 ms (1 allocation: 16 bytes)

julia> @btime sum(sin, b);
  5.632 ms (25 allocations: 1.70 KiB)
```

## APIs and usage

Following Base APIs are supports. In addition to the preconditions required by the standard
APIs, **the user is responsible for verifying that the user-specified functions (denoted by
`f` and `op` below) are safe to be invoked on multiple tasks without any synchronizations**
(e.g., they must be data-race-free).

* `map(f, xs::ThreadedArray)`
* `reduce(op, xs::ThreadedArray; init)`
* `mapreduce(f, op, xs::ThreadedArray; init)`
* `all([f], xs::ThreadedArray; init)`
* `any([f], xs::ThreadedArray; init)`
* `count([f], xs::ThreadedArray; init)`
* `maximum([f], xs::ThreadedArray; init)`
* `minimum([f], xs::ThreadedArray; init)`
* `extrema([f], xs::ThreadedArray; init)`
* `findall([f], xs::ThreadedArray; init)`
* `findfirst([f], xs::ThreadedArray; init)`
* `findlast([f], xs::ThreadedArray; init)`
* `maximum([f], xs::ThreadedArray; init)`
* `minimum([f], xs::ThreadedArray; init)`
* `findmax([f], xs::ThreadedArray; init)`
* `findmin([f], xs::ThreadedArray; init)`
* `argmax([f], xs::ThreadedArray; init)`
* `argmin([f], xs::ThreadedArray; init)`
* `prod([f], xs::ThreadedArray; init)`
* `sum([f], xs::ThreadedArray; init)`
* `unique([f], xs::ThreadedArray; init)`
* `issorted(xs::ThreadedArray)`
* `cumsum(xs::ThreadedArray)`
* `cumsum!(ys, xs::ThreadedArray)`
* `cumprod(xs::ThreadedArray)`
* `cumprod!(ys, xs::ThreadedArray)`
* `accumulate(op, xs::ThreadedArray; init)`: `(op, init)` must be a monoid
* `accumulate!(op, ys, xs::ThreadedArray; init)`: `(op, init)` must be a monoid
* `Set(xs::ThreadedArray)`
* `Dict(xs::ThreadedArray)`

## Limitations

### Limitation in safety guarantee and usability

ThreadedArrays.jl is safe to use provided that the user (i.e., the programmer writing the
code that constructs `ThreadedArray`s) writes and reviews the code that invokes all APIs
supported by ThreadedArrays.  Passing a `ThreadedArray` to a library code is fundamentally
unsafe in general since the parallelizability is an implementation detail.

Interestingly, this also has an implication in the SemVer-based code compatibility
reasoning.  If ThreadedArrays.jl is released (hypothetically), it has to consider that the
pure *addition* of new implementation (dispatch) of is a *breaking* change.  This is because
the users may be relying on non-parallel semantics of a Base API that is not parallelized in
an old version of ThreadedArrays.jl.  If a new implementation is added, all users must go
through their code base to check that the APIs with the new implementation can support
parallelized execution.  This is counter-intuitive from the usual point-of-view of
compatibility in which addition of new APIs is not considered a breaking change.

### Limitation in "vanilla" method dispatch

ThreadedArrays.jl only supports very limited set of data-parallel processing.  For example,
unfortunately, it cannot support a simple composition of data parallel processing such as

```julia
# Given:
xs::ThreadedArray{Int}

sum(gcd(x, 42) for x in xs if isodd(x))
```

This is because `Base`'s dispatch pipeline is not designed to support.  Furthermore, it is
semantically unclear what should happen when `ThreadedArray` is a part of a "composite" data
structures such as `zip`:

```julia
# Given:
a::AbstractArray
b::ThreadedArray

sum(((x, y),) -> x * y, zip(a, b))
mapreduce(*, +, a, b)  # equivalent
```
