using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    render(JSON, "Hello World")
end



if PROGRAM_FILE == basename(@__FILE__)

routes() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)

(Router)(get, "/")

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
