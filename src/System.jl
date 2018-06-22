module System # Bukdu

import ..Bukdu: ApplicationController, Conn, Route, Deps, Plug, render
import Documenter.Utilities.DOM: @tags

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
    @error Symbol(:System_, :internal_error) c.err.exception string("\n    ", join(c.err.stackframes, "\n    "))
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

# info

const controller_rpad  = 20
const action_rpad      = 16
const target_path_rpad = 28

function _regularize_text(str::String, padding::Int)::String
    s = escape_string(str)
    if textwidth(s) < padding
        padded_str = rpad(s, padding)
        if textwidth(padded_str) > padding
        else
            return s
        end
    end
    n = 0
    a = []
    for (idx, x) in enumerate(s)
        n += textwidth(x)
        push!(a, x)
        if n > padding - 1
            break
        end
    end
    newstr = join(a)
    newdiff = textwidth(s) - textwidth(newstr)
    if length(s) == length(a)
        news = newstr
        npad = padding - textwidth(newstr)
    else
        if newdiff > 0 && length(a) >= 2
            newstr = join(a[1:end-2])
            newpad = padding - textwidth(newstr)
            news = string(newstr, fill('.', newpad)...)
        else
            news = newstr
        end
        npad = padding - textwidth(news)
    end
    news
end

function _unescape_req_target(req)
    str = req.target
    try
        str = Deps.HTTP.URIs.unescapeuri(req.target)
    catch
    end
    _regularize_text(str, target_path_rpad)
end

const style_request_action_others  = :red
const style_request_action = Dict{String,Symbol}(
    "GET"    => :normal,
    "POST"   => :yellow,
    "DELETE" => :magenta,
    "PATCH"  => :blue,
    "PUT"    => :cyan,
)

const style_response_status_others = :red
const style_response_status = Dict{Int,Symbol}(
    200 => :normal,     # 200 OK
    401 => :magenta,    # 401 Unauthorized
    404 => :light_blue, # 404 Not Found
    500 => :red,        # 500 Internal Server Error
)

function req_method_style(method::String)
    (color=get(style_request_action, method, style_request_action_others),)
end

function resp_status_style(status::Int16)
    (color=get(style_response_status, status, style_response_status_others),)
end

function info_response(route::Route, req, response)
    logger = Base.global_logger()
    buf = IOBuffer()
    iocontext = IOContext(buf, logger.stream)
    iob = IOContext(iocontext, :color => true)
    printstyled(iob, "INFO:", color=:cyan)
    logger isa Plug.Logger && logger.formatter(iob)
    printstyled(iob, ' ')
    printstyled(iob, rpad(req.method, 6); req_method_style(req.method)...)
    printstyled(iob, ' ')
    controller_name = String(nameof(route.C))
    if endswith(controller_name, "Controller")
        printstyled(iob, controller_name[1:end-10])
        printstyled(iob, rpad("Controller", controller_rpad-(length(controller_name)-10)), color=248)
    else
        printstyled(iob, rpad(controller_name, controller_rpad))
    end
    printstyled(iob, rpad(nameof(route.action), action_rpad))
    printstyled(iob, response.status; resp_status_style(response.status)...)
    printstyled(iob, ' ', _unescape_req_target(req))
    println(iob)
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
end

"""
    Bukdu.System.catch_request(route::Bukdu.Route, req)
"""
function catch_request
end

"""
    Bukdu.System.catch_response(route::Bukdu.Route, resp)
"""
function catch_response
end

end # module Bukdu.System


function Bukdu.System.catch_request(route::Bukdu.Route, req)
#    @debug "REQ " req.headers
end

function Bukdu.System.catch_response(route::Bukdu.Route, resp)
#    @debug "RESP" resp.headers resp.status
end
