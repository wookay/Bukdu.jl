# module Bukdu

abstract ApplicationController

# verbs: get, post, delete, patch, put
const HTTP_VERBS = [:get, :post, :delete, :patch, :put]

import Base: get, show, edit, getindex

for verb in HTTP_VERBS
    @eval $verb{AC<:ApplicationController}(path::String, controller::Type{AC}, action::Function; kw...) =
        Routing.match($verb, path, controller, action, Dict(kw))
end

function getindex{AC<:ApplicationController}(C::AC, sym::Symbol)
    if sym in [:query_params, :params, :action, :private, :assigns]
        task = current_task()
        if haskey(Routing.task_storage, task)
            branch = Routing.task_storage[task]
            return getfield(branch, sym)
        else
            throw(ErrorException("no $task"))
        end
    end
    throw(KeyError(sym))
end

# actions: index, edit, new, show, create, update, delete
function index
end

function edit
end

function new
end

function show
end

function create
end

function update
end

function delete
end
