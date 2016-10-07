importall Bukdu

type TextController <: ApplicationController
end

layout(::Layout, body) = """empty layout"""
index(::TextController) = render(Text)
index_with_layout(::TextController) = render(Text/Layout)

Router() do
    get("/index", TextController, index)
    get("/index_with_layout", TextController, index_with_layout)
end


using Base.Test
conn = (Router)(get, "/index")
@test 200 == conn.status
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "" == conn.resp_body

logs = []
before(render, Text) do
    push!(logs, "b")
end
after(render, Text) do
    push!(logs, "a")
end

conn = (Router)(get, "/index")
@test "" == conn.resp_body
@test ["b", "a"] == logs
empty!(logs)


conn = (Router)(get, "/index_with_layout")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "empty layout" == conn.resp_body
@test ["b", "a"] == logs
empty!(logs)


layout(::Layout, body::String) = """layout - $body"""
index1(::TextController) = render(Text, "hello")
index_with_layout1(::TextController) = render(Text/Layout, "hello")

Router() do
    get("/index1", TextController, index1)
    get("/index_with_layout1", TextController, index_with_layout1)
end

conn = (Router)(get, "/index1")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "hello" == conn.resp_body
@test [] == logs

before(render, Text) do body
    push!(logs, "b $body")
end
after(render, Text) do body
    push!(logs, "a $body")
end

conn = (Router)(get, "/index1")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "hello" == conn.resp_body
@test ["b hello", "a hello"] == logs
empty!(logs)

conn = (Router)(get, "/index_with_layout1")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "layout - hello" == conn.resp_body
@test ["b hello", "a hello"] == logs
empty!(logs)

before(render, Text/Layout) do body
    push!(logs, "bl $body")
end
after(render, Text/Layout) do body
    push!(logs, "al $body")
end

conn = (Router)(get, "/index1")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "hello" == conn.resp_body
@test ["b hello", "a hello"] == logs
empty!(logs)

conn = (Router)(get, "/index_with_layout1")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "layout - hello" == conn.resp_body
@test ["bl hello","b hello","a hello","al hello"] == logs
empty!(logs)


layout(::Layout, body::String, c::TextController) = """layout2 - $body, $c"""
index2(c::TextController) = render(Text, "foo", c)
index_with_layout2(c::TextController) = render(Text/Layout, "foo", c)

Router() do
    get("/index2", TextController, index2)
    get("/index_with_layout2", TextController, index_with_layout2)
end

conn = (Router)(get, "/index2")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "foo" == conn.resp_body
@test [] == logs
empty!(logs)

before(render, Text) do body, c
    push!(logs, "b $body, $c")
end

after(render, Text) do body, c
    push!(logs, "a $body, $c")
end

before(render, Text/Layout) do body, c
    push!(logs, "bl")
end

after(render, Text/Layout) do body, c
    push!(logs, "al")
end

conn = (Router)(get, "/index_with_layout2")
@test "text/plain" == conn.resp_headers["Content-Type"]
@test "layout2 - foo, TextController()" == conn.resp_body
@test ["bl","b foo, TextController()","a foo, TextController()","al"] == logs
empty!(logs)
