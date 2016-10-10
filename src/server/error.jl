# module Bukdu

import .Plug: InvalidCSRFTokenError
import .Logger: debug_verb

function Base.show{AE<:ApplicationError}(io::IO, ex::AE)
    # don't show ex.conn
    write(io, string(AE.name.name, "(\"", ex.message, "\")"))
end

function conn_error(verb::Symbol, path::String, ex, stackframes::Vector{StackFrame})::Conn
    if isa(ex, NoRouteError)
        conn = conn_not_found(verb, path, ex, stackframes) # 404
    elseif isa(ex, InvalidCSRFTokenError)
        Logger.warn() do
            debug_verb(verb, path, ex)
        end
        conn = conn_application_error(verb, path, ex, stackframes)
    else
        Logger.error() do
            Routing.error_route(verb, path, ex, stackframes)
        end
        if isa(ex, ApplicationError)
            conn = conn_application_error(verb, path, ex, stackframes)
        else
            conn = conn_internal_server_error(verb, path, ex, stackframes) # 500
        end
    end
end
