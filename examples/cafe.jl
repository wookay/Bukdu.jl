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
    attach::Plug.Upload
end

user = User("foo bar", 20, "", 0.5, Plug.Upload())

include("layout.jl")

function post_result(c::CafeController)
    changeset = change(c, user)
    changes = isempty(changeset.changes) ? "<div><strong>no changes</strong></div>" : """
<h3>changes</h3>
<pre>
$(stringmime("text/html", changeset.changes))
</pre>

$(Tag.uploaded_image(changeset, :attach))
"""

    render(HTML/Layout, """
<h3>model</h3>
<pre>
$(changeset.model)
</pre>

$changes
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
    plug(Plug.Logger)
    plug(Plug.Static, at="/", from=normpath(dirname(@__FILE__), "public"), only=["css"])
    plug(Plug.Upload, at="/upload", tmp_dir=normpath(dirname(@__FILE__), "tmp"))
    plug(Router)
end

Bukdu.start(8080)

wait()

# Bukdu.stop()
