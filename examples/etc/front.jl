if PROGRAM_FILE == basename(@__FILE__)
    println("please  julia -i sevenstars.jl")
    exit()
end


module Front

export WelcomeController

using Bukdu # ApplicationController Conn
using ..Layout: layout
using ..WASM: WasmController
using Sockets: @ip_str
import Bukdu.Actions: index

struct WelcomeController <: ApplicationController
    conn::Conn
end

function get_server()
    if haskey(ENV, "ON_HEROKU")
        (port=parse(Int, ENV["PORT"]), host=Sockets.IPAddr(0,0,0,0))
    else
        (port=8080, host=ip"127.0.0.1")
    end
end

server = get_server()

end # module Front


import .Layout: layout
function Front.index(::Front.WelcomeController)
    wasm_path = Router.Helpers.url_path(get, WasmController, index)
    uri = "http://$(Front.server.host):$(Front.server.port)"
    title = ""
    script = ""
    style = ""
    body = """
<h3>Welcome</h3>

<h3>1. REST API Demo</h3>
<pre>
GET     /customers           CustomerController  index   :api
GET     /customers/new       CustomerController  new     :api
GET     /customers/:id/edit  CustomerController  edit    :api
GET     /customers/:id       CustomerController  show    :api
POST    /customers           CustomerController  create  :api
DELETE  /customers/:id       CustomerController  delete  :api
PATCH   /customers/:id       CustomerController  update  :api
PUT     /customers/:id       CustomerController  update  :api
</pre>

<pre>
curl -X GET    $uri/customers
curl -X GET    $uri/customers/new
curl -X GET    $uri/customers/1/edit
curl -X GET    $uri/customers/1
curl -X POST   $uri/customers
curl -X DELETE $uri/customers/1
curl -X PATCH  $uri/customers/1
curl -X PUT    $uri/customers/1
</pre>

<h3>2. WebAssembly Demo</h3>
<p>Go => <a href="$wasm_path">WASM</a></h3></p>
"""
    layout(title, script, style, body)
end
