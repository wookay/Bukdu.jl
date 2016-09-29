importall Bukdu

type HelloController <: ApplicationController
end

layout(::Layout, body) = "layout $body"

type CustomLayout <: ApplicationLayout
end
layout(::CustomLayout, body) = "custom $body"

custom(::HelloController) = render(Text/Layout/CustomLayout, "hello")
index(::HelloController) = render(Text/CustomLayout/Layout, "hello")

Router() do
    get("/", HelloController, index)
    get("/custom", HelloController, custom)
end


using Base.Test
conn = (Router)(get, "/")
@test 200 == conn.status
@test "layout custom hello" == conn.resp_body

conn = (Router)(get, "/custom")
@test 200 == conn.status
@test "custom layout hello" == conn.resp_body

@test "custom layout hello" == render(Text/Layout/CustomLayout, "hello").resp_body
@test "layout custom hello" == render(Text/CustomLayout/Layout, "hello").resp_body
@test "custom layout hello" == render(HTML/Layout/CustomLayout, "hello").resp_body
@test "layout custom hello" == render(HTML/CustomLayout/Layout, "hello").resp_body

@test "Text{T}" == string(Text)
@test "Text/Layout" == string(Text/Layout)
@test "Text/Layout/CustomLayout" == string(Text/Layout/CustomLayout)
@test "Text/CustomLayout/Layout" == string(Text/CustomLayout/Layout)
@test "Layout/CustomLayout" == string(Layout/CustomLayout)
@test "CustomLayout/Layout" == string(CustomLayout/Layout)
