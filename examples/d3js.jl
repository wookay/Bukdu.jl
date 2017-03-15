importall Bukdu

struct D3Controller <: ApplicationController
end

index(::D3Controller) = redirect_to("/d3js-index.html")

Router() do
    get("/", D3Controller, index)
end

Endpoint() do
    plug(Plug.Logger)
    plug(Plug.Static, at= "/", from= "public")
    plug(Router)
end

Bukdu.start(8080)

(Endpoint)("/")
Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
