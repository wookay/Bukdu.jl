# module Bukdu

immutable Resource{AC<:ApplicationController}
    path::String
    param::String
    controller::Type{AC}
    actions::Vector
    route::Dict
    member::Dict
    collection::Dict
    singleton::Bool
end


module RouterResource

import ..Bukdu: ApplicationController
import ..Bukdu: Assoc, Naming
import ..Bukdu: RouterScope
import ..Bukdu: Resource
import ..Bukdu: index, edit, new, show, create, update, delete

const default_param_key = "id"
const controller_actions = [index, edit, new, show, create, update, delete]

function build{AC<:ApplicationController}(path::String, ::Type{AC}, options::Dict)
    path  = RouterScope.validate_path(path)
    alias = get(options, :alias, "")
    param = get(options, :param, default_param_key)
    name  = get(options, :name, Naming.resource_name(AC, "Controller"))
    as      = get(options, :as, name)
    private = get(options, :private, Assoc())
    assigns = get(options, :assigns, Assoc())

    singleton = get(options, :singleton, false)
    actions   = extract_actions(options, singleton)

    route       = Dict(:as => as, :private => private, :assigns => assigns)
    collection  = Dict(:path => path, :as => as, :private => private, :assigns => assigns)
    member_path = singleton ? path : string(path, "/:", name, "_", param)
    member      = Dict(:path => member_path, :as => as, :alias => alias, :private => private, :assigns => assigns)

    Resource(path, param, AC, actions, route, member, collection, singleton)
end

function extract_actions(options::Dict, singleton::Bool)::Vector{Function}
    if haskey(options, :only)
        setdiff(controller_actions, setdiff(controller_actions, options[:only]))
    else
        except = get(options, :except, [])
        setdiff(default_actions(singleton), except)
    end
end

function default_actions(singleton::Bool)::Vector{Function}
    singleton ? setdiff(controller_actions, [index]) : controller_actions
end

end # module Bukdu.RouterResource
