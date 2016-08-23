import Bukdu: set, Endpoint

Bukdu.config(
    set(
        url = set(host="example.com", path="/api"),
        static_url = set(host="static.example.com"),
        http = set(port=80),
        https = set(port=443)))


using Base.Test
@test Endpoint.config(:url) == Dict(:host=>"example.com", :path=>"/api")
@test Endpoint.config(:static_url) == Dict(:host=>"static.example.com")
