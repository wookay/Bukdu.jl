importall Bukdu

type ViewController <: ApplicationController
end

layout(::Layout, body, options) = "<html><body>$body<body></html>"

show(::ViewController) = render(View; path="page.tpl", contents="hello")
index(::ViewController) = render(View/Layout; path="page.tpl", contents="hello")
mark(::ViewController) = render(Markdown/Layout, "# hello")

Router() do
    get("/hey", ViewController, show)
    get("/", ViewController, index)
    get("/mark", ViewController, mark)
end

Endpoint() do
    plug(Router)
end

plugins(render, View/Layout) do path, contents
    plug(Logger.log_message, View/Layout)
end

plugins(render, View) do path, contents
    plug(Logger.log_message, View)
end

plugins(render, Markdown/Layout) do text
    plug(Logger.log_message, Markdown/Layout)
end

plugins(render, Markdown) do text
    plug(Logger.log_message, Markdown)
end


using Base.Test
conn = (Router)(get, "/hey")
@test 200 == conn.status
@test "<div>hello</div>" == conn.resp_body

conn = (Router)(get, "/")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body

conn = (Router)(get, "/mark")
@test 200 == conn.status
@test "<html><body><h1>hello</h1><body></html>" == conn.resp_body

logs = []
before(render, View/Layout) do path, contents
    push!(logs, :bvl)
end
before(render, View) do path, contents
    push!(logs, :bv)
end
after(render, View) do path, contents
    push!(logs, :av)
end
after(render, View/Layout) do path, contents
    push!(logs, :avl)
end
conn = (Router)(get, "/")
@test [:bvl,:bv,:av,:avl] == logs

conn = (Router)(get, "/")
@test [:bvl,:bv,:av,:avl, :bvl,:bv,:av,:avl] == logs

@test "<div>hello</div>" == render(View; path="page.tpl", contents="hello")
@test "<html><body><div>hello</div><body></html>" == render(View/Layout; path="page.tpl", contents="hello")


Logger.have_color(false)

before(render, Markdown/Layout) do text
    Logger.info("mark")
end

before(render, Markdown) do text
    Logger.info("down")
end

let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(get, "/mark")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test "INFO Markdown/Layout mark\nINFO Markdown down\n" == wait(reader)
end


before(render, View/Layout) do path, contents
    Logger.info("view layout")
end

before(render, View) do path, contents
    Logger.info("view")
end


let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(get, "/")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test "INFO View/Layout view layout\nINFO View view\n" == wait(reader)
end
