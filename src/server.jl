# module Bukdu

const bukdu_server = Ref{HT.Server}()
const bukdu_router = Ref{HT.Router}()

struct Middleware <: HT.Middleware
end

function (::Middleware)(tup::Tuple)
    (C, action) = tup
    req -> begin
        conn = Conn(req)
        c = C(conn)
        action(c)
    end
end

"""
    Bukdu.start(port::Integer; host::String="localhost", listenany::Bool = false)

start the Bukdu server.
"""
function start(port::Integer; host::String="localhost", listenany::Bool = false)
    if isassigned(bukdu_router)
        bukdu_server[] = HT.serve!(bukdu_router[], host, port; listenany)
    else
    end
end

"""
    Bukdu.stop()

stop the Bukdu server.
"""
function stop()
    isassigned(bukdu_server) && HT.forceclose(bukdu_server[])
    nothing
end

# module Bukdu
