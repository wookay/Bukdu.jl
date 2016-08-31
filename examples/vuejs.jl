importall Bukdu

type VueController <: ApplicationController
end

index(::VueController) = "hello bukdu"

Router() do
    get("/", VueController, index)
end

Endpoint() do
    plug(Plug.Static, at= "/", from= "public")
    plug(Plug.Logger)
    plug(Router)
end

Bukdu.start(8080)

wait()

# Bukdu.stop()
