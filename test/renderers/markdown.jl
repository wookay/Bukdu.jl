module test_renderers_markdown

importall Bukdu
import Base.Test: @test, @test_throws

type MarkdownController <: ApplicationController
    conn::Conn
end

function index(c::MarkdownController)
    code = c[:params]["code"]
    render(Markdown, """
```
julia> $code
$(eval(parse(code)))
```
""")
end

layout(::Layout, body) = "<body>$body</body>"
Base.show(::MarkdownController) = render(Markdown/Layout, "`cool`")

Router() do
    get("/:code", MarkdownController, index)
    get("/mark/down", MarkdownController, show)
end


conn = (Router)(get, "/mark/down")
@test 200 == conn.status
@test "<body><p><code>cool</code></p></body>" == conn.resp_body

conn = (Router)(get, "/1+2")
@test 200 == conn.status
@test """<pre><code>julia&gt; 1&#43;2\n3</code></pre>""" == conn.resp_body

conn = (Router)(get, "/1+2")
@test 200 == conn.status
@test """<pre><code>julia&gt; 1&#43;2\n3</code></pre>""" == conn.resp_body

conn = (Router)(get, "/")
@test 200 == conn.status
@test """<pre><code>julia&gt; \nnothing</code></pre>""" == conn.resp_body

Logger.have_color(false)
let oldout = STDERR
    rdout, wrout = redirect_stdout()

    conn = (Router)(get, "/undefined_variable")
    @test 400 == conn.status
    @test contains(conn.resp_body, "UndefVarError")

    reader = @async readstring(rdout)
    redirect_stdout(oldout)
    close(wrout)

    @test startswith(wait(reader), "ERROR  GET /undefined_variable")
end

end # module test_renderers_markdown
