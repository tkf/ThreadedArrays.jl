module TestArrays

using Test
using ThreadedArrays
using ThreadedArrays: GenericThreadedArray

function test_getset()
    xs = ThreadedArray{Int}(undef, 3)
    xs.data .= 10:10:30
    @test [xs[i] for i in 1:3] == 10:10:30
    xs[2] = 222
    @test xs[2] == 222
end

function test_iterate()
    xs = ThreadedArray(collect(1:3))
    ys = Int[]
    for x in xs
        push!(ys, x)
    end
    @test ys == 1:3
end

function test_size()
    @test size(ThreadedArray{Int}(undef, ())) == ()
    @test size(ThreadedArray{Int}(undef, 1)) == (1,)
    @test size(ThreadedArray{Int}(undef, 1, 2)) == (1, 2)
end

function test_indexstyle()
    @test IndexStyle(ThreadedArray{Int}(undef, 1)) == IndexLinear()
    @test IndexStyle(GenericThreadedArray((zeros(2, 3))')) == IndexCartesian()
end

function test_similar()
    @test similar(ThreadedArray{Int}(undef, 3)) isa ThreadedArray{Int}
    @test similar(GenericThreadedArray(1:3)) isa ThreadedArray{Int}
end

function test_threadedarray_constructor()
    @test ThreadedArray{Int}(undef, 3) isa ThreadedArray{Int,1}
    @test ThreadedArray{Int,2}(undef, 2, 3) isa ThreadedArray{Int,2}
    @test ThreadedArray{Int,2}(undef, (2, 3)) isa ThreadedArray{Int,2}
    @test ThreadedArray([1, 2, 3]) isa ThreadedArray{Int,1}
end

function test_genericthreadedarray_constructor()
    @test GenericThreadedArray(1:3) isa GenericThreadedArray{Int,1}
    @test GenericThreadedArray{Int}(1:3) isa GenericThreadedArray{Int,1}
    @test GenericThreadedArray{Int,1}(1:3) isa GenericThreadedArray{Int,1}
end

end  # module
