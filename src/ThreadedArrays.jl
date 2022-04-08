baremodule ThreadedArrays

export ThreadedArray, ThreadedVector, ThreadedMatrix

struct GenericThreadedArray{T,N,Data} <: Core.AbstractArray{T,N}
    data::Data
end

const GenericThreadedVector{T,Data} = GenericThreadedArray{T,1,Data}
const GenericThreadedMatrix{T,Data} = GenericThreadedArray{T,2,Data}

const ThreadedArray{T,N} = GenericThreadedArray{T,N,Core.Array{T,N}}
const ThreadedVector{T} = ThreadedArray{T,1}
const ThreadedMatrix{T} = ThreadedArray{T,2}

module Internal

using Base: @propagate_inbounds

import Folds

using ..ThreadedArrays:
    GenericThreadedArray, GenericThreadedVector, ThreadedArray, ThreadedArrays

include("arrays.jl")
include("folds.jl")

end  # module Internal

end  # baremodule ThreadedArrays
