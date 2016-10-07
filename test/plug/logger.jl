importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end

Endpoint() do
    plug(Plug.Logger)
    plug(Router)
end


using Base.Test
@test Bukdu.Logger.level_debug == Bukdu.Logger.settings[:level]

Logger.have_color(false)

let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(get, "/")
@test_throws Bukdu.NoRouteError (Router)(get, "/strange")
@test_throws Bukdu.NoRouteError (Endpoint)("/strange")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

str = wait(reader)
@test """
DEBUG  GET /                                   index(::WelcomeController)
WARN   GET /strange                           
WARN       /strange                           
""" == str
end
