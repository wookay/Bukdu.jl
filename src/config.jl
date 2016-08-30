# module Bukdu

function config{AE<:ApplicationEndpoint}(app::Symbol, endpoint::Type{AE}; kw...)
    # app, endpoint
    merge!(Configuration.env, Dict(map(kw) do kv
        (k,v) = kv
        (k,Dict(v))
    end))
end

function getindex{AE<:ApplicationEndpoint}(::Type{AE}, sym::Symbol)
    Configuration.env[sym]
end


module Configuration
env = Dict{Symbol, Any}()
end # module Bukdu.Configuration
