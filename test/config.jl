import Bukdu: Endpoint

Bukdu.config(:app, Endpoint,
        http= (:port => 80),
        https= (:port => 443),
        url= (:host => "example.com", :path => "/api"),
        static_url= (:host => "static.example.com"))


using Base.Test
@test Endpoint[:url] == Dict(:host => "example.com", :path => "/api")
