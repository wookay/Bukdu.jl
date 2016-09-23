importall Bukdu
importall Bukdu.Octo
importall Tag

type CafeController <: ApplicationController
end

type User
    name::String
    age::Int
end

user = User("foo bar", 19)

layout(::Layout, body) = """
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
$body
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
    form = change(user, age=20)
    contents = form_for(form, action=post_result, method=post) do f
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
    render(HTML/Layout, contents)
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
