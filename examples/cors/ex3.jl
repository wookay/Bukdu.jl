using Bukdu # Plug ApplicationController Conn plug pipeline routes get
using HTTP.Messages: setheader

struct CORS <: Plug.AbstractPlug
end

function plug(::Type{CORS}, conn::Conn, origin::String)
    setheader(conn.request.response, "Access-Control-Allow-Origin" => origin)
end


struct RESTController <: ApplicationController
    conn::Conn
end

function index(c::RESTController)
    @info c.conn.request.response.headers
    render(JSON, 42)
end

pipeline(:rest) do conn::Conn
    plug(CORS, conn, "*")
end

routes(:rest) do
    get("/", RESTController, index)
end

Bukdu.start(8080)
