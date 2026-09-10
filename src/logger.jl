# module Bukdu

module Logging # Bukdu
const Info = Base.CoreLogging.LogLevel(-2000)
end # module Bukdu.Logging


function log_info(f, io::IO)
    if Base.CoreLogging._min_enabled_level[] < Logging.Info.level
        printstyled(io, "INFO:"; color = :cyan, bold = false)
        print(io, " ")
        f(io)
    end
end

# module Bukdu
