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
@test Bukdu.Logger.level_info == Bukdu.Logger.settings[:level]

Logger.have_color(false)

let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(get, "/")
@test_throws NoRouteError (Router)(get, "/strange")
@test_throws NoRouteError (Endpoint)("/strange")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test "WARN  GET /strange\nWARN  | /strange\n" == wait(reader)
end
