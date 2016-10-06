importall Bukdu

type WelcomeController <: ApplicationController
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


using Base.Test

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
