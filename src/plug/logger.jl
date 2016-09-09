# module Bukdu.Plug

import ..Bukdu

export Logger

immutable Logger
end

function plug(::Type{Plug.Logger}; kw...)
    # level::Union{Symbol,Bool}
    opts = Dict(kw)
    level = haskey(opts, :level) ? opts[:level] : :debug
    Bukdu.Logger.set_level(level)
end
