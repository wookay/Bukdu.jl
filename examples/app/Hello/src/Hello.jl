module Hello

using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(::WelcomeController)
    render(Text, "hello")
end

function __init__()
    routes() do
        get("/", WelcomeController, index)
    end
end

function julia_main()::Cint
    try
        port = isempty(ARGS) ? 8080 : parse(Int, ARGS[1])
        Bukdu.start(port)
        wait()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
end

end
