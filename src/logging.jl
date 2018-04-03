# module Bukdu

import Base.CoreLogging: AbstractLogger, global_logger, handle_message, min_enabled_level
import Base.CoreLogging: LogLevel, Debug, Info, Warn, Error

struct Logger <: AbstractLogger
    stream::IO
    min_level::LogLevel
    message_limits::Dict{Any,Int}
end
function Logger(; access_log::Union{Nothing,<:NamedTuple}=nothing, stream::IO=stderr, level=Debug, message_limits=Dict{Any,Int}())
    if access_log isa Nothing
        Logger(stream, level, message_limits)
    else
        io = open(access_log.path, "a")
        Logger(io, level, message_limits)
    end
end

min_enabled_level(logger::Bukdu.Logger) = logger.min_level


# code from julia/base/logging.jl
function handle_message(logger::Bukdu.Logger, level, message, _module, group, id,
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
    printstyled(IOContext(iob, :color => true), levelstr, ": ", msglines, color=color)
    for (key, val) in pairs(kwargs)
        printstyled(iob, "   ", simple_repr(val))
    end
    print(iob, '\n')
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
    nothing
end

# module Bukdu
