importall Bukdu

type VueController <: ApplicationController
end

index(::VueController) = "Hello Bukdu"

Router() do
    get("/", VueController, index)
end

Endpoint() do
    plug(Plug.Logger)
    plug(Plug.Static, at= "/", from= "public")
    plug(Router)
end

Bukdu.start(8080)

# wait()

# Bukdu.stop()
