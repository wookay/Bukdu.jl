module test_controller_params

importall Bukdu
import Bukdu.Octo: change
import Base.Test: @test, @test_throws

type WelcomeController <: ApplicationController
    conn::Conn
end

type User
    name::String
end

show(c::WelcomeController) = (c[:query_params], c[:params])
posted(c::WelcomeController) = change(c, User)

Router() do
    get("/:page", WelcomeController, show)
    post("/posted", WelcomeController, posted)
end


conn = (Router)(get, "/1?q=Julia")
@test 200 == conn.status
@test (Assoc(q="Julia"), Assoc(page="1")) == conn.resp_body
@test Assoc(q="Julia") == conn.query_params
@test "Julia" == conn.query_params["q"]
@test "Julia" == conn.query_params[:q]
@test_throws KeyError conn.query_params["none"]
@test Assoc(page="1") == conn.params
@test "1" == conn.params["page"]
@test "1" == conn.params[:page]

conn = (Router)(post, "/posted", user_name="jack", q="Julia")
@test Assoc([(:user_name,"jack"),(:q,"Julia")]) == conn.query_params

end # test_controller_params
