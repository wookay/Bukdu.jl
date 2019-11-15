module test_bukdu_resources

using Test
using Bukdu # ApplicationController Conn Router Utils routes resources
import .Bukdu.Actions: index, show, new, edit, create, delete, update

struct ArticleController <: ApplicationController
    conn::Conn
end

index(::ArticleController)   = (:index,)
show(c::ArticleController)   = (:show, c.params.id)
new(::ArticleController)     = (:new,)
edit(c::ArticleController)   = (:edit, c.params.id)
create(::ArticleController)  = (:create,)
delete(c::ArticleController) = (:delete, c.params.id)
update(c::ArticleController) = (:update, c.params.id)

routes() do
    resources("/articles", ArticleController, :id=>Int)
end

@test Router.call(get, "/articles").got   == (:index,)
@test Router.call(get, "/articles/2").got == (:show, 2)

@test Utils.read_stdout(CLI.routes) == """
GET     /articles           ArticleController  index
GET     /articles/new       ArticleController  new
GET     /articles/:id/edit  ArticleController  edit
GET     /articles/:id       ArticleController  show
POST    /articles           ArticleController  create
DELETE  /articles/:id       ArticleController  delete
PATCH   /articles/:id       ArticleController  update
PUT     /articles/:id       ArticleController  update"""

Router.call(delete, "/articles/1")
Router.call(patch, "/articles/1")
Router.call(put, "/articles/1")

Routing.empty!()


routes() do
    resources("/articles", ArticleController, only=[index, show])
end
@test Utils.read_stdout(CLI.routes) == """
GET  /articles      ArticleController  index
GET  /articles/:id  ArticleController  show"""
Routing.empty!()


routes() do
    resources("/articles", ArticleController, :id=>Int, except=[new, edit, create, delete, update])
end
@test Utils.read_stdout(CLI.routes) == """
GET  /articles      ArticleController  index
GET  /articles/:id  ArticleController  show"""


result = Router.call(Bukdu.head, "/articles/1")
@test result.resp.status == 301
@test result.got === nothing
@test result.route.action === show
@test result.route.param_types == Dict(:id=>Int)
@test result.route.path_params == ["id"=>"1"]

Routing.empty!()

end # module test_bukdu_resources
