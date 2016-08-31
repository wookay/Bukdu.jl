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

let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(index, "/")
conn = (Router)(index, "/strange")
conn = (Endpoint)("/strange")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test "\e[1m\e[32mINFO\e[0m GET / WelcomeController.index\n\e[1m\e[32mINFO\e[0m | /strange\n\e[1m\e[32mINFO\e[0m | /strange\n" == wait(reader)
end
