module test_renderers_view

importall Bukdu
import Base.Test: @test, @test_throws

type ViewController <: ApplicationController
end

type ALayout <: ApplicationLayout
end

layout(::ALayout, body) = "<html><body>$body<body></html>"

show(::ViewController) = render(View; path="renderers/page.tpl", contents="hello")
index(::ViewController) = render(View/ALayout; path="renderers/page.tpl", contents="hello")
mark(::ViewController) = render(Markdown/ALayout, "# hello")

Router() do
    get("/hey", ViewController, show)
    get("/", ViewController, index)
    get("/mark", ViewController, mark)
end

Endpoint() do
    plug(Router)
end


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

before(render, View/ALayout) do
    push!(logs, :bvl)
end

before(render, View) do
    push!(logs, :bv)
end

after(render, View/ALayout) do
    push!(logs, :avl)
end

after(render, View) do
    push!(logs, :av)
end

conn = (Router)(get, "/")
@test [:bvl,:bv,:av,:avl] == logs

conn = (Router)(get, "/")
@test [:bvl,:bv,:av,:avl, :bvl,:bv,:av,:avl] == logs

@test "<div>hello</div>" == render(View; path="renderers/page.tpl", contents="hello").resp_body
@test "<html><body><div>hello</div><body></html>" == render(View/ALayout; path="renderers/page.tpl", contents="hello").resp_body


Logger.have_color(false)
Logger.set_level(:info)

before(render, Markdown/ALayout) do md
    Logger.info("mark layout")
end

before(render, Markdown) do md
    Logger.info("mark")
end

let oldout = STDERR
    rdout, wrout = redirect_stdout()

    conn = (Router)(get, "/mark")

    reader = @async readstring(rdout)
    redirect_stdout(oldout)
    close(wrout)

    @test "INFO  mark layout\nINFO  mark\n" == wait(reader)
end

before(render, View/ALayout) do
    Logger.info("view layout")
end

before(render, View) do
    Logger.info("view")
end

let oldout = STDERR
    rdout, wrout = redirect_stdout()

    conn = (Router)(get, "/")

    reader = @async readstring(rdout)
    redirect_stdout(oldout)
    close(wrout)

    @test "INFO  view layout\nINFO  view\n" == wait(reader)
end

end # module test_renderers_view
