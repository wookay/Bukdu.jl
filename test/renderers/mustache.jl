importall Bukdu

type PageController <: ApplicationController
end

show(c::PageController) = render(View; path="page.tpl", contents="hello")

Router() do
    get("/:page", PageController, show)
end


using Base.Test
conn = (Router)(show, "/1")
@test 200 == conn.status
@test "<div>hello</div>" == conn.resp_body
@test "1" == conn.params["page"]


layout(::Layout, body, options) = """<html><body>$body<body></html>"""

index(c::PageController) = render(View/Layout; path="page.tpl", contents="hello")

Router() do
    get("/", PageController, index)
end

conn = (Router)(index, "/")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body
@test !haskey(conn.params, "page")

logs = []
before(render, View) do path, contents
    push!(logs, "before $path $contents")
end
after(render, View) do path, contents
    push!(logs, "after $path $contents")
end
conn = (Router)(index, "/")
@test ["before page.tpl hello", "after page.tpl hello"] == logs
