# parent module Bukdu

function set(;kw...)
    Dict(kw)
end

function config(env::Dict)
   merge!(Endpoint.env, env)
end


module Endpoint

env = Dict()

function config(sym::Symbol)
    env[sym]
end

url() = getfield(env, :url)
static_url() = getfield(env, :static_url)

end # module Endpoint
