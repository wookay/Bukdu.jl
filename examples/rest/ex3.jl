# https://discourse.julialang.org/t/switch-from-httpserver-jl-to-http-jl/19717

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

function run_simulation(inputs_string::String)
    @info :inputs inputs_string
    # work
end

function run_simulation(c::SimulationController)
    inputs_string = String(c.conn.request.body)
    output = run_simulation(inputs_string)
    render(JSON, output)
end

routes() do
    Bukdu.options("/", SimulationController, take_options)
    Bukdu.options("/run", SimulationController, take_options)
    post("/run", SimulationController, run_simulation)
end

Bukdu.start(8080)

#=
curl -i -X OPTIONS http://localhost:8080/
curl -i -X OPTIONS http://localhost:8080/run
curl -i -H "Content-Type: text/plain" -d "data" http://localhost:8080/run
=#
