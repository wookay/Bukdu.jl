importall Bukdu

type ArticleController <: ApplicationController
end

index(::ArticleController)   = (:index,)
show(c::ArticleController)   = (:show, c[:params][:id])
new(::ArticleController)     = (:new,)
edit(c::ArticleController)   = (:edit, c[:params][:id])
create(::ArticleController)  = (:create,)
delete(c::ArticleController) = (:delete, c[:params][:id])
update(c::ArticleController) = (:update, c[:params][:id])

Router() do
    resources("/articles", ArticleController)
end


using Base.Test

conn = (Router)(get, "/articles")
@test conn.resp_body == (:index,)

conn = (Router)(get, "/articles/1")
@test conn.resp_body == (:show, "1")

conn = (Router)(get, "/articles/new")
@test conn.resp_body == (:new,)

conn = (Router)(get, "/articles/1/edit")
@test conn.resp_body == (:edit, "1")

conn = (Router)(post, "/articles")
@test conn.resp_body == (:create,)

conn = (Router)(delete, "/articles/1")
@test conn.resp_body == (:delete, "1")

conn = (Router)(patch, "/articles/1")
@test conn.resp_body == (:update, "1")

conn = (Router)(put, "/articles/1")
@test conn.resp_body == (:update, "1")
