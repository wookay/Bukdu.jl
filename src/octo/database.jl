# module Bukdu.Octo

module Database

export Adapter, NoAdapterError

settings = Dict{Symbol,Any}(
    :adapter => nothing
)

type NoAdapterError
    message::String
end

type Adapter{T}
end

include("adapters/dict.jl")

function get_adapter() # throw NoAdapterError
    adapter = settings[:adapter]
    isa(adapter, Void) && throw(NoAdapterError(""))
    adapter
end

function set_adapter(T::Type)
    settings[:adapter] = Adapter{T}
    include(normpath(dirname(@__FILE__), "adapters/dict.jl"))
end

end # module Bukdu.Octo.Database
