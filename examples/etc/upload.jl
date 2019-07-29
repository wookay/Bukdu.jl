# # Bukdu v0.4.5
using Bukdu # ApplicationController Conn HTML Router CLI render routes get post
using Bukdu.HTML5.Form # change
                       # form_for label_for
                       # text_area text_input radio_button checkbox file_input
                       # submit
using Documenter.Utilities.DOM: @tags
using HTTP: Multipart
using Base64

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

global changeset = Changeset(User, (name="", famous=false, season="summer", intro="", photo1=nothing, photo2=nothing))

function preview(multipart::Multipart)
    @tags img
    mark(multipart)
    data = read(multipart)
    if isempty(data)
        ""
    else
        base64 = base64encode(data)
        reset(multipart)
        img[:src => string("data:", multipart.contenttype, ";base64, ", base64),
            :alt => multipart.filename]
    end
end

function preview(::Nothing)
    ""
end

function index(c::FormController)
    global changeset
    @tags div
    form1 = form_for(changeset, (FormController, post_result), method=post, multipart=true) do f
        div(
            div.([
                text_area(f, :name, placeholder="Name", rows="3", cols="50"),
                label_for(checkbox(f, :famous), "Famous"),
                label_for(file_input(f, :photo1), "Photo1"),
                preview(changeset.changes.photo1),
                label_for(file_input(f, :photo2), "Photo2"),
                preview(changeset.changes.photo2),
                submit("Submit"),
            ])
        )
    end
    body = div(form1)
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
        preview(changeset.changes.photo1),
        preview(changeset.changes.photo2),
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
