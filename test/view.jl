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
    plug(Plug.Logger, level=false)
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
conn = (Router)(show, "/hey")
@test 200 == conn.status
@test "<div>hello</div>" == conn.resp_body

conn = (Router)(index, "/")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body

conn = (Router)(mark, "/mark")
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
conn = (Router)(index, "/")
@test [:bvl,:bv,:av,:avl] == logs

conn = (Router)(index, "/")
@test [:bvl,:bv,:av,:avl, :bvl,:bv,:av,:avl] == logs

@test "<div>hello</div>" == render(View; path="page.tpl", contents="hello")
@test "<html><body><div>hello</div><body></html>" == render(View/Layout; path="page.tpl", contents="hello")


before(render, Markdown) do text
    Logger.debug("mark")
end

before(render, Markdown/Layout) do text
    Logger.debug("mark")
end

let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(mark, "/mark")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test "\e[1m\e[33mDEBUG\e[0m Markdown/Layout mark\n\e[1m\e[33mDEBUG\e[0m Markdown mark\n" == wait(reader)
end


before(render, View/Layout) do path, contents
    Logger.debug("view")
end

before(render, View) do path, contents
    Logger.debug("view")
end


let oldout = STDERR
   rdout, wrout = redirect_stdout()

conn = (Router)(index, "/")

   reader = @async readstring(rdout)
   redirect_stdout(oldout)
   close(wrout)

@test "\e[1m\e[33mDEBUG\e[0m View/Layout view\n\e[1m\e[33mDEBUG\e[0m View view\n" == wait(reader)
end
