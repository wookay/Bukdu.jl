module test_renderers_html

importall Bukdu
import Base.Test: @test, @test_throws

type HTMLController <: ApplicationController
end

index(::HTMLController) = render(HTML, "<p>hello</p>")

Router() do
    get("/", HTMLController, index)
end


conn = (Router)(get, "/")
@test 200 == conn.status
@test "<p>hello</p>" == conn.resp_body

logs = []
before(render, HTML) do t
    push!(logs, "b $t")
end
after(render, HTML) do t
    push!(logs, "a $t")
end

conn = (Router)(get, "/")
@test ["b <p>hello</p>", "a <p>hello</p>"] == logs

type HtmlLayout <: ApplicationLayout
end
layout(::HtmlLayout, body) = """<div>$body</div>"""
show(::HTMLController) = render(HTML/HtmlLayout, "<p>hello</p>")
Router() do
    get("/say", HTMLController, show)
end

before(render, HTML/HtmlLayout) do t
    push!(logs, "bl $t")
end
after(render, HTML/HtmlLayout) do t
    push!(logs, "al $t")
end

empty!(logs)

conn = (Router)(get, "/say")
@test 200 == conn.status
@test "<div><p>hello</p></div>" == conn.resp_body

@test ["bl <p>hello</p>","b <p>hello</p>","a <p>hello</p>","al <p>hello</p>"] == logs

end # module test_renderers_html
