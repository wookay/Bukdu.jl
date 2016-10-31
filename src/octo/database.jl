# module Bukdu.Octo

module Database

export Adapter
include("adapters.jl")

import .Adapter: DatabaseAdapter, NoAdapter, NoAdapterError
import ..Logger
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
    !applicable(Adapter.execute, adapter, "") &&
        include(normpath(dirname(@__FILE__), "adapters/$name.jl"))
    block(adapter)
    set_adapter(adapter)
    adapter
end

function reset()
    reset(get_adapter())
    set_adapter(Adapter.NoAdapter())
end

function install_guide(adapter_name::String)::Bool
    automatically_install_packages = settings[:automatically_install_packages]
    if automatically_install_packages
        Logger.info("Installing $adapter_name...")
        Pkg.add(adapter_name)
    else
        Logger.warn(string("Run ", Logger.with_color(:bold, """Pkg.add("$adapter_name")"""), " to install $adapter_name"))
    end 
    automatically_install_packages
end

end # module Bukdu.Octo.Database

import .Database: Adapter
