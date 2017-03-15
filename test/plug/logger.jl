module test_plug_logger

importall Bukdu
import Bukdu: NoRouteError
import Base.Test: @test, @test_throws

struct WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end

Endpoint() do
    plug(Plug.Logger)
    plug(Router)
end


@test Bukdu.Logger.level_debug == Bukdu.Logger.settings[:level]

Logger.have_color(false)

let oldout = STDERR
    rdout, wrout = redirect_stdout()

    conn = (Router)(get, "/")
    @test_throws NoRouteError (Router)(get, "/strange")
    @test_throws NoRouteError (Endpoint)("/strange")

    reader = @async readstring(rdout)
    redirect_stdout(oldout)
    close(wrout)

    str = wait(reader)
@test """
DEBUG  GET /                                   index(::WelcomeController)
WARN   GET /strange                            NoRouteError("not found /strange")
WARN   GET /strange                            NoRouteError("not found /strange")
""" == str
end

end # module test_plug_logger
