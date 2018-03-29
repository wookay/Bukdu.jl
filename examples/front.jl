if PROGRAM_FILE == basename(@__FILE__)
    println("please  julia -i sevenstars.jl")
    exit()
end


module Front

export WelcomeController

using Bukdu
import Bukdu.Actions: index
import ..Layout: layout
import ..WASM: WasmController

struct WelcomeController <: ApplicationController
    conn::Conn
end

end # module Front


import .Layout: layout
function Front.index(::Front.WelcomeController)
    wasm_path = Router.Helpers.url_path(get, WasmController, index)
    bukdu_git_url = "http://github.com/wookay/Bukdu.jl"
    
    title = ""
    script = ""
    style = ""
    body = """
<h3>Welcome</h3>

<p>Bukdu sevenstars demo on Heroku</p>
  <li>Visit Bukdu.jl Github Repository => <a href="$bukdu_git_url">$bukdu_git_url</a></li>
  <p />
  <li>Heroku example. Get full code of this page => <a href="https://github.com/wookay/heroku-sevenstars">https://github.com/wookay/heroku-sevenstars</a></li>

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
curl -X GET    https://sevenstars.herokuapp.com/customers
curl -X GET    https://sevenstars.herokuapp.com/customers/new
curl -X GET    https://sevenstars.herokuapp.com/customers/1/edit
curl -X GET    https://sevenstars.herokuapp.com/customers/1
curl -X POST   https://sevenstars.herokuapp.com/customers
curl -X DELETE https://sevenstars.herokuapp.com/customers/1
curl -X PATCH  https://sevenstars.herokuapp.com/customers/1
curl -X PUT    https://sevenstars.herokuapp.com/customers/1
</pre>

<h3>2. WebAssembly Demo</h3>
<p>Go => <a href="$wasm_path">WASM</a></h3></p>
"""
    layout(title, script, style, body)
end
