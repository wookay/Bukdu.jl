using Bukdu
using JSON2

struct RESTController <: ApplicationController
    conn::Conn
end

function create(c::RESTController)
    m = JSON2.read(String(c.conn.request.body))
    @info :message m.message
    render(JSON, "OK")
end

routes() do
    post("/messages", RESTController, create)
end

Bukdu.start(8080)

# curl -H "Content-Type: application/json" http://127.0.0.1:8080/messages -d '{"message":"Hello Data"}'
