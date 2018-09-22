using Bukdu
using .Bukdu.System: MissingController
import .Bukdu.System: not_found

function not_found(c::MissingController)
    c.conn.request.response.status = 404 # 404 Not Found
    render(HTML, "custom 404 not found message")
end



if PROGRAM_FILE == basename(@__FILE__)

Bukdu.start(8080)

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
