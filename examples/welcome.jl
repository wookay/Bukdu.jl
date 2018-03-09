using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    "hello $(c.params.a)"
end

Router() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)

#Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
