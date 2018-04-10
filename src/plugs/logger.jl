# module Bukdu.Plug

import Base: CoreLogging
import .CoreLogging: AbstractLogger, global_logger, handle_message, min_enabled_level
import .CoreLogging: LogLevel, Debug, Info, Warn, Error

include("repr.jl") # simple_repr

"""
    Plug.LoggerFormatter
"""
module LoggerFormatter # Bukdu.Plug

import Dates: now, format

"""
    Plug.LoggerFormatter.basic_message(io)
"""
function basic_message(io)
end

"""
    Plug.LoggerFormatter.datetime_message(io)
"""
function datetime_message(io)
    datetime = format(now(), "yyyy-mm-ddTHH:MM:SS.sss")
    printstyled(io, ' ', datetime, color=:normal)
end

end # module Bukdu.Plug.LoggerFormatter

"""
    Plug.Logger
"""
struct Logger <: AbstractLogger
    stream::IO
    min_level::LogLevel
    message_limits::Dict{Any,Int}
    formatter
end
function Logger(; access_log::Union{Nothing,<:NamedTuple}=nothing, stream::IO=stderr, level=Debug, message_limits=Dict{Any,Int}(), formatter=LoggerFormatter.basic_message)
    if access_log isa Nothing
        Logger(stream, level, message_limits, formatter)
    else
        io = open(access_log.path, "a")
        Logger(io, level, message_limits, formatter)
    end
end

min_enabled_level(logger::Logger) = logger.min_level

CoreLogging.shouldlog(::Logger, ::LogLevel, ::Module, ::Symbol, ::Symbol) = true

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
    printstyled(iob, ' ', msglines, color=color)
    for (key, val) in pairs(kwargs)
        printstyled(iob, "   ", simple_repr(val))
    end
    print(iob, '\n')
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
    nothing
end

"""
    plug(::Type{Logger}; access_log::Union{Nothing,<:NamedTuple}=nothing, formatter=nothing)
"""
function plug(::Type{Logger}; access_log::Union{Nothing,<:NamedTuple}=nothing,
                              formatter=nothing)
    if !(access_log isa Nothing)
        logger_formatter = formatter isa Nothing ? LoggerFormatter.basic_message : formatter
        global_logger(Logger(access_log=access_log, formatter=logger_formatter))
    elseif !(formatter isa Nothing)
        global_logger(Logger(formatter=formatter))
    end
end

# module Bukdu.Plug
