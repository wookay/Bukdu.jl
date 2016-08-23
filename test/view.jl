importall Bukdu

type ViewController <: ApplicationController
end

type Layout
end
layout(::Layout, body, options) = "<html><body>$body<body></html>"
index(::ViewController) = render(View{Layout}, "page.tpl"; contents="hello")

Router() do
    get("/", ViewController, index)
end


using Base.Test
conn = (Router)(index, "/")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body

logs = []
Bukdu.before(::View) = push!(logs, :b)
Bukdu.after(::View) = push!(logs, :a)
conn = (Router)(index, "/")
@test [:b, :a] == logs

conn = (Router)(index, "/")
@test [:b, :a, :b, :a] == logs

@test "<div>hello</div>" == render(View, "page.tpl"; contents="hello")
@test "<html><body><div>hello</div><body></html>" == render(View{Layout}, "page.tpl"; contents="hello")
