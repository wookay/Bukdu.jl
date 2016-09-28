# module Bukdu

# verbs: get, post, delete, patch, put
const HTTP_VERBS = [:get, :post, :delete, :patch, :put]

import Base: getindex, edit

for verb in HTTP_VERBS
    @eval $verb{AC<:ApplicationController}(path::String, ::Type{AC}, action::Function; kw...) =
        Routing.match($verb, path, AC, action, Dict(kw))
end

immutable Branch
    query_params::Assoc
    params::Assoc
    action::Function
    host::String
    headers::Assoc
    assigns::Dict{Symbol,Any}
end

function getindex{AC<:ApplicationController}(C::AC, sym::Symbol)
    if sym in fieldnames(Branch)
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

# actions: index, edit, new, show,  create, update, delete
function index
end

# edit

function new
end

# show

function create
end

function update
end

function delete
end
