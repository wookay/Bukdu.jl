module test_logger

importall Bukdu
import Base.Test: @test, @test_throws

struct WelcomeController <: ApplicationController
end

function index(::WelcomeController)
    Logger.info("hi")
    "hello"
end

Router() do
    get("/", WelcomeController, index)
end

Endpoint() do
    plug(Plug.Logger, level=:debug)
    plug(Router)
end


Logger.have_color(false)
let oldout = STDERR
    rdout, wrout = redirect_stdout()

    conn = (Router)(get, "/")

    reader = @async readstring(rdout)
    redirect_stdout(oldout)
    close(wrout)

    lines = split(wait(reader), '\n')
    @test startswith(lines[1], "DEBUG  GET /")
    @test lines[2] == "INFO  hi"
end

end # module test_logger
