# module Bukdu

immutable Scope
    path::String
    host::String
    pipes::Vector{Pipeline}
    private::Assoc
    assigns::Assoc
end


module RouterScope

import ..Bukdu
import Bukdu: ApplicationController, Route, RouterRoute, Scope, Pipeline, Keyword, Naming, Assoc
import Bukdu: Logger

stack = Vector{Scope}()
pipes = Vector{Pipeline}()

function push_scope!(options::Dict)
    path = Keyword.get(options, :path, "")::String
    path = validate_path(path)
    host = Keyword.get(options, :host, "")::String
    private = Assoc(Keyword.get(options, :private, Assoc()))
    assigns = Assoc(Keyword.get(options, :assigns, Assoc()))
    pipes = Vector{Pipeline}()
    scope = Scope(path, host, pipes, private, assigns)
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
             path::String, ::Type{AC}, action::Function, options::Dict)::Route
    path = validate_path(path)
    stack = get_stack()
    pipes = get_pipes()
    private = reduce(merge, vcat(extract(stack, :private), Keyword.get(options, :private, Assoc())))
    assigns = reduce(merge, vcat(extract(stack, :assigns), Keyword.get(options, :assigns, Assoc())))
    RouterRoute.build(kind, verb, join_path(stack, path), find_host(stack), AC, action, pipes, private, assigns)
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

function get_pipes()
    getfield(RouterScope, :pipes)
end

function pipe_through(pipe::Pipeline)
    scope = first(stack)
    push!(scope.pipes, pipe)
    push!(RouterScope.pipes, pipe)
end

end # module Bukdu.RouterScope
