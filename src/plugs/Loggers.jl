module Loggers # Bukdu.Plug

"""
    Plug.Loggers.config

Logging options for System info and error messages.
 - `:controller_pad`
 - `:action_pad`
 - `:path_pad`
 - `:error_stackframes_range`
"""
config = Dict{Symbol, Any}(
    :controller_pad => 20,
    :action_pad => 16,
    :path_pad => 28,
    :error_stackframes_range => :,
)

using ..Deps: Deps
using ..Plug: Conn
using ...Bukdu: RouteAction
using Logging: AbstractLogger

struct DefaultLogger <: AbstractLogger
    stream
    DefaultLogger() = new(IOContext(Core.stdout, :color => have_color()))
end

struct NullLogger <: AbstractLogger
    stream
    NullLogger() = new(IOContext(Core.stdout, :color => have_color()))
end

@generated have_color() = :(2 != Base.JLOptions().color)

current = Dict{Symbol, Union{<:AbstractLogger}}(:logger => NullLogger())

const style_request_action_others  = :red
const style_request_action = Dict{String,Symbol}(
    "GET"     => :normal,
    "POST"    => :yellow,
    "DELETE"  => :magenta,
    "PATCH"   => :light_green,
    "PUT"     => :green,
    "HEAD"    => :light_cyan,
    "OPTIONS" => :cyan,
    "TRACE"   => :light_cyan,
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

function _unescape_request_target(target)
    str = target
    try
        str = Deps.HTTP.URIs.unescapeuri(target)
    catch
    end
    _regularize_text(str, config[:path_pad])
end


function default_print_message(io::IO, args...; kwargs...)
    Base.println(io, args...; kwargs...)
end

function default_print_internal_error(io::IO, name::Symbol, err)
    Base.printstyled(io, name, color=:red)
    r = config[:error_stackframes_range]
    stackframes = err.stackframes[r]
    Base.println(io, " ", err.exception, "\n    ", join(stackframes, "\n    "))
end

function default_info_response(io::IO, conn::Conn, route::RouteAction)
    controller_name = route.controller === nothing ? "" : String(nameof(route.controller))
    action_name = route.action === nothing ? "" : String(nameof(route.action))
    Base.printstyled(io, "INFO:", color=:cyan)
    Base.printstyled(io, ' ')
    Base.printstyled(io, rpad(conn.request.method, 7); req_method_style(conn.request.method)...)
    Base.printstyled(io, ' ')
    controller_color = Sys.iswindows() ? :normal : 248
    if endswith(controller_name, "Controller")
        Base.printstyled(io, controller_name[1:end-10])
        pad_length = config[:controller_pad] - length(controller_name)
        if pad_length > 0
            Base.printstyled(io, "Controller", color=controller_color)
            Base.printstyled(io, repeat(' ', pad_length))
        elseif pad_length < -10
        else
            Base.printstyled(io, "Controller"[1:10+pad_length-1], color=controller_color)
            Base.printstyled(io, ' ')
        end
    else
        Base.printstyled(io, rpad(controller_name, config[:controller_pad]))
    end
    if length(action_name) > config[:action_pad]
        Base.printstyled(io, action_name[1:config[:action_pad]-1], ' ')
    else
        Base.printstyled(io, rpad(action_name, config[:action_pad]))
    end
    Base.printstyled(io, conn.request.response.status; resp_status_style(conn.request.response.status)...)
    Base.printstyled(io, ' ', _unescape_request_target(conn.request.target))
    Base.println(io)
end


function print_message(logger::DefaultLogger, args...; kwargs...)
    io = logger.stream
    default_print_message(io, args...; kwargs...)
end

function print_internal_error(logger::DefaultLogger, name::Symbol, err)
    io = logger.stream
    default_print_internal_error(io, name, err)
end

function info_response(logger::DefaultLogger, conn::Conn, route::RouteAction)
    io = logger.stream
    default_info_response(io, conn, route)
end


function info_response(logger::NullLogger, conn::Conn, route::RouteAction)
end


function print_message(::T, args...; kwargs...) where {T <: AbstractLogger}
    io = IOContext(Core.stdout, :color => have_color())
    default_print_message(io, args...; kwargs...)
end

function print_internal_error(::T, name::Symbol, err) where {T <: AbstractLogger}
    io = IOContext(Core.stdout, :color => have_color())
    default_print_internal_error(io, name, err)
end

function info_response(::T, conn::Conn, route::RouteAction) where {T <: AbstractLogger}
    io = IOContext(Core.stdout, :color => have_color())
    default_info_response(io, conn, route)
end


function print_message(args...; kwargs...)
    logger = current[:logger]
    print_message(logger, args...; kwargs...)
end

function print_internal_error(name::Symbol, err)
    logger = current[:logger]
    print_internal_error(logger, name, err)
end

function info_response(conn::Conn, route::RouteAction)
    logger = current[:logger]
    info_response(logger, conn, route)
end

end # module Bukdu.Plug.Loggers

"""
    plug(::Type{T}, args...; kwargs...) where {T <: AbstractLogger}
"""
function plug(::Type{T}, args...; kwargs...) where {T <: AbstractLogger}
    Loggers.current[:logger] = T(args...; kwargs...)
end

# module Bukdu.Plug
