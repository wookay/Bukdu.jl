include("layout.jl")                    # layout
include(joinpath("api", "endpoint.jl")) # Endpoint
include("wasm.jl")                      # WASM
include("front.jl")                     # Front



if PROGRAM_FILE == basename(@__FILE__)

using Bukdu # pipeline Conn routes resources get plug Router
import .Bukdu.Actions: index, show, new, edit, create, delete, update
using .Front # WelcomeController
using .Endpoint # CustomerController
using .WASM: WasmController, hello_js, hello_wast
using Sockets

pipeline(:api) do conn::Conn
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

Bukdu.start(Front.server.port; host=Front.server.host)

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
