module test_bukdu_routing

using Test

using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

struct Route
    C::Type{<:ApplicationController}
    action
    param_types::Dict{Symbol,DataType}
    path_params::Vector{Pair{String,Any}}
    pipelines::Vector{Function}
end

index(::WelcomeController) = "hello"

C = WelcomeController
action = index

url = "/a/:b/:c"
segments = split(url, '/')
param_types = Dict{Symbol,DataType}(:b=>Int, :c=>Int)
(vals, path_params) = Bukdu.Routing.penetrate_segments(segments)
method = "GET"
pipelines = []
@eval route(::Val{Symbol($method)}, $(vals...)) = Route($C, $action, $param_types, Vector{Pair{String,Any}}($(path_params...)), $pipelines)

target_path = "/a/25/36"
segments = split(target_path, '/')
vals = [Val(Symbol(seg)) for seg in segments]
r = route(Val(Symbol(method)), vals...)

@test r.C === WelcomeController
@test r.action === index
@test r.path_params == Vector{Pair{String,Any}}(["b"=>"25", "c"=>"36"])


# https://discourse.julialang.org/t/write-a-rest-interface-like-flask/18538
function update(c::WelcomeController)
    c.path_params
end
get("/update/region/:region/site/:site_id/channel/:channel_id/", WelcomeController, update, :region=>String, :site_id=>Int, :channel_id=>Int)

Plug.Loggers.config[:path_pad] = 36
@test Router.call(get, "/update/region/west/site/1/channel/2").got == Assoc("region"=>"west", "site_id"=>1, "channel_id"=>2)

end # module test_bukdu_routing
