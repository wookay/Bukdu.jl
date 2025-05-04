module System # Bukdu

using ..Bukdu: ApplicationController, Conn, Route, render
using ..Bukdu.Deps
using ..Bukdu.Plug
using Documenter.DOM: @tags

struct HaltedError <: Exception
    msg
end

struct NotApplicableError <: Exception
    msg
end

struct InternalError <: Exception
    exception
    stackframes
end

struct SystemController <: ApplicationController
    conn::Conn
    err
end

struct MissingController <: ApplicationController
    conn::Conn
end

struct AnonymousController <: ApplicationController
    conn::Conn
end

"""
    halted_error(c::SystemController)
"""
function halted_error(c::SystemController)
    @tags h3 p
    # set the status code when halted on Plug
    render(HTML, string(
        h3(string(HaltedError)),
        p(string(c.err.msg)),
    ))
end

"""
    not_applicable(c::SystemController)
"""
function not_applicable(c::SystemController)
    @tags h3 p
    c.conn.request.response.status = 500 # 500 Internal Server Error
    render(HTML, string(
        h3(string(NotApplicableError)),
        p(string(c.err.msg)),
    ))
end

"""
    internal_error(c::SystemController)
"""
function internal_error(c::SystemController)
    @tags h3 p
    c.conn.request.response.status = 500 # 500 Internal Server Error
    Plug.Loggers.print_internal_error(Symbol(:System_, :internal_error), c.err)
    render(HTML, string(
        h3(string(InternalError)),
        p(string(c.err.exception)),
        (p ∘ string).(c.err.stackframes)...
    ))
end


"""
    not_found(c::MissingController)
"""
function not_found(c::MissingController)
    @tags h3
    c.conn.request.response.status = 404 # 404 Not Found
    render(HTML, string(
        h3("Not Found"),
    ))
end

"""
    Bukdu.System.catch_request(route::Bukdu.Route, conn)
"""
function catch_request
end

"""
    Bukdu.System.catch_response(route::Bukdu.Route, conn)
"""
function catch_response
end

end # module Bukdu.System


function Bukdu.System.catch_request(route::Bukdu.Route, conn)
#    @debug "REQ " conn.request.headers
end

function Bukdu.System.catch_response(route::Bukdu.Route, conn)
#    @debug "RESP" conn.request.response.headers resp.status
end
