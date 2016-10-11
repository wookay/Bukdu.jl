module test_pipeline

importall Bukdu
import Bukdu.Controller: accepts
import Base.Test: @test, @test_throws

type ContactController <: ApplicationController
end

index(::ContactController) = "ok"

Router() do
    browser = Pipeline() do conn
        plug(conn, accepts, ["html"])
        plug(conn, fetch_session)
        plug(conn, fetch_flash)
        plug(conn, protect_from_forgery)
        plug(conn, put_secure_browser_headers)
    end

    api = Pipeline() do conn
        plug(conn, accepts, ["json"])
    end

    scope("/api") do
        pipe_through(api)
        resources("/contacts", ContactController)
    end
end

Endpoint() do
    plug(Plug.Logger, level=:info)
    plug(Router)
end


conn = (Router)(get, "/api/contacts")
@test "json" == conn.private[:format]
@test index == conn.private[:action]
@test isa(conn.private[:controller], ContactController)
@test Router == conn.private[:router]
@test nothing == conn.private[:endpoint]

conn = (Endpoint)("/api/contacts")
@test "json" == conn.private[:format]
@test Router == conn.private[:router]
@test Endpoint == conn.private[:endpoint]

api = Pipeline() do conn
    accepts(conn, ["json"])
end

@test isa(api, Pipeline)

conn = Conn()

api(conn)

@test "json" == conn.private[:format]

end # module test_pipeline
