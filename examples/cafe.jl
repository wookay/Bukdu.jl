importall Bukdu
importall Bukdu.Octo
importall Tag

type CafeController <: ApplicationController
end

type User
    name::String
    age::Int
    description::String
    happiness::Float64
    attach::FormFile
end

user = User("foo bar", 20, "", 0.5, FormFile())

include("layout.jl")

function post_result(c::CafeController)
    changeset = change(c, user)
    no_changes = isempty(changeset.changes) ? "-------------\n# < no changes >" : ""
    render(Markdown/Layout, """
# model
```
$(changeset.model)
```
# changes
```
$(changeset.changes)
```

$no_changes
""")
end


function input_form(form)
    form_for(form, action=post_result, method=post, multipart=true) do f
         """
<div>
  Name: $(text_input(f, :name))
</div>

<div>
    Age: $(select(f, :age, 18:30))
</div>

<div>
    Happiness: $(text_input(f, :happiness))
</div>

<div>
    $(textarea(f, :description, placeholder="enter description"))
</div>

<div>
    $(file_input(f, :attach))
</div>

$(submit("Submit"))
"""
    end
end

function index(::CafeController)
    form = change(user)
    render(HTML/Layout, input_form(form))
end

Router() do
    get("/", CafeController, index)
    post("/post_result", CafeController, post_result)
end

Endpoint() do
    plug(Plug.Static, at= "/", from=normpath(dirname(@__FILE__), "public"); try_index_html=false)
    plug(Plug.Logger)
    plug(Router)
end

Bukdu.start(8080)

# wait()

# Bukdu.stop()
