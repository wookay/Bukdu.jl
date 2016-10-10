importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "Hello Bukdu"

Router() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)

Endpoint() do
    plug(Plug.Logger)
    plug(Router)
end

(Endpoint)("/")
Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
