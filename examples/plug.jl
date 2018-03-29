using Bukdu

struct PlugController <: ApplicationController
    conn::Conn
end

function index(::PlugController)
    "ok"
end


if PROGRAM_FILE == basename(@__FILE__)

pipeline(:auth) do conn::Conn
    # plug(Plug.Auth, conn)
end

routes(:auth) do
    get("/", PlugController, index)
end

Bukdu.start(8080)

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
