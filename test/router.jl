using Base.Test
using Bukdu

type PageController <: ApplicationController
end

show(::PageController) = "hello"
index(::PageController) = "hi hello"


type Router <: ApplicationRouter
end

Router() do
    get("/pages", PageController, index)
    get("/pages/:page", PageController, show)
end

conn = (Router)(index, "/pages")
@test conn.status == 200
@test conn.resp_body == "hi hello"

conn = (Router)(show, "/pages/1")
@test conn.status == 200
@test conn.resp_body == "hello"
@test conn.params["page"] == "1"

conn = (Router)(show, "/user/1")
@test conn.status == 404
