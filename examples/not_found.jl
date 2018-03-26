using Bukdu
import Bukdu.Routing: MissingController, not_found

function not_found(c::MissingController)
    render(HTML, "custom 404 not found message")
end



if PROGRAM_FILE == basename(@__FILE__)

Bukdu.start(8080)

(Router)(get, "/")

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
