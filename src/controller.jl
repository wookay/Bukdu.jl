abstract ApplicationController

# verbs: get, post, delete, patch, put
const HTTP_VERBS = [:get, :post, :delete, :patch, :put]

import Base: get, show, edit

for verb in HTTP_VERBS
    @eval $verb{AC<:ApplicationController}(path::String, controller::Type{AC}, action::Function; kw...) =
        Routing.match($verb, path, controller, action, Dict(kw))
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
