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

global changeset = Changeset(User, (name="",))

function index(c::FormController)
    global changeset
    @tags div
    form1 = form_for(changeset, (FormController, post_result), method=post, multipart=true) do f
        div(
            text_input(f, :name, placeholder="Name"),
            submit("Submit"),
            " multipart/form-data",
        )
    end
    form2 = form_for(changeset, (FormController, post_result), method=post, multipart=false) do f
        div(
            text_input(f, :name, placeholder="Name"),
            submit("Submit"),
            " application/x-www-form-urlencoded",
        )
    end
    body = div(form1, form2)
    render(HTML, layout(body))
end

function post_result(c::FormController)
    global changeset
    @tags div a strong h3 li
    result = change(changeset, c.params)
    if !isempty(result.changes)
        changeset = result
    end
    body = div(
        h3( a[:href => "/"]("back") ),
        li( isempty(result.changes) ? strong("nothing's changed") : "changed" ),
        li( "result: ", string(result) ),
        li( "global changeset: ", string(changeset) ),
    )
    render(HTML, layout(body))
end



if PROGRAM_FILE == basename(@__FILE__)

routes() do
    get("/", FormController, index)
    post("/post_result", FormController, post_result)
end

Bukdu.start(8080)

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
