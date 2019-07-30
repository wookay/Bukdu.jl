# # Bukdu v0.4.5
using Bukdu # ApplicationController Conn HTML Changeset render routes get post
using Bukdu.HTML5.Form # form_for file_input submit
using Documenter.Utilities.DOM: @tags
using HTTP: Multipart
using Base64

struct FormController <: ApplicationController
    conn::Conn
end

function layout(body)
    """
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h3>Multipart example</h3>
$body
</body>
</html>
"""
end

function preview(multipart::Multipart)
    if eof(multipart)
        string("empty")
    else
        @tags div img
        mark(multipart)
        data = read(multipart)
        reset(multipart)
        contents = [
            div(multipart.filename),
            div(repr(length(data)), " bytes"),
        ]
        if startswith(multipart.contenttype, "image")
            base64 = base64encode(data)
            push!(contents, img[:src => string("data:", multipart.contenttype, ";base64, ", base64),
                                :alt => multipart.filename])
        end
        div(contents)
    end
end

function preview(::Nothing)
    ""
end

struct User
end

function post_result(c::FormController)
    @tags div h3
    user_photo1 = c.params["user_photo1"]
    user_photo2 = c.params["user_photo2"]
    body = div([
        h3("user_photo1"),
        preview(user_photo1),
        h3("user_photo2"),
        preview(user_photo2),
    ])
    render(HTML, layout(body))
end

function index(c::FormController)
    @tags div
    form1 = form_for(Changeset(User), (FormController, post_result), method=post, multipart=true) do f
        div(
            div.([
                label_for(file_input(f, :photo1), "Photo1"),
                label_for(file_input(f, :photo2), "Photo2"),
                submit("Submit"),
            ])
        )
    end
    body = div(form1)
    render(HTML, layout(body))
end

routes() do
    get("/", FormController, index)
    post("/post_result", FormController, post_result)
end

Bukdu.start(8080)
Router.call(get, "/") #
Base.JLOptions().isinteractive==0 && wait()
