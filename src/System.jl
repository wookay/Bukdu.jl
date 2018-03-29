module System # Bukdu

import ..Bukdu: ApplicationController, Conn, Route, Deps, render
import Documenter.Utilities.DOM: @tags

struct HaltedError <: Exception
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

function internal_error(c::SystemController)
    @tags h3 p pre
    c.conn.request.response.status = 500 # 500 Internal Server Error
    render(HTML, string(
        h3(string(InternalError)),
        p(string(c.err.exception)),
        (p ∘ string).(c.err.stackframes)...
    ))
end

function halted_error(c::SystemController)
    @tags h3 p
    # set the status code when halted on Plug
    render(HTML, string(
        h3(string(HaltedError)),
        p(string(c.err.msg)),
    ))
end

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
        if n > padding - 2
            break
        end
        push!(a, x)
    end
    newstr = join(a)
    newpad = padding - textwidth(newstr)
    if newpad >= 2
        news = string(newstr, "..")
    elseif newpad == 1
        news = string(newstr, ".")
    else
        news = newstr
    end
    npad = padding - textwidth(news)
    rstrip(string(news, npad > 0 ? join(fill(' ', npad)) : ""))
end

function _unescape_req_target(req)
    str = req.target
    try
        str = Deps.HTTP.URIs.unescapeuri(req.target)
    catch
    end
    _regularize_text(str, target_path_rpad)
end

function req_method_color(method::String)
    bold = false
    if "POST" == method
        color = :yellow
    else
        color = :cyan
    end
    (bold=bold, color=color)
end

function info_response(route::Route, req, response)
    logger = Base.global_logger()
    buf = IOBuffer()
    iob = IOContext(buf, logger.stream)
    printstyled(iob, "INFO:  ", color=:cyan)
    printstyled(iob, rpad(req.method, 6); req_method_color(req.method)...)
    printstyled(iob, string(' ',
                            rpad(nameof(route.C), controller_rpad),
                            rpad(nameof(route.action), action_rpad)
    ))
    printstyled(iob, response.status, color= 200 == response.status ? :normal : :red)
    printstyled(iob, ' ', _unescape_req_target(req))
    println(iob)
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
end


end # module Bukdu.System
