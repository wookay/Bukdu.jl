importall Bukdu

type WelcomeController <: ApplicationController
end

show(c::WelcomeController) = [c[:query_params], c[:params]]

Router() do
    get("/:page", WelcomeController, show)
end


using Base.Test
conn = (Router)(get, "/1?q=Julia")
@test 200 == conn.status
@test [Dict("q"=>"Julia"), Dict("page"=>"1")] == conn.resp_body
@test Dict("q"=>"Julia") == conn.query_params
@test Dict("page"=>"1") == conn.params
