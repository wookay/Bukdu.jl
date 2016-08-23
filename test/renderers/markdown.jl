importall Bukdu
import Base: show

type MarkdownController <: ApplicationController
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

layout(::Layout, body, options) = "<body>$body</body>"
show(::MarkdownController) = render(Markdown/Layout, "`cool`")

Router() do
    get("/mark/down", MarkdownController, show)
    get("/:code", MarkdownController, index)
end


using Base.Test
conn = (Router)(show, "/mark/down")
@test 200 == conn.status
@test "<body><p><code>cool</code></p></body>" == conn.resp_body

conn = (Router)(index, "/1+2")
@test 200 == conn.status
@test """<pre><code>julia&gt; 1&#43;2\n3</code></pre>""" == conn.resp_body

conn = (Router)(index, "/1+2")
@test 200 == conn.status
@test """<pre><code>julia&gt; 1&#43;2\n3</code></pre>""" == conn.resp_body

conn = (Router)(index, "/")
@test 200 == conn.status
@test """<pre><code>julia&gt; \nnothing</code></pre>""" == conn.resp_body

conn = (Router)(index, "/undefined_variable")
@test 400 == conn.status
@test "bad request UndefVarError(:undefined_variable)" == conn.resp_body
