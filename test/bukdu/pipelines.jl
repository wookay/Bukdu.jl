module test_bukdu_pipelines

using Test # @test
using Bukdu # Plug.AbstractPlug Conn Routing pipeline plug routes get

struct CSRF <: Plug.AbstractPlug
end

function plug(::Type{CSRF}, conn::Conn)
    conn.private[:csrf] = 1
end

struct Auth <: Plug.AbstractPlug
end

function plug(::Type{Auth}, conn::Conn)
    conn.private[:auth] = 2
end

pipeline(:web, :auth) do conn::Conn
    plug(CSRF, conn)
end

pipeline(:auth) do conn::Conn
    plug(Auth, conn)
end

struct W <: ApplicationController; conn::Conn end
struct A <: ApplicationController; conn::Conn end
index(w::W) = keys(w.conn.private)
index(a::A) = values(a.conn.private)

routes(:web) do
    get("/w", W, index)
end

routes(:auth) do
    get("/a", A, index)
end

@test Router.call(get, "/w").got == ["csrf"]
@test Router.call(get, "/a").got == [1, 2]

@test Utils.read_stdout(CLI.routes) == """
GET  /w  W  index  :web
GET  /a  A  index  :auth"""

Routing.empty!()


### halted
struct HaltedAuth <: Plug.AbstractPlug
end

function plug(::Type{HaltedAuth}, conn::Conn)
    conn.request.response.status = 401 # 401 Unauthorized
    conn.halted = true
end

pipeline(:halted_auth) do conn::Conn
    plug(HaltedAuth, conn)
end

routes(:halted_auth) do
    get("/ha", A, index)
end
result = Router.call(get, "/ha")
@test result.route.action === Bukdu.System.halted_error
@test result.resp.status == 401

Routing.empty!()

end # module test_bukdu_pipelines
