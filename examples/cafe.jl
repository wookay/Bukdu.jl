importall Bukdu

import Bukdu.Octo: default, change
import Tag: form_for, text_input, select, submit

type CafeController <: ApplicationController
end

type User
    name::String
    age::Int
end

function post_result(c::CafeController)
    c[:query_params]
end


function index(::CafeController)
    form = change(default(User), name="jack")
    form_for(form, action=post_result, method=post) do f
"""
<label>
  Name: $(text_input(f, :name))
</label>

<label>
    Age: $(select(f, :age, 18:20))
</label>

$(submit("Submit"))
"""
    end
end

Router() do
    get("/", CafeController, index)
    post("/post_result", CafeController, post_result)
end

Endpoint() do
    plug(Plug.Logger)
    plug(Router)
end

Bukdu.start(8080)

# wait()

# Bukdu.stop()
