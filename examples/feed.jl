"""
```

# get a feed
\$ curl http://localhost:8080/v2.8/me/feed

# reading
\$ curl http://localhost:8080/v2.8/10152089774156129_1015392390403110

# updating
\$ curl -X POST -d "message=foo bar" http://localhost:8080/v2.8/10152089774156129_1015392390403110

# deleting
\$ curl -X DELETE http://localhost:8080/v2.8/10152089774156129_1015392390403110

# publishing
\$ curl -X POST -d "message=hello world" http://localhost:8080/v2.8/me/feed

# publishing : message is empty
\$ curl -X POST http://localhost:8080/v2.8/me/feed

```
"""
module V28

importall Bukdu
import JSON

type UserController <: ApplicationController
    conn::Conn
end

posts = [
    Dict("story" => "shared a link", "created_time" => "2016-10-10T11:46:16+0000", "id" => "10152089774156129_1015392390403110"),
    Dict("message" => "chord tracker", "created_time" => "2016-10-11T11:46:16+0000", "id" => "10152089774156129_1015392390403111"),
    Dict("message" => "yak shaving", "created_time" => "2016-10-12T11:46:16+0000", "id" => "10152089774156129_1015392390403112")
]

feed(::UserController) = render(JSON,
    Dict(
        "data" => posts,
        "paging" => Dict(
            "previous" => "/v2.8/1015208977415612/feed?format=json&since=1476359176&limit=25&&__previous=1",
            "next" => "/v2.8/1015208977415612/feed?format=json&&limit=25&until=1471951272"
        )
    )
)
after(c::UserController) = Logger.info(c.conn.resp_headers["Content-Type"])

type PostController <: ApplicationController
    conn::Conn
end

function publishing(c::PostController)
    params = c[:query_params]
    if haskey(params, :message)
        message = params[:message]
        Logger.info("publishing $message")
        render(JSON, Dict("id" => "The newly created post ID"))
    else
        Logger.info("error $(c[:private][:action]) | message is empty")
        render(JSON, Dict(
            "error" => Dict(
                "message" => "message is empty",
                "type" => "GraphMethodException",
                "code" => 100
            )
        ))
    end
end

function find_post(block::Function, c::PostController)
    post_id = c[:params][:post_id]
    find_posts = filter(post->post["id"] == post_id, posts)
    if isempty(find_posts)
        Logger.info("error $(c[:private][:action]) | $post_id does not exist")
        render(JSON, Dict(
            "error" => Dict(
                "message" => "Unsupported get request. Object with ID '$post_id' does not exist",
                "type" => "GraphMethodException",
                "code" => 100
            )
        ))
    else
        post = first(find_posts)
        block(findfirst(posts, post), post)
    end
end

function reading(c::PostController)
    find_post(c) do idx,post
        Logger.info("reading $(post["id"])")
        render(JSON, post)
    end
end

function deleting(c::PostController)
    find_post(c) do idx,post
        deleteat!(posts, idx)
        Logger.info("deleting $(post["id"])")
        render(JSON, Dict(
            "success" => true
        ))
    end
end

function updating(c::PostController)
    find_post(c) do idx,post
        if haskey(c[:query_params], :message)
            post["message"] = c[:query_params][:message]
            posts[idx] = post
        end
        Logger.info("updating $(post["id"])")
        render(JSON, Dict(
            "success" => true
        ))
    end
end

function routes()
    scope("/v2.8") do
        get("/me/feed", UserController, feed)
        post("/me/feed", PostController, publishing)

        get("/:post_id", PostController, reading)
        delete("/:post_id", PostController, deleting)
        post("/:post_id", PostController, updating)
    end
end

end # module V28


importall Bukdu

Router(V28.routes)

Endpoint() do
    plug(Plug.Logger)
    plug(Router)
end

Bukdu.start(8080)

Base.JLOptions().isinteractive==0 && wait()

Bukdu.stop()
