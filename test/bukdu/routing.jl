module test_bukdu_routing

using Test

function penetrate_segments(segments)
    vals = Expr[]
    path_params = Expr[]
    for seg in segments
        if startswith(seg, ':')
            name = seg[2:end]
            mangled = Symbol(name, :_)
            pair = :(Pair($name, String(first(typeof($mangled).parameters))))
            push!(path_params, pair)
            expr = :($mangled::Any)
        else
            expr = :(::Val{Symbol($seg)})
        end
        push!(vals, expr)
    end
    return (vals, path_params)
end

struct Conn
end

abstract type ApplicationController end

struct WelcomeController <: ApplicationController
    conn::Conn
end

struct Route
    C::Type{<:ApplicationController}
    action
    path_params::Dict{String, String}
end

index(::WelcomeController) = "hello"

C = WelcomeController
action = index

url = "/a/:b/:c"
segments = split(url, '/')
(vals, path_params) = penetrate_segments(segments)
method = "GET"
@eval route(::Val{Symbol($method)}, $(vals...)) = Route($C, $action, Dict($(path_params...)))


target_path = "/a/25/36"
segments = split(target_path, '/')
vals = [Val(Symbol(seg)) for seg in segments]
r = route(Val(Symbol(method)), vals...)

@test r.C == WelcomeController
@test r.action == index
@test r.path_params == Dict("c"=>"36","b"=>"25")

end # module test_bukdu_routing
