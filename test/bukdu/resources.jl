module test_bukdu_resources

using Test
using Bukdu # ApplicationController Conn Router Utils routes resources
import Bukdu.Actions: index, show, new, edit, create, delete, update

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
    resources("/articles", ArticleController)
    # resources("/articles", ArticleController, only=[index, show])
    # resources("/articles", ArticleController, except=[index, show])
end

@test Router.request(get, "/articles")   == (:index,)
@test Router.request(get, "/articles/2") == (:show, "2")

@test Utils.read_stdout(CLI.routes) == """
GET     /articles           ArticleController  index   
GET     /articles/new       ArticleController  new     
GET     /articles/:id/edit  ArticleController  edit    
GET     /articles/:id       ArticleController  show    
POST    /articles           ArticleController  create  
DELETE  /articles/:id       ArticleController  delete  
PATCH   /articles/:id       ArticleController  update  
PUT     /articles/:id       ArticleController  update"""

Routing.empty!()

end # module test_bukdu_resources
