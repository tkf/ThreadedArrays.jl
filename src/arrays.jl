@propagate_inbounds Base.getindex(xs::GenericThreadedArray, idx...) = xs.data[idx...]
@propagate_inbounds Base.setindex!(xs::GenericThreadedArray, v, idx...) =
    xs.data[idx...] = v
@propagate_inbounds Base.iterate(xs::GenericThreadedArray) = iterate(xs.data)
@propagate_inbounds Base.iterate(xs::GenericThreadedArray, state) = iterate(xs.data, state)

Base.size(xs::GenericThreadedArray) = size(xs.data)
Base.IndexStyle(::Type{<:GenericThreadedArray{<:Any,<:Any,Data}}) where {Data} =
    Base.IndexStyle(Data)

Base.similar(xs::GenericThreadedArray, ::Type{ElType}, dims::Dims) where {ElType} =
    GenericThreadedArray(similar(xs.data, ElType, dims))

function ThreadedArrays.ThreadedArray{T}(::UndefInitializer, args...) where {T}
    data = Array{T}(undef, args...)
    return ThreadedArray{T,ndims(data)}(data)::ThreadedArray{T}
end

ThreadedArrays.ThreadedArray{T,N}(::UndefInitializer, args...) where {T,N} =
    ThreadedArray{T,N}(Array{T,N}(undef, args...))::ThreadedArray{T,N}

ThreadedArrays.ThreadedArray(data::Array) =
    ThreadedArray{eltype(data),ndims(data)}(data)::ThreadedArray

ThreadedArrays.ThreadedArray{T}(data::Array{T}) where {T} =
    ThreadedArray{T,ndims(data)}(data)::ThreadedArray{T}

ThreadedArrays.GenericThreadedArray(data) =
    GenericThreadedArray{eltype(data),ndims(data),typeof(data)}(data)

ThreadedArrays.GenericThreadedArray{T}(data) where {T} =
    GenericThreadedArray{T,ndims(data),typeof(data)}(data)

ThreadedArrays.GenericThreadedArray{T,N}(data) where {T,N} =
    GenericThreadedArray{T,N,typeof(data)}(data)
