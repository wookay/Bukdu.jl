# module Bukdu.Plug

using Base.CoreLogging
using .CoreLogging: AbstractLogger, LogLevel, Debug, Info, Warn, Error, global_logger
import .CoreLogging: handle_message, min_enabled_level, shouldlog

include("repr.jl") # simple_repr

"""
    Plug.LoggerFormatter
"""
module LoggerFormatter # Bukdu.Plug

using Dates: now, format

"""
    Plug.LoggerFormatter.basic_message(io)
"""
function basic_message(io)
end

"""
    Plug.LoggerFormatter.datetime_message(io)
"""
function datetime_message(io)
    dt = now()
    date = format(dt, "yyyy-mm-dd")
    time = format(dt, "HH:MM:SS.sss")
    printstyled(io, ' ', date, color=:normal)
    printstyled(io, 'T', color=:light_black)
    printstyled(io, time, color=:normal)
end

end # module Bukdu.Plug.LoggerFormatter

"""
    Plug.Logger
"""
struct Logger <: AbstractLogger
    stream::IO
    min_level::LogLevel
    message_limits::Dict{Any,Int}
    access_log
    formatter
end
function Logger(; access_log::Union{Nothing,<:NamedTuple}, formatter, stream::IO=stderr, level=Debug, message_limits=Dict{Any,Int}())
    if access_log isa Nothing
        Logger(stream, level, message_limits, access_log, formatter)
    else
        @info :access_log access_log.path
        io = open(access_log.path, "a")
        Logger(io, level, message_limits, access_log, formatter)
    end
end

min_enabled_level(logger::Logger) = logger.min_level
shouldlog(logger::Logger, level, _module, group, id) = get(logger.message_limits, id, 1) > 0

# code from julia/base/logging.jl
function handle_message(logger::Logger, level, message, _module, group, id,
                        filepath, line; maxlog=nothing, kwargs...)
    if maxlog != nothing && maxlog isa Integer
        remaining = get!(logger.message_limits, id, maxlog)
        logger.message_limits[id] = remaining - 1
        remaining > 0 || return
    end
    buf = IOBuffer()
    iocontext = IOContext(buf, logger.stream)
    iob = IOContext(iocontext, :color => true)
    levelstr = uppercase(string(level))
    msglines = message
    color = :normal
    if level == Info
        color = :cyan
    elseif level == Warn
        color = :yellow
    elseif level == Debug
        color = :magenta
    elseif level == Error
        color = :red
    end
    printstyled(iob, levelstr, ':', color=color)
    logger.formatter(iob)
    printstyled(iob, ' ')
    if msglines isa Union{Symbol,Nothing}
        printstyled(iob, repr(msglines), color=:cyan)
    else
        printstyled(iob, msglines)
    end
    if length(kwargs) == 1
        val = first(kwargs).second
        printstyled(iob, " ", simple_repr(val))
    else
        for (key, val) in pairs(kwargs)
            printstyled(iob, "   ", simple_repr(val))
        end
    end
    print(iob, '\n')
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
    nothing
end

"""
    plug(::Type{Logger}; access_log::Union{Nothing,<:NamedTuple}=nothing, formatter=LoggerFormatter.basic_message)
"""
function plug(::Type{Logger}; access_log::Union{Nothing,<:NamedTuple}=nothing, formatter=LoggerFormatter.basic_message)
    global_logger(Logger(access_log=access_log, formatter=formatter))
end

# module Bukdu.Plug
