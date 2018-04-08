module test_bukdu_plugs_conn

using Test
import HTTP
import Dates: DateTime

@testset "cookies" begin
    req = HTTP.Messages.Request()
    z = HTTP.Cookies.Cookie("special-2", "z")
    HTTP.Messages.setheader(req, "Cookie" => String(z))
    @test HTTP.Messages.header(req.headers, "Cookie") == "special-2=z"
    cookies = HTTP.Cookies.cookies(req)
    @test cookies isa Vector{HTTP.Cookies.Cookie}
    @test first(cookies) == z
    cookies = HTTP.Cookies.readcookies(req.headers, "special-2")
    @test first(cookies) == z

    expires_at = DateTime(2021,06,09, 10,18,14)
    resp_cookie = HTTP.Cookies.Cookie("theme", "light", expires=expires_at)
    HTTP.Messages.setheader(req.response, "Set-Cookie" => String(resp_cookie, false))
    @test HTTP.Messages.header(req.response.headers, "Set-Cookie") == "theme=light; Expires=Wed, 09 Jun 2021 10:18:14 GMT"
end

end # module test_bukdu_plugs_conn
