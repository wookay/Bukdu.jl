# parent module Bukdu

type Route{AC<:ApplicationController}
    verb::Function # get
    kind::Symbol # :match, :forward
    path::String
    host::String
    controller::Type{AC}
    action::Function
end


module RouterRoute

import Bukdu: ApplicationController
import Bukdu: Route

routes = Vector{Route}()

function build{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String,
             host::String, controller::Type{AC}, action::Function)
    Route(verb, kind, path, host, controller, action)
end

end # module RouterRoute
