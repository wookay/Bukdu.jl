include("layout.jl")                    # layout
include(joinpath("api", "endpoint.jl")) # Endpoint
include("wasm.jl")                      # WASM
include("front.jl")                     # Front



if PROGRAM_FILE == basename(@__FILE__)

using Bukdu
import Bukdu.Actions: index, show, new, edit, create, delete, update
using .Front # WelcomeController
using .Endpoint # CustomerController
import .WASM: WasmController, hello_js, hello_wast
using Sockets

pipeline(:api) do conn::Conn
    # plug(Plug.Accepts, conn, ["json"])
end

routes(:api) do
    resources("/customers", CustomerController)
end

routes(:wasm) do
    get("/wasm", WasmController, index)
    get("/hello.js", WasmController, hello_js)
    get("/hello.wast", WasmController, hello_wast)
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "public"))
end

routes(:front) do
    get("/", WelcomeController, index)
end

if haskey(ENV, "ON_HEROKU")
    Bukdu.start(parse(Int, ENV["PORT"]); host=Sockets.IPAddr(0,0,0,0))
else
    Bukdu.start(8080)
end

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
