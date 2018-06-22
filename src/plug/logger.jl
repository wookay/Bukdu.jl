# module Bukdu.Plug

"""
plug `Plug.Logger` to write the event logs.

```julia
Endpoint() do
    plug(Plug.Logger, level= :info)
end
```
"""
function plug(::Type{Val{:Logger}}; kw...)
    # level::Union{Symbol,Bool}
    opts = Dict(kw)
    level = haskey(opts, :level) ? opts[:level] : :debug
    Logger.set_level(level)
end
