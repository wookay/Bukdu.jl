# https://discourse.julialang.org/t/switch-from-httpserver-jl-to-http-jl/19717

# Bukdu v0.4.4
using Bukdu
using HTTP.Messages: setheader

struct SimulationController <: ApplicationController
    conn::Conn
end

function take_options(c::SimulationController)
    req = c.conn.request
    @info :req_headers req.headers
    @info :req_method_target (req.method, req.target)
    # setheader(req.response, "Access-Control-Allow-Origin" => "*")
    setheader(req.response, "Content-Length" => "0")
    nothing
end

function run_simulation(json)
    @info :json json
    # work
end

function run_simulation(c::SimulationController)
    json = c.params.json
    output = run_simulation(json)
    render(asJSON, output)
end

routes() do
    Bukdu.options("/", SimulationController, take_options)
    Bukdu.options("/run", SimulationController, take_options)
    post("/run", SimulationController, run_simulation)
    plug(Plug.Parsers, json=Plug.ContentParsers.JSONDecoder)
end

Bukdu.start(8080)

#=
curl -i -X OPTIONS http://localhost:8080/
curl -i -X OPTIONS http://localhost:8080/run
curl -i -H "Content-Type: application/json" -d '{"message": "Hello Data"}' http://127.0.0.1:8080/run
=#
