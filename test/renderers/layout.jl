module test_renderers_layout

importall Bukdu
import Base.Test: @test, @test_throws

type HelloController <: ApplicationController
end

type ALayout <: ApplicationLayout
end

type CustomLayout <: ApplicationLayout
end

layout(::ALayout, body) = "layout $body"
layout(::CustomLayout, body) = "custom $body"

custom(::HelloController) = render(Text/ALayout/CustomLayout, "hello")
index(::HelloController) = render(Text/CustomLayout/ALayout, "hello")

Router() do
    get("/", HelloController, index)
    get("/custom", HelloController, custom)
end


conn = (Router)(get, "/")
@test 200 == conn.status
@test "layout custom hello" == conn.resp_body

conn = (Router)(get, "/custom")
@test 200 == conn.status
@test "custom layout hello" == conn.resp_body

@test "custom layout hello" == render(Text/ALayout/CustomLayout, "hello").resp_body
@test "layout custom hello" == render(Text/CustomLayout/ALayout, "hello").resp_body
@test "custom layout hello" == render(HTML/ALayout/CustomLayout, "hello").resp_body
@test "layout custom hello" == render(HTML/CustomLayout/ALayout, "hello").resp_body

@test "Text{T}" == string(Text)
@test "Text/ALayout" == string(Text/ALayout)
@test "Text/ALayout/CustomLayout" == string(Text/ALayout/CustomLayout)
@test "Text/CustomLayout/ALayout" == string(Text/CustomLayout/ALayout)
@test "ALayout/CustomLayout" == string(ALayout/CustomLayout)
@test "CustomLayout/ALayout" == string(CustomLayout/ALayout)

end # module test_renderers_layout
