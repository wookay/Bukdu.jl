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
<h3>Bukdu.HTML5.Form</h3>
$body
</body>
</html>
"""
end

function index(c::FormController)
    @tags div
    changeset = Changeset(User, (name="Alex",))
    form1 = form_for(changeset, (FormController, post_result), method=post, multipart=true) do f
        div(
            text_input(f, :name),
            submit("Submit"),
            " multipart/form-data",
        )
    end
    form2 = form_for(changeset, (FormController, post_result), method=post, multipart=false) do f
        div(
            text_input(f, :name),
            submit("Submit"),
            " application/x-www-form-urlencoded",
        )
    end
    body = div(form1, form2)
    render(HTML, layout(body))
end

function post_result(c::FormController)
    @tags div a strong h3 li
    changeset = change(User, (name="Alex",), c.params)
    body = div(
        h3( a[:href => "/"]("back") ),
        li( isempty(changeset.changes) ? strong("nothing's changed") : "changed" ),
        li( string(changeset) )
    )
    render(HTML, layout(body))
end

Router() do
    get("/", FormController, index)
    post("/post_result", FormController, post_result)
end

Bukdu.start(8080)

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
