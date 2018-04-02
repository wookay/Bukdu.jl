module test_bukdu_pipelines

using Test # @test
using Bukdu # Plug.AbstractPlug Conn Routing pipeline plug routes get

struct CSRF <: Plug.AbstractPlug
end

function plug(::Type{CSRF}, conn::Conn)
    conn.params[:csrf] = "1"
end

struct Auth <: Plug.AbstractPlug
end

function plug(::Type{Auth}, conn::Conn)
    conn.params[:auth] = "1"
end

pipeline(:web, :auth) do conn::Conn
    plug(CSRF, conn)
end

pipeline(:auth) do conn::Conn
    plug(Auth, conn)
end

struct W <: ApplicationController; conn::Conn end
struct A <: ApplicationController; conn::Conn end
index(w::W) = keys(w.params)
index(a::A) = keys(a.params)

routes(:web) do
    get("/w", W, index)
end

routes(:auth) do
    get("/a", A, index)
end

@test Router.call(get, "/a").got == ["csrf", "auth"]
@test Router.call(get, "/w").got == ["csrf"]

@test Utils.read_stdout(CLI.routes) == """
GET  /w  W  index  :web
GET  /a  A  index  :auth"""

Routing.empty!()

end # module test_bukdu_pipelines
