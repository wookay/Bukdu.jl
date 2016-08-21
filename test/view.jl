using Base.Test
using Bukdu

type Layout
end
Bukdu.layout(::Layout, body, params) = """<html><body>$body<body></html>"""

@test "<div>hello</div>" == render(View, "page.tpl"; contents="hello")
@test "<html><body><div>hello</div><body></html>" == render(View{Layout}, "page.tpl"; contents="hello")


type PageController <: ApplicationController
end

show(::PageController) = render(View, "page.tpl"; contents="hello")

Router() do
    get("/:page", PageController, show)
end

conn = (Router)(show, "/1")
@test 200 == conn.status
@test "<div>hello</div>" == conn.resp_body
@test "1" == conn.params["page"]
