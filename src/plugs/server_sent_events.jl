# module Bukdu.Plug

import ..Bukdu

struct ServerSentEvents <: AbstractPlug
end

"""
    plug(::Type{ServerSentEvents})
"""
function plug(::Type{ServerSentEvents})
    Bukdu.env[:check_server_sent_events] = true
end

# module Bukdu.Plug
