# module Bukdu

const bukdu_server = Ref{HT.Server}()
const bukdu_router = Ref{HT.Router}()

struct Middleware <: HT.Middleware
end

struct AnonymousController <: ApplicationController
    conn::Conn
end

import Base: get

function get(path, ::Type{C}, f) where C <: ApplicationController
    HT.register!(bukdu_router[], "GET", path, (C, f))
end

function post(path, ::Type{C}, f) where C <: ApplicationController
    HT.register!(bukdu_router[], "POST", path, (C, f))
end

function post(f, path::String)
    action = c -> f(c.conn)
    HT.register!(bukdu_router[], "POST", path, (AnonymousController, action))
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

function (::Middleware)(tup::Tuple)
    (C, f) = tup
    req -> begin
        conn = Conn(req)
        c = C(conn)
        f(c)
    end
end

function routes(f)
    middleware = Middleware()
    bukdu_router[] = HT.Router(HT.Handlers.default404, HT.Handlers.default405, middleware)
    f()
end

# module Bukdu
