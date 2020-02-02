module test_bukdu_options

using Test
using Bukdu
using Bukdu: options
using HTTP.Messages: setheader, header

struct IndexController <: ApplicationController
    conn::Conn
end

function index(c::IndexController)
    setheader(c.conn.request.response, "Allow" => "OPTIONS, GET, HEAD, POST")
    nothing
end

routes() do
    options("/", IndexController, index)
end

result = Router.call(options, "/")
@test result.resp.status == 200
@test header(result.resp.headers, "Allow") == "OPTIONS, GET, HEAD, POST"
@test result.got === nothing

result = Router.call(get, "/")
@test result.resp.status == 404

Routing.reset!()

end # module test_bukdu_options
