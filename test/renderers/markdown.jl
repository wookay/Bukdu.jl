importall Bukdu

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

Router() do
    resource("/:code", MarkdownController)
end


using Base.Test
conn = (Router)(index, "/1+2")
@test 200 == conn.status
@test """<pre><code>julia&gt; 1&#43;2\n3</code></pre>""" == conn.resp_body

conn = (Router)(index, "/")
@test 200 == conn.status
@test """<pre><code>julia&gt; \nnothing</code></pre>""" == conn.resp_body

conn = (Router)(index, "/undefined_variable")
@test 400 == conn.status
@test "bad request UndefVarError(:undefined_variable)" == conn.resp_body
