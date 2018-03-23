# using Pkg
# try
#     Pkg.installed("Revise") && using Revise
# end


using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    "q" => c.params.q
    # render(JSON, "q" => c.params.q)
end

Router() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)

#Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
