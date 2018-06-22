using Bukdu # ApplicationController Conn HTML Router CLI render routes get post
using Bukdu.HTML5.Form # change
                       # form_for label_for
                       # text_area text_input radio_button checkbox
                       # submit
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

global changeset = Changeset(User, (name="", famous=false, season="summer", intro=""))

function index(c::FormController)
    global changeset
    @tags div
    form1 = form_for(changeset, (FormController, post_result), method=post, multipart=true) do f
        div(
            div.([
                text_area(f, :name, placeholder="Name", rows="3", cols="50"),
                label_for(checkbox(f, :famous), "Famous"),
                submit("Submit"),
                " multipart/form-data",
            ])
        )
    end
    form2 = form_for(changeset, (FormController, post_result), method=post, multipart=false) do f
        div(
            div.([
                text_area(f, :intro, placeholder="Intro", rows="5", cols="50"),
                [
                    label_for(radio_button(f, :season, "winter"), "Winter"),
                    label_for(radio_button(f, :season, "spring"), "Spring"),
                    label_for(radio_button(f, :season, "summer"), "Summer"),
                    label_for(radio_button(f, :season, "autumn"), "Autumn"),
                ],
                submit("Submit"),
                " application/x-www-form-urlencoded",
            ])
        )
    end
    body = div(form1, form2)
    render(HTML, layout(body))
end

function post_result(c::FormController)
    global changeset
    @tags div a h3 li p
    result = change(changeset, c.params)
    if !isempty(result.changes)
        changeset.changes = merge(changeset.changes, result.changes)
    end
    body = div(
        h3( a[:href => "/"]("back") ),
        p(isempty(result.changes) ?
            "nothing's changed" :
            "✅ changed"),
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

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
