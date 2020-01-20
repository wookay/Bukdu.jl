using Bukdu # ApplicationController Conn pipeline routes get
using HTTP.Messages: setheader

struct RESTController <: ApplicationController
    conn::Conn
end

function index(c::RESTController)
    @info c.conn.request.response.headers
    render(JSON, 42)
end

pipeline(:cors) do conn::Conn
    setheader(conn.request.response, "Access-Control-Allow-Origin" => "*")
end

routes(:cors) do
    get("/", RESTController, index)
end

Bukdu.start(8080)
