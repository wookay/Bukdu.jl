importall Bukdu
importall Bukdu.Octo
importall Tag

type CafeController <: ApplicationController
end

type User
    name::String
    age::Int
    description::String
end

user = User("foo bar", 20, "")

layout(::Layout, body) = """
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Hello Livecoding</title>
    <link rel="stylesheet" href="/css/style.css"/>
</head>
<body>
<div>
$body
</div>
</body>
</html>
"""

function post_result(c::CafeController)
    changeset = change(c, user)
    changed = isempty(changeset.changes) ? "<p>no changes</p>" : ""
    render(HTML/Layout, """
        <div>$(changeset.model)</div>
        <div>$(changeset.changes)</div>
        <p>$changed</p>
    """)
end


function index(::CafeController)
    form = change(user)
    contents = form_for(form, action=post_result, method=post) do f
"""
<label>
  Name: $(text_input(f, :name))
</label>

<label>
    Age: $(select(f, :age, 18:30))
</label>

<div>
$(textarea(f, :description, placeholder="enter description"))
</div>

$(submit("Submit"))
"""
    end
    render(HTML/Layout, contents)
end

Router() do
    get("/", CafeController, index)
    post("/post_result", CafeController, post_result)
end

Endpoint() do
    plug(Plug.Static, at= "/", from= "$(dirname(@__FILE__))/public"; try_index_html=false)
    plug(Plug.Logger)
    plug(Router)
end

Bukdu.start(8080)

# wait()

# Bukdu.stop()
