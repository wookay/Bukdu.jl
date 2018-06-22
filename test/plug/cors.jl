module test_plug_cors

importall Bukdu
import Requests # Requests.options
import Requests: URI
import Base.Test: @test, @test_throws

type UserController <: ApplicationController
    conn::Conn
end

index(::UserController) = nothing

Router() do
    get("/", UserController, index)
end

Endpoint() do
    plug(Plug.CORS)
    plug(Router)
end


Logger.set_level(:error)

port = Bukdu.start(:any)

@test Requests.head(URI("http://localhost:$port/")).status == 200
@test Requests.options(URI("http://localhost:$port/"), headers=Dict("Origin" => "http://localhost")).status == 204 # :no_content

Endpoint() do
    plug(Plug.CORS, allow_origin=["http://github.com"])
    plug(Router)
end

reload(Endpoint)

@test Requests.head(URI("http://localhost:$port/")).status == 200
@test Requests.options(URI("http://localhost:$port/"), headers=Dict("Origin" => "http://localhost")).status == 405 # :method_not_allowed
@test Requests.options(URI("http://localhost:$port/"), headers=Dict("Origin" => "http://github.com")).status == 204 # :no_content

sleep(0.1)
Bukdu.stop()

end # module test_plug_cors
