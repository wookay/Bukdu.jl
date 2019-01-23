module test_bukdu_plugs_contentparsers_json

using Test
using JSON2
using Bukdu
using .Bukdu.Plug.ContentParsers

buf = IOBuffer(JSON2.write((k=1,)))
@test ContentParsers.parse(ContentParsers.MergedJSON, buf) == Pair{String,Any}["k"=>1]

buf = IOBuffer(JSON2.write((k=1,)))
@test ContentParsers.parse(ContentParsers.JSONDecoder, buf) == Pair{String,Any}["json"=>(k=1,)]

end


module test_bukdu_plugs_contentparsers_urlencoded_multipart

using Test
using Bukdu
using .Bukdu.Deps
using .Bukdu.Plug.ContentParsers

struct FC <: ApplicationController; conn::Conn; end

function urlencoded(c::FC)
    c.params.q
end

function multipart(c::FC)
    c.params
end

routes() do
    post("/urlencoded", FC, urlencoded)
    post("/multipart", FC, multipart)
end

req = Deps.HTTP.Request(
    "POST",
    "/urlencoded",
    ["Content-Type"=>"application/x-www-form-urlencoded", "Content-Length"=>"3"],
    codeunits("q=5")
)
@test Router.call(req).got == "5"


req = Deps.HTTP.Request(
    "POST",
    "/multipart",
    ["Content-Type"=>"multipart/form-data; boundary=boundary"],
    codeunits("""
--boundary
Content-Disposition: form-data; name="field1"

value1
--boundary
Content-Disposition: form-data; name="field2"; filename="example.txt"

value2
--boundary--""")
)
@test Router.call(req).got == Assoc("field1"=>"value1", "field2"=>"value2")


req = Deps.HTTP.Request(
    "POST",
    "/multipart",
    ["Content-Type"=>"multipart/form-data; boundary=boundary"],
    codeunits("""
--boundary
Content-Disposition: form-data; name="field1"

value1
--boundary
Content-Disposition: form-data; name="field2"; filename="example.txt"
Content-Type: text/plain

value2
--boundary--""")
)
@test Router.call(req).got == Assoc("field1"=>"value1", "field2"=>"value2")

req = Deps.HTTP.Request(
    "POST",
    "/multipart",
    ["Content-Type"=>"multipart/form-data; boundary=----WebKitFormBoundaryLeFS8sRvPzeszrWy"],
    codeunits("""
------WebKitFormBoundaryLeFS8sRvPzeszrWy\r\nContent-Disposition: form-data; name=\"user_name\"\r\n\r\n\r\n------WebKitFormBoundaryLeFS8sRvPzeszrWy\r\nContent-Disposition: form-data; name=\"user_famous\"\r\n\r\nfalse\r\n------WebKitFormBoundaryLeFS8sRvPzeszrWy--\r\n""")
)
@test Router.call(req).got == Assoc("user_name"=>"", "user_famous"=>"false")

Routing.empty!()


@test  ContentParsers.rstripcrlf([0x0d, 0x0a]) == []      # CR LF
@test  ContentParsers.rstripcrlf([0x0d])       == [0x0d]  # CR

end # module test_bukdu_plugs_contentparsers_urlencoded_multipart
