# https://discourse.julialang.org/t/write-a-rest-interface-like-flask/18538/16

# Bukdu v0.4.4
using Bukdu

struct RESTController <: ApplicationController
    conn::Conn
end

function create(c::RESTController)
    @info :payload (c.params.message, c.params.x, c.params.y)
    render(JSON, "OK")
end

routes() do
    post("/messages", RESTController, create)
    plug(Plug.Parsers, [:json])
end

Bukdu.start(8080)

#=
curl -H "Content-Type: application/json" http://127.0.0.1:8080/messages -d '{"message": "Hello Data"}'
curl -H "Content-Type: application/json" http://127.0.0.1:8080/messages -d '{"x": 1.2, "y": 2.3}'

On Windows:
- `"` needs to be escaped either by `\"` or `"""`
- initial `'` needs to be replaces with `"`
curl -H "Content-Type: application/json" http://127.0.0.1:8080/messages -d "{\"message\": \"Hello Data\"}"
curl -H "Content-Type: application/json" http://127.0.0.1:8080/messages -d "{"""x""": 1.2, """y""": 2.3}"
For more information, see: https://stackoverflow.com/questions/7172784/how-do-i-post-json-data-with-curl
=#
