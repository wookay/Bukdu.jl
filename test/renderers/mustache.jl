module test_renderers_mustache

importall Bukdu
import Base.Test: @test, @test_throws

type PageController <: ApplicationController
end

show(::PageController) = render(View; path="renderers/page.tpl", contents="hello")

Router() do
    get("/:page", PageController, show)
end


conn = (Router)(get, "/1")
@test 200 == conn.status
@test "<div>hello</div>" == conn.resp_body
@test "1" == conn.params["page"]
@test "1" == conn.params[:page]

type ALayout <: ApplicationLayout
end

layout(::ALayout, body) = """<html><body>$body<body></html>"""
index(c::PageController) = render(View/ALayout; path="renderers/page.tpl", contents="hello")

Router() do
    get("/", PageController, index)
end

conn = (Router)(get, "/")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body
@test !haskey(conn.params, "page")

logs = []
before(render, View) do
    push!(logs, "before")
end

after(render, View) do
    push!(logs, "after")
end
conn = (Router)(get, "/")
@test ["before", "after"] == logs
empty!(logs)


layout(::ALayout, body, c::PageController, kwd) = """layout2 - $body, $(c[:name]), $(kwd[:path])"""
index2(c::PageController) = render(View, c; path="renderers/page.tpl", contents="hello")
index_with_layout2(c::PageController) = render(View/ALayout, c; path="renderers/page.tpl", contents="hello")

Router() do
    get("/index2", PageController, index2)
    get("/index_with_layout2", PageController, index_with_layout2)
end

conn = (Router)(get, "/index2")
@test "<div>hello</div>" == conn.resp_body
@test [] == logs
empty!(logs)

before(render, View) do c
    push!(logs, "before $(c[:name])")
end

after(render, View) do c
    push!(logs, "after $(c[:name])")
end

conn = (Router)(get, "/index2")
@test "<div>hello</div>" == conn.resp_body
@test ["before PageController","after PageController"] == logs
empty!(logs)

conn = (Router)(get, "/index_with_layout2")
@test "layout2 - <div>hello</div>, PageController, renderers/page.tpl" == conn.resp_body
@test ["before PageController","after PageController"] == logs
empty!(logs)

before(render, View/ALayout) do c
    push!(logs, "bl")
end

after(render, View/ALayout) do c
    push!(logs, "al")
end

conn = (Router)(get, "/index_with_layout2")
@test "layout2 - <div>hello</div>, PageController, renderers/page.tpl" == conn.resp_body
@test ["bl", "before PageController","after PageController", "al"] == logs
empty!(logs)

end # module test_renderers_mustache
