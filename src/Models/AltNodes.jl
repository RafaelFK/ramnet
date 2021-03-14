module AltNodes

using StaticArrays

import ..AbstractModel, ..train!, ..predict, ..reset!

export AbstractNode, RegressionNode, FunctionalNode

abstract type AbstractNode{D} <: AbstractModel end

## Generic functions
reset!(node::N) where {N <: AbstractNode} = empty!(node.memory)

predict(node::N, X::UInt) where {N <: AbstractNode} = get(node.memory, X, zero(eltype(N)))

# ============================== Concrete types ============================== #
# ------------------------------ Regression Node ----------------------------- #
struct RegressionNodeMemoryElement{D}
    count::MVector{D,Int}
    value::MVector{D,Float64}
end

function RegressionNodeMemoryElement{D}() where {D}
    RegressionNodeMemoryElement{D}(zero(MVector{D,Int}), zero(MVector{D,Int}))
end

Base.zero(::Type{RegressionNodeMemoryElement{D}}) where {D} = RegressionNodeMemoryElement{D}()

struct RegressionNode{D} <: AbstractNode{D}
    γ::Float64
    memory::Dict{UInt,RegressionNodeMemoryElement{D}}
end

function RegressionNode{D}(; γ=1.0) where {D}
    RegressionNode{D}(
    γ,
    Dict{UInt,RegressionNodeMemoryElement{D}}()
  )
end

Base.eltype(::Type{RegressionNode{D}}) where {D} = RegressionNodeMemoryElement{D}

function train!(node::RegressionNode{D}, X::UInt, y::StaticArray{Tuple{D},Float64,1}) where {D}
    el = get!(node.memory, X, zero(eltype(RegressionNode{D})))

    el.count .+= 1
    el.value .*= node.γ
    el.value .+= y 

    nothing
end

# ------------------------------ Functional Node ----------------------------- #
struct FunctionalNode{D} <: AbstractNode{D}
    memory::Dict{UInt,MVector{D,Float64}}
end

function FunctionalNode{D}() where {D}
    FunctionalNode{D}(Dict{UInt,MVector{D,Float64}}())
end

Base.eltype(::Type{FunctionalNode{D}}) where {D} = MVector{D,Float64}

function train!(node::FunctionalNode{D}, X::UInt, y::StaticArray{Tuple{D},Float64,1}) where {D}
    value = get!(node.memory, X, zero(eltype(FunctionalNode{D})))

    value .+= y

    nothing
end

end