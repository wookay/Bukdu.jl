importall Bukdu
import Bukdu.Controller: accepts

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
    plug(Plug.CSRFProtection)
    plug(Router)
end


using Base.Test

conn = (Router)(get, "/api/contacts")
@test "json" == conn.private[:format]


api = Pipeline() do conn
    accepts(conn, ["json"])
end

@test isa(api, Pipeline)

conn = Conn()

api(conn)

@test "json" == conn.private[:format]
