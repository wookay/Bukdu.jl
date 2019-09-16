module Hello

using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(::WelcomeController)
    render(Text, "hello")
end

routes() do
    get("/", WelcomeController, index)
end

function start_server()
    port = 8080
    Bukdu.start(port)
end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    start_server()
    wait()
    return 0
end

end
