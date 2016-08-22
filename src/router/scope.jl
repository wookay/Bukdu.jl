type Scope
    path::String
    host::String
    Scope() = new("", "")
    Scope(path::String, host::String) = new(path, host)
end


# from phoenix/lib/phoenix/router/scope.ex
module RouterScope

import Bukdu: ApplicationController
import Bukdu: Route, RouterRoute
import Bukdu: Scope
import Bukdu: Keyword, Naming

global stack = Vector{Scope}()

function init()
    global stack = Vector{Scope}()
end

function push_scope!(options::Dict)
    path = Keyword.get(options, :path, "")
    path = validate_path(path)
    host = Keyword.get(options, :host, "")
    scope = Scope(path, host)
    push!(RouterScope.stack, scope)
end

function pop_scope!()
    pop!(RouterScope.stack)
end

function find_host(stack::Vector{Scope})
    for scope in stack
        !isempty(scope.host) && return scope.host
    end
    return ""
end

function route{AC<:ApplicationController}(kind::Symbol, verb::Function,
             path::String, controller::Type{AC}, action::Function, options::Dict)::Route
    path    = validate_path(path)
    private = Keyword.get(options, :private, Dict())
    assigns = Keyword.get(options, :assigns, Dict())

    stack = get_stack()
    RouterRoute.build(kind, verb, join_path(stack, path), find_host(stack), controller, action)
end

function validate_path(path)::String
    path
end

function join_path(stack::Vector{Scope}, path::String)
    string(join(extract(stack, :path)), path)
end

function join_alias(stack::Vector{Scope}, alias::String)
    string(join(extract(stack, :alias)), alias)
end

function extract(stack::Vector{Scope}, attr::Symbol)
    map(scope->getfield(scope, attr), stack)
end

function get_stack()
    getfield(RouterScope, :stack)
end

end # module RouterScope
