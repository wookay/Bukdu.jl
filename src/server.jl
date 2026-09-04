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
    Bukdu.start(port::Integer ;
                host::String = "127.0.0.1",
                listenany::Bool = false,
                reuseaddr::Bool = true)
start the Bukdu server.
"""
function start(port::Integer ;
               host::String = "127.0.0.1",
               listenany::Bool = false,
               reuseaddr::Bool = true)
    if isassigned(bukdu_router)
        bukdu_server[] = HT.serve!(bukdu_router[], host, port; listenany, reuseaddr)
        io = stdout
        print(io, "Bukdu Listening on: ")
        printstyled(io, bukdu_server[].bound_address; color = :cyan)
        println(io)
    else
    end
end

"""
    Bukdu.stop()

stop the Bukdu server.
"""
function stop()
    if isassigned(bukdu_server)
        HT.close(bukdu_server[])
        io = stdout
        println(io, "Bukdu has stopped.")
    end
    nothing
end

# module Bukdu
