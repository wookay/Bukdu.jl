# module Bukdu

immutable Scope
    path::String
    host::String
    private::Dict{Symbol,String}
    assigns::Dict{Symbol,String}
end


module RouterScope

import ..Bukdu: ApplicationController
import ..Bukdu: Route, RouterRoute
import ..Bukdu: Scope
import ..Bukdu: Keyword, Naming

stack = Vector{Scope}()

function push_scope!(options::Dict)
    path = Keyword.get(options, :path, "")::String
    path = validate_path(path)
    host = Keyword.get(options, :host, "")::String
    private = Dict{Symbol,String}(Keyword.get(options, :private, Dict()))
    assigns = Dict{Symbol,String}(Keyword.get(options, :assigns, Dict()))
    scope = Scope(path, host, private, assigns)
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
    stack = get_stack()
    private = Dict{Symbol,String}(reduce(merge, vcat(extract(stack, :private), Keyword.get(options, :private, Dict()))))
    assigns = Dict{Symbol,String}(reduce(merge, vcat(extract(stack, :assigns), Keyword.get(options, :assigns, Dict()))))
    RouterRoute.build(kind, verb, join_path(stack, path), find_host(stack), controller, action, private, assigns)
end

function validate_path(path)::String
    path
end

function join_path(stack::Vector{Scope}, path::String)
    string(join(extract(stack, :path)), path)
end

function extract(stack::Vector{Scope}, attr::Symbol)
    map(scope->getfield(scope, attr), stack)
end

function get_stack()
    getfield(RouterScope, :stack)
end

end # module Bukdu.RouterScope
