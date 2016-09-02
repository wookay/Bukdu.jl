importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "Hello Bukdu"

Router() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)

wait()

# Bukdu.stop()
