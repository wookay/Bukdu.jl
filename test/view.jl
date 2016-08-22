importall Bukdu

type PageController <: ApplicationController
end

type Layout
end
layout(::Layout, body, params) = """<html><body>$body<body></html>"""

show(c::PageController) = render(View{Layout}, "page.tpl"; contents="hello")

Router() do
    get("/:page", PageController, show)
end


using Base.Test
conn = (Router)(show, "/1")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body
@test "1" == conn.params["page"]

logs = []
Bukdu.before(::View) = push!(logs, :b)
Bukdu.after(::View) = push!(logs, :a)
conn = (Router)(show, "/1")
@test [:b, :a] == logs

@test "<div>hello</div>" == render(View, "page.tpl"; contents="hello")
@test "<html><body><div>hello</div><body></html>" == render(View{Layout}, "page.tpl"; contents="hello")
