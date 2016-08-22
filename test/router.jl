importall Bukdu

type PageController <: ApplicationController
end

show(::PageController) = "hello"
index(::PageController) = "hi hello"

Router() do
    get("/pages", PageController, index)
    get("/pages/:page", PageController, show)
end


using Base.Test
conn = (Router)(index, "/pages")
@test conn.status == 200
@test conn.resp_body == "hi hello"

conn = (Router)(show, "/pages/1")
@test conn.status == 200
@test conn.resp_body == "hello"
@test conn.params["page"] == "1"

conn = (Router)(show, "/user/1")
@test conn.status == 404

reset(Router)
conn = (Router)(index, "/pages")
@test conn.status == 404

Router() do
    get("/pages", PageController, index)
end
conn = (Router)(index, "/pages")
@test conn.status == 200
