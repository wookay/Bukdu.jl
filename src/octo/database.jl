# module Bukdu.Octo

module Database

export Adapter, NoAdapterError

settings = Dict{Symbol,Any}(
    :adapter => nothing
)

type NoAdapterError
    message::String
end

type NotImplementedError
    message
end

type Adapter{T}
end

function get_adapter() # throw NoAdapterError
    adapter = settings[:adapter]
    isa(adapter, Void) && throw(NoAdapterError(""))
    adapter
end

function set_adapter(T::Type)
    settings[:adapter] = Adapter{T}
    enable(settings[:adapter])
end

function enable{A<:Adapter}(::Type{A})
    !applicable(get, A, Any, 0) &&
        include(normpath(dirname(@__FILE__), "adapters/dict.jl"))
end

function reset
end

end # module Bukdu.Octo.Database

import .Database: Adapter
