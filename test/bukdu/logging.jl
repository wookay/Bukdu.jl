module test_bukdu_logging

using Test
using Bukdu.Plug
using .Plug: LoggerFormatter, handle_message
using Base.CoreLogging: Debug, Info, Warn, Error

logger = Plug.Logger(access_log=nothing, formatter=LoggerFormatter.basic_message)
@test logger.min_level === Debug

_module = nothing
group = nothing
id = nothing
filepath = nothing
line = nothing
handle_message(logger, Debug, "d", _module, group, id, filepath, line)
handle_message(logger, Info,  "i", _module, group, id, filepath, line)
handle_message(logger, Warn,  "w", _module, group, id, filepath, line)
handle_message(logger, Error, "e", _module, group, id, filepath, line)


using Bukdu # plug
access_log_path = normpath(@__DIR__, "access.log")
rm(access_log_path, force=true)

plug(Plug.Logger, access_log=(path=access_log_path,), formatter=Plug.LoggerFormatter.datetime_message)
@info "write a message to access log file"
@test endswith(read(access_log_path, String), "access log file\n")

plug(Plug.Logger, access_log=nothing)

@info nothing nothing

end # module test_bukdu_logging
