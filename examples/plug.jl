using Bukdu # ApplicationController Conn pipeline plug routes get Router

struct PlugController <: ApplicationController
    conn::Conn
end

function index(::PlugController)
    "ok"
end


if PROGRAM_FILE == basename(@__FILE__)

pipeline(:web) do conn::Conn
    plug(Plug.CSRF.Protection, conn)
end

routes(:web) do
    get("/", PlugController, index)
end

Bukdu.start(8080)

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
