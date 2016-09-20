importall Bukdu

type HelloController <: ApplicationController
end

layout(::Layout, body) = "default $body"

type CustomLayout <: ApplicationLayout
end
layout(::CustomLayout, body) = "custom $body"

custom(::HelloController) = render(Text/CustomLayout, "hello")
index(::HelloController) = render(Text/Layout, "hello")

Router() do
    get("/", HelloController, index)
    get("/hey", HelloController, custom)
end


using Base.Test
conn = (Router)(get, "/")
@test 200 == conn.status
@test "default hello" == conn.resp_body

conn = (Router)(get, "/hey")
@test 200 == conn.status
@test "custom hello" == conn.resp_body
