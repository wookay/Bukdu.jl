module WelcomeStuff

export WelcomeController

using Bukdu
import Bukdu.Actions: index
import Documenter.Utilities.DOM: @tags

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    @tags h3 div a

    render(HTML, div(
        a[:href => "/"]("Back"),
        h3("Welcome"),
        div(
            "Hello World"
        )
    ))
end

end # module WelcomeStuff



module CalculatorStuff

export Calculator

using Bukdu
import Bukdu.Actions: index
import Documenter.Utilities.DOM: @tags

struct Calculator <: ApplicationController
    conn::Conn
end

function index(c::Calculator)
    @tags h3 div a

    x = get(c.params, :x, 0)
    y = get(c.params, :y, 0)

    rand_x = rand(1:10)
    rand_y = rand(1:10)

    render(HTML, div(
        a[:href => "/"]("Back"),
        h3("Calculator"),
        div(
            string(x, +, y, '=', x+y),
        ),
        div(
            a[:href => "/calculator?x=$rand_x&y=$rand_y"]("/calculator?x=$rand_x&y=$rand_y")
        )
    ))
end

end # module CalculatorStuff



module MainStuff

export MainController

using Bukdu
import Bukdu.Actions: index
import Documenter.Utilities.DOM: @tags

struct MainController <: ApplicationController
    conn::Conn
end

function index(::MainController)
    @tags h3 div a
    render(HTML, div(
        h3("Main"),
        div(
            a[:href => "/welcome"]("/welcome")
        ),
        div(
            a[:href => "/calculator"]("/calculator")
        ),
    ))
end

end # module MainStuff



if PROGRAM_FILE == basename(@__FILE__)

using Bukdu
import Bukdu.Actions: index

using .WelcomeStuff
using .CalculatorStuff
using .MainStuff

routes() do
    get("/", MainController, index)
    get("/welcome", WelcomeController, index)
    get("/calculator", Calculator, index)
end

Bukdu.start(8080)

(Router)(get, "/")

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
