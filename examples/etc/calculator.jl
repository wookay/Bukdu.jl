using Bukdu # ApplicationController Conn render HTML routes get Router
using Documenter.Utilities.DOM: @tags

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
        h3("Calculator"),
        div(
            string(x, +, y, '=', x+y),
        ),
        div(
            a[:href => "/?x=$rand_x&y=$rand_y"]("/?x=$rand_x&y=$rand_y")
        )
    ))
end



if PROGRAM_FILE == basename(@__FILE__)

routes() do
    get("/", Calculator, index)
end

Bukdu.start(8080)

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
