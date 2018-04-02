# module Bukdu

import Base.CoreLogging: AbstractLogger, global_logger, handle_message, min_enabled_level
import Base.CoreLogging: LogLevel, Debug, Info, Warn, Error

struct BukduLogger <: AbstractLogger
    stream::IO
    min_level::LogLevel
    message_limits::Dict{Any,Int}
end
BukduLogger(stream::IO=stderr, level=Debug) = BukduLogger(stream, level, Dict{Any,Int}())

min_enabled_level(logger::BukduLogger) = logger.min_level


# code from julia/base/logging.jl
function handle_message(logger::BukduLogger, level, message, _module, group, id,
                        filepath, line; maxlog=nothing, kwargs...)
    if maxlog != nothing && maxlog isa Integer
        remaining = get!(logger.message_limits, id, maxlog)
        logger.message_limits[id] = remaining - 1
        remaining > 0 || return
    end
    buf = IOBuffer()
    iob = IOContext(buf, logger.stream)
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
    printstyled(iob, levelstr, ": ", msglines, color=color)
    for (key, val) in pairs(kwargs)
        printstyled(iob, "   ", simple_repr(val))
    end
    print(iob, '\n')
    print(logger.stream, String(take!(buf)))
    flush(logger.stream)
    nothing
end

# module Bukdu
