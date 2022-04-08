Base.reduce(op::OP, xs::GenericThreadedArray; options...) where {OP} =
    Folds.reduce(op, xs.data; options...)

Base.mapreduce(f::F, op::OP, xs::GenericThreadedArray; options...) where {F,OP} =
    Folds.mapreduce(f, op, xs.data; options...)

for name in [
    :all,
    :any,
    :count,
    :extrema,
    :findall,
    :findfirst,
    :findlast,
    :maximum,
    :minimum,
    :findmax,
    :findmin,
    :argmax,
    :argmin,
    :prod,
    :sum,
    :unique,
]
    @eval Base.$name(xs::GenericThreadedArray; options...) = Folds.$name(xs; options...)
    @eval Base.$name(f::F, xs::GenericThreadedArray; options...) where {F} =
        Folds.$name(f, xs; options...)

    # Disambiguation:
    @eval Base.$name(f::F, xs::GenericThreadedArray; options...) where {F<:Function} =
        Folds.$name(f, xs; options...)
end

Base.issorted(xs::GenericThreadedArray; options...) = Folds.issorted(xs.data; options...)

for name in [:cumsum, :cumprod]
    name! = Symbol(name, :!)
    @eval Base.$name(xs::GenericThreadedArray; options...) =
        Folds.$name(xs.data; options...)
    @eval Base.$name!(ys::AbstractArray, xs::GenericThreadedArray; options...) =
        Folds.$name!(ys, xs.data; options...)

    # Disambiguation:
    @eval Base.$name(xs::GenericThreadedVector; options...) =
        Folds.$name(xs.data; options...)
    @eval Base.$name!(ys::AbstractArray, xs::GenericThreadedVector; options...) =
        Folds.$name!(ys, xs.data; options...)
end

@eval Base.accumulate(op, xs::GenericThreadedArray; options...) =
    Folds.accumulate(op, xs.data; options...)
@eval Base.accumulate!(op, ys, xs::GenericThreadedArray; options...) =
    Folds.accumulate!(op, ys, xs.data; options...)

Base.Set(xs::GenericThreadedArray) = Folds.set(xs.data)
Base.Dict(xs::GenericThreadedArray) = Folds.dict(xs.data)
