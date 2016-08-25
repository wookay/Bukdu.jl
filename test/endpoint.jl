import Bukdu: Endpoint

Bukdu.config(
        url= (:host => "example.com", :path => "/api"),
        static_url= (:host => "static.example.com"),
        http= (:port => 80),
        https= (:port => 443))


using Base.Test
@test Endpoint[:url] == Dict(:host=>"example.com", :path=>"/api")
@test Endpoint[:static_url] == Dict(:host=>"static.example.com")
