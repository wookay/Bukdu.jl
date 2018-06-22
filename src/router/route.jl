# module Bukdu

immutable Route{AC<:ApplicationController}
    verb::Function # get
    kind::Symbol # :match, :forward
    path::String
    host::String
    controller::Type{AC}
    action::Function
    pipes::Vector{Pipeline}
    private::Assoc
    assigns::Assoc
end


module RouterRoute

import ..Bukdu: ApplicationController, Route, Pipeline, Assoc

function build{AC<:ApplicationController}(kind::Symbol, verb::Function, path::String,
             host::String, ::Type{AC}, action::Function, pipes::Vector{Pipeline}, private::Assoc, assigns::Assoc)
    Route(verb, kind, path, host, AC, action, pipes, private, assigns)
end

end # module Bukdu.RouterRoute
