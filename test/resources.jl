module test_resources

using Test
using Bukdu
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

Router() do
    # resources("/articles", ArticleController)
    resources("/articles", ArticleController, only=[index, show])
    # resources("/articles", ArticleController, except=[index, show])
end

@test (Router)(get, "/articles") == (:index,)
@test (Router)(get, "/articles/2") == (:show, "2")

end # module test_resources
