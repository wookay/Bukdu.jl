# module Bukdu

immutable Route{AC<:ApplicationController}
    verb::Function # get
    kind::Symbol # :match, :forward
    path::String
    host::String
    controller::Type{AC}
    action::Function
    private::Dict{Symbol,String}
    assigns::Dict{Symbol,String}
end


module RouterRoute

import ..Bukdu: ApplicationController
import ..Bukdu: Route

routes = Vector{Route}()

function build{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String,
             host::String, controller::Type{AC}, action::Function, private::Dict{Symbol,String}, assigns::Dict{Symbol,String})
    Route(verb, kind, path, host, controller, action, private, assigns)
end

end # module Bukdu.RouterRoute
