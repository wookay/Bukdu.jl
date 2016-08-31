# module Bukdu.Plug

import ..Bukdu

type Logger
end

function plug(::Type{Plug.Logger}; kw...)
    # level::Union{Symbol,Bool}
    opts = Dict(kw)
    level = haskey(opts, :level) ? opts[:level] : :info
    Bukdu.Logger.set_level(level)
end
