importall Bukdu

type ViewController <: ApplicationController
end

layout(::Layout, body, options) = "<html><body>$body<body></html>"

show(::ViewController) = render(View; path="page.tpl", contents="hello")
index(::ViewController) = render(View/Layout; path="page.tpl", contents="hello")

Router() do
    get("/hey", ViewController, show)
    get("/", ViewController, index)
end


using Base.Test
conn = (Router)(show, "/hey")
@test 200 == conn.status
@test "<div>hello</div>" == conn.resp_body

conn = (Router)(index, "/")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body

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
