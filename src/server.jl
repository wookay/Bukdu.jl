# module Bukdu

using HTTP # HTTP.Servers HTTP.handle
using Sockets # @ip_str

function start(port)
    r = env[:router]
    server = HTTP.Servers.Server(stdout) do req
        HTTP.handle(r, req)
    end
    env[:server] = server
    @async HTTP.Servers.serve(
                server,
                ip"127.0.0.1",
                port,
                false) # verbose
end

function stop()
    server = env[:server]
    env[:server] = nothing
    server isa HTTP.Servers.Server && put!(server.in, HTTP.Servers.KILL)
end
