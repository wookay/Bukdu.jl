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

layout(::Layout, body) = "<body>$body</body>"
show(::MarkdownController) = render(Markdown/Layout, "`cool`")

Router() do
    get("/:code", MarkdownController, index)
    get("/mark/down", MarkdownController, show)
end


using Base.Test
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
@test contains(conn.resp_body, "400 UndefVarError(:undefined_variable)")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test startswith(wait(reader), "ERROR  GET /undefined_variable                 ")
end
