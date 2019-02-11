module System # Bukdu

using ..Bukdu: ApplicationController, Conn, Route, render
using ..Bukdu.Deps
using ..Bukdu.Plug
using Documenter.Utilities.DOM: @tags

"""
    Bukdu.System.config

Logging options for System info and error messages.
 - `:controller_pad`
 - `:action_pad`
 - `:path_pad`
 - `:error_stackframes_range`
"""
config = Dict{Symbol,Any}(
    :controller_pad => 20,
    :action_pad => 16,
    :path_pad => 28,
    :error_stackframes_range => :,
)

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
    stackframes = c.err.stackframes[config[:error_stackframes_range]]
    @error Symbol(:System_, :internal_error) c.err.exception string("\n    ", join(stackframes, "\n    "))
    render(HTML, string(
        h3(string(InternalError)),
        p(string(c.err.exception)),
        (p ∘ string).(stackframes)...
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
    _regularize_text(str, config[:path_pad])
end

const style_request_action_others  = :red
const style_request_action = Dict{String,Symbol}(
    "GET"     => :normal,
    "POST"    => :yellow,
    "DELETE"  => :magenta,
    "PATCH"   => :light_green,
    "PUT"     => :green,
    "HEAD"    => :light_cyan,
    "OPTIONS" => :cyan,
)

const style_response_status_others = :red
const style_response_status = Dict{Int,Symbol}(
    200 => :normal,       # 200 OK
    301 => :light_red,    # 301 Moved Permanently
    302 => :light_red,    # 302 Found
    401 => :magenta,      # 401 Unauthorized
    404 => :light_blue,   # 404 Not Found
    500 => :red,          # 500 Internal Server Error
    503 => :red,          # 503 Service Unavailable
)

function req_method_style(method::String)
    (color=get(style_request_action, method, style_request_action_others),)
end

function resp_status_style(status::Int16)
    (color=get(style_response_status, status, style_response_status_others),)
end

function info_response(controller_name, action_name, req, response)
    logger = Base.global_logger()
    buf = IOBuffer()
    iocontext = IOContext(buf, logger.stream)
    iob = IOContext(iocontext, :color => true)
    printstyled(iob, "INFO:", color=:cyan)
    logger isa Plug.Logger && logger.formatter(iob)
    printstyled(iob, ' ')
    printstyled(iob, rpad(req.method, 7); req_method_style(req.method)...)
    printstyled(iob, ' ')
    controller_color = Sys.iswindows() ? :normal : 248
    if endswith(controller_name, "Controller")
        printstyled(iob, controller_name[1:end-10])
        pad_length = config[:controller_pad] - length(controller_name)
        if pad_length > 0
            printstyled(iob, "Controller", color=controller_color)
            printstyled(iob, repeat(' ', pad_length))
        elseif pad_length < -10
        else
            printstyled(iob, "Controller"[1:10+pad_length-1], color=controller_color)
            printstyled(iob, ' ')
        end
    else
        printstyled(iob, rpad(controller_name, config[:controller_pad]))
    end
    printstyled(iob, rpad(action_name, config[:action_pad]))
    printstyled(iob, response.status; resp_status_style(response.status)...)
    printstyled(iob, ' ', _unescape_req_target(req))
    println(iob)
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
end

function info_response(route::Route, req, response)
    controller_name = String(nameof(route.C))
    action_name = String(nameof(route.action))
    info_response(controller_name, action_name, req, response)
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
