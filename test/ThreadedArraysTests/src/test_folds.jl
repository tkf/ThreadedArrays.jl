module TestFolds

using Test
using ThreadedArrays: GenericThreadedArray

TESTCASES_WITH_SEQUENTIAL_RAWDATA = """
all(isodd, 1:10)
all(isodd, 1:2:10)
any(isodd, 1:10)
any(isodd, 2:2:10)
count(isodd, 1:10)
Dict([x => x^2 for x in 1:10])
extrema(x -> (x - 5)^2, 1:10)
findall(isodd, 1:10)
findfirst(x -> x > 3, 1:10)
findlast(x -> x < 3, 1:10)
map(x -> x^2, 1:10)
map(+, 1:10, 11:20)
map(+, 1:10, 11:20, 21:30)
mapreduce(identity, +, 1:0)
mapreduce(x -> x^2, +, 1:10)
mapreduce(*, +, 1:10, 11:20)
mapreduce(*, +, 1:10, 11:20, 21:30)
maximum(0:9)
maximum(9:-1:0)
maximum([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
maximum([1:10; [missing]])
minimum(0:9)
minimum(9:-1:0)
minimum([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
minimum([1:10; [missing]])
findmax(0:9)
findmax(9:-1:0)
findmax([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
findmax([1:10; [missing]])
findmin(0:9)
findmin(9:-1:0)
findmin([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
findmin([1:10; [missing]])
argmax(0:9)
argmax(9:-1:0)
argmax([2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
argmax([1:10; [missing]])
argmin(0:9)
argmin(9:-1:0)
argmin(x -> x^2, [2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
argmin(x -> x^2, [1:10; [missing]])
argmax(x -> x^2, 0:9)
argmax(x -> x^2, 9:-1:0)
argmax(x -> x^2, [2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
argmax(x -> x^2, [1:10; [missing]])
argmin(x -> x^2, 0:9)
argmin(x -> x^2, 9:-1:0)
argmin(x -> x^2, [2, 3, 0, 3, 4, 0, 5, 7, 4, 2])
argmin(x -> x^2, [1:10; [missing]])
prod(1:2:10)
prod([1:10; [missing]])
prod(x -> [x -x; -x x], 1:2:19)
reduce(+, 1:0)
Set(1:10)
sum(1:10)
sum([1:10; [missing]])
sum(x -> x^2, 1:11)
sum(x -> x^2, 1:11; init = 0)
unique(x -> gcd(x, 42), 1:30)
issorted([1:5; 5:-1:0])
issorted(1:10)
cumsum([1:10;])
cumprod([1:10;])
"""

args_and_kwargs(args...; kwargs...) =
    (preargs = args[1:end-1], data = args[end], kwargs = (; kwargs...))

function parse_tests(str, _module = Module())
    return map(split(str, "\n", keepempty = false)) do x
        @debug "Parsing: $x"
        fstr, rest = split(x, "(", limit = 2)
        ex = Meta.parse("DUMMY($rest")
        ex.args[1] = args_and_kwargs
        testcase = Base.eval(_module, ex)
        f = getproperty(Base, Symbol(fstr))
        if (m = match(r"^(.*?) *# *(.*?) *$", x)) !== nothing
            label = m[1]
            tags = map(Symbol, split(m[2], ","))
        else
            label = x
            tags = Symbol[]
        end
        return (; label = label, tags = tags, f = f, testcase...)
    end
end

function getlabel((i, example),)
    if example isa NamedTuple
        return example.label
    else
        return "$i"
    end
end

function getdata((_, example),)
    if example isa NamedTuple
        return example.data
    else
        return example
    end
end

function getequality((_, example),)
    if example isa NamedTuple && haskey(example, :eq)
        return example.eq
    else
        return isequal
    end
end

function check_with_sequential(tests)
    tests = deepcopy(tests)
    @testset "$(getlabel(x))" for x in enumerate(tests)
        @debug "check_with_sequential $(getlabel(x))"
        _i, testcase = x
        f(args...) = testcase.f(testcase.preargs..., args...; testcase.kwargs...)
        ==′ = getequality(x)
        threaded = GenericThreadedArray(getdata(x))
        seq = getdata(x)
        @test f(threaded) ==′ f(seq)
    end
end

function test_with_sequential()
    tests = parse_tests(TESTCASES_WITH_SEQUENTIAL_RAWDATA)
    Base.invokelatest(check_with_sequential, tests)
end

end  # module
