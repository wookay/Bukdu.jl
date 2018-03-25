using Bukdu # ApplicationController Conn HTML render
using Bukdu.HTML5.Form # change form_for text_input submit
import Documenter.Utilities.DOM: @tags

struct FormController <: ApplicationController
    conn::Conn
end

struct User
end

function layout(body)
    """
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
$body
</body>
</html>
"""
end

function index(c::FormController)
    changeset = Changeset(User)
    @tags div
    
    form1 = form_for(changeset, (FormController, post_result), method=post, multipart=true) do f
        div(
            text_input(f, :name),
            submit("Submit")
        )
    end

    form2 = form_for(changeset, (FormController, post_result), method=post, multipart=false) do f
        div(
            text_input(f, :name),
            submit("Submit")
        )
    end
    body = div(form1, form2)
    render(HTML, layout(body))
end

function post_result(c::FormController)
    changeset = change(User, c.params)
    body = changeset
    render(HTML, layout(body))
end

Router() do
    get("/", FormController, index)
    post("/post_result", FormController, post_result)
end

Bukdu.start(8080)

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
