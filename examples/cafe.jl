importall Bukdu
importall Bukdu.Octo
importall Tag

type CafeController <: ApplicationController
end

type User
    name::String
    age::Int
end

user = User("jack", 19)

function post_result(c::CafeController)
    changeset = change(c, user)
end


function index(::CafeController)
    form = change(user, age=20)
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
