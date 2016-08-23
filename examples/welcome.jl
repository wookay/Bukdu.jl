importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello bukdu"

Router() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)

wait()

# Bukdu.stop()
