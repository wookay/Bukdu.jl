module test_bukdu_logging

using Test
import Bukdu: Plug
import .Plug: handle_message
import Base.CoreLogging: Debug, Info, Warn, Error

logger = Plug.Logger()
@test logger.min_level == Debug

_module = nothing
group = nothing
id = nothing
filepath = nothing
line = nothing
handle_message(logger, Debug, "d", _module, group, id, filepath, line)
handle_message(logger, Info,  "i", _module, group, id, filepath, line)
handle_message(logger, Warn,  "w", _module, group, id, filepath, line)
handle_message(logger, Error, "e", _module, group, id, filepath, line)

end # module test_bukdu_logging
