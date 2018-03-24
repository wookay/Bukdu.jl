# module Bukdu

export resources

import .Actions: routing_actions
import .Actions: index, edit, new, show, create, update, delete

const default_param_key = "id"

function resources(path::String, ::Type{C}; only=[], except=[]) where {C <: ApplicationController}
    name = Naming.resource_name(C, "Controller")
    param = default_param_key
    if !isempty(only)
        actions = only
    elseif !isempty(except)
        actions = setdiff(routing_actions, except)
    else
        actions = routing_actions
    end
    for (action, verb, routepath) in [(index,  get,    ""),
                                      (new,    get,    "/new"),
                                      (edit,   get,    "/:$param/edit"),
                                      (show,   get,    "/:$param"),
                                      (create, post,   ""),
                                      (delete, delete, "/:$param"),
                                      (update, patch,  "/:$param"),
                                      (update, put,    "/:$param")]
        !(action in actions) && continue
        url = string(path, routepath)
        Routing.add_route(verb, url, C, action)
    end
end

# module Bukdu
