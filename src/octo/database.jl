# module Bukdu.Octo

module Database

export Adapter
include("adapters.jl")

import .Adapter: DatabaseAdapter, NoAdapter, NoAdapterError, disconnect
import Base: reset

settings = Dict{Symbol,Any}(
    :adapter => Adapter.NoAdapter(),
    :automatically_install_packages => false
)

function get_adapter()::DatabaseAdapter # <: DatabaseAdapter
                             # throw NoAdapterError
    adapter = settings[:adapter]
    isa(adapter, NoAdapter) && throw(NoAdapterError(""))
    adapter
end

function set_adapter{A<:DatabaseAdapter}(adapter::A)
    settings[:adapter] = adapter
end

function setup{A<:DatabaseAdapter}(block::Function, ::Type{A})::A
    name = lowercase(string(A.name.name))
    adapter = A()
    !applicable(connect, adapter) &&
        include(normpath(dirname(@__FILE__), "adapters/$name.jl"))
    block(adapter)
    set_adapter(adapter)
    adapter
end

function reset()
    reset(get_adapter())
end

end # module Bukdu.Octo.Database

import .Database: Adapter, disconnect
