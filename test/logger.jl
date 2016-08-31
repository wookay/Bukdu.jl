importall Bukdu

type WelcomeController <: ApplicationController
end

function plugins(c::WelcomeController)
    plug(Logger.log_message, c)
end

function index(::WelcomeController)
    Logger.debug("hi")
    "hello"
end

Router() do
    get("/", WelcomeController, index)
end

Endpoint() do
    plug(Plug.Logger)
    plug(Router)
end


using Base.Test

let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(index, "/")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test "\e[1m\e[32mINFO\e[0m GET / WelcomeController.index\n\e[1m\e[33mDEBUG\e[0m WelcomeController.index hi\n" == wait(reader)
end
