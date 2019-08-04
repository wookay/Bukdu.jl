module Plug # module Bukdu

using ..Deps
using ..Bukdu: Assoc, AbstractPlug, ApplicationController, AbstractRender, Render

function plug
end

using Logging: AbstractLogger
include("plugs/Loggers.jl")

include("plugs/conn.jl")

include("plugs/ContentParsers.jl")
include("plugs/parsers.jl")

include("plugs/static.jl")

end # module Bukdu.Plug

export Plug, Conn, ApplicationController, Render, plug

using .Plug: Conn, ApplicationController, AbstractPlug, AbstractRender, Render
import .Plug: plug

# module Bukdu
