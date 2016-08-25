# parent module Bukdu

function config(; kw...)
    merge!(Configure.env, Dict(map(kw) do kv
        (k,v) = kv
        (k,Dict(v))
    end))
end

module Configure
env = Dict()
end # module Configure

type Endpoint
end

function getindex(::Type{Endpoint}, sym::Symbol)
    Configure.env[sym]
end
