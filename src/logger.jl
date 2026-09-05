# module Bukdu

using Base: CoreLogging as Logging

function log_info(f, io::IO)
    if Logging._min_enabled_level[] < Logging.Info.level
        printstyled(io, "[ Info:"; color = :cyan, bold = true)
        print(io, " ")
        f(io)
    end
end

# module Bukdu
