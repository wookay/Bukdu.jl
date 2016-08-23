# parent module Bukdu

importall Bukdu

type ViewController <: ApplicationController
end

layout(::Layout, body, options) = "<html><body>$body<body></html>"

show(::ViewController) = render(View; path="page.tpl", contents="hello")
index(::ViewController) = render(View/Layout; path="page.tpl", contents="hello")

Router() do
    get("/", ViewController, show)
    get("/", ViewController, index)
end


using Base.Test
conn = (Router)(index, "/")
@test 200 == conn.status
@test "<html><body><div>hello</div><body></html>" == conn.resp_body

conn = (Router)(show, "/")
@test 200 == conn.status
@test "<div>hello</div>" == conn.resp_body
