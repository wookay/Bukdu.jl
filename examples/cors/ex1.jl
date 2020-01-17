using Bukdu # ApplicationController Conn routes get
using HTTP.Messages: setheader

struct RESTController <: ApplicationController
    conn::Conn
end

function index(c::RESTController)
    setheader(c.conn.request.response, "Access-Control-Allow-Origin" => "*")
    render(asJSON, 42)
end

routes() do
    get("/", RESTController, index)
end

Bukdu.start(8080)
