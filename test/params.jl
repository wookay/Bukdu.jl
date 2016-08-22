importall Bukdu

type WelcomeController <: ApplicationController
end

show(c::WelcomeController) = join(c[:query_params])

Router() do
    get("/:page", WelcomeController, show)
end


using Base.Test
conn = (Router)(show, "/1?q=Julia")
@test 200 == conn.status
@test "\"q\"=>\"Julia\"" == conn.resp_body
@test Dict("page"=>"1") == conn.params
@test Dict("q"=>"Julia") == conn.query_params
