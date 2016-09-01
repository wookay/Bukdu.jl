importall Bukdu

type TextController <: ApplicationController
end

index(::TextController) = render(Text, "hello")

Router() do
    get("/", TextController, index)
end


using Base.Test
conn = (Router)(get, "/")
@test 200 == conn.status
@test "text/plain" == conn.resp_header["Content-Type"]
@test "hello" == conn.resp_body

logs = []
before(render, Text) do t
    push!(logs, "b $t")
end
after(render, Text) do t
    push!(logs, "a $t")
end

conn = (Router)(get, "/")
@test ["b hello", "a hello"] == logs

layout(::Layout, body, options) = """say $body"""
show(::TextController) = render(Text/Layout, "hello")
Router() do
    get("/say", TextController, show)
end

before(render, Text/Layout) do t
    push!(logs, "bl $t")
end
after(render, Text/Layout) do t
    push!(logs, "al $t")
end

empty!(logs)

conn = (Router)(get, "/say")
@test 200 == conn.status
@test "text/plain" == conn.resp_header["Content-Type"]
@test "say hello" == conn.resp_body

@test ["bl hello","b hello","a hello","al hello"] == logs
