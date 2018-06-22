# module Bukdu.Plug

import ..Bukdu

struct WebSocket <: AbstractPlug
end

"""
    plug(::Type{WebSocket})
"""
function plug(::Type{WebSocket})
    Bukdu.env[:check_websocket] = true
end

# module Bukdu.Plug
