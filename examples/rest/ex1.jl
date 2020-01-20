# https://discourse.julialang.org/t/write-a-rest-interface-like-flask/18538

# Bukdu v0.4.2
using Bukdu

struct RestController <: ApplicationController
    conn::Conn
end

function init(c::RestController)
    render(JSON, (:init, c.params.region, c.params.site_id, c.params.channel_id))
end

function update(c::RestController)
    render(JSON, (:update, c.params.region, c.params.site_id, c.params.channel_id))
end

routes() do
    get("/init/region/:region/site/:site_id/channel/:channel_id/", RestController, init, :site_id=>Int, :channel_id=>Int)
    get("/update/region/:region/site/:site_id/channel/:channel_id/", RestController, update, :site_id=>Int, :channel_id=>Int)
end

Bukdu.start(8080)

#=
curl localhost:8080/init/region/west/site/1/channel/2/
curl localhost:8080/update/region/west/site/1/channel/2/
=#
