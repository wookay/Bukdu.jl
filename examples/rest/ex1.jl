# https://discourse.julialang.org/t/write-a-rest-interface-like-flask/18538

# Bukdu v0.3.4
using Bukdu

struct RestController <: ApplicationController
    conn::Conn
end

function init(c::RestController)
    region::String = c.params.region
    site_id::Int, channel_id::Int = parse.(Int, (c.params.site_id, c.params.channel_id))
    render(JSON, (region, site_id, channel_id))
end

function update(c::RestController)
    region::String = c.params.region
    site_id::Int, channel_id::Int = parse.(Int, (c.params.site_id, c.params.channel_id))
    render(JSON, (region, site_id, channel_id))
end

routes() do
    get("/init/region/:region/site/:site_id/channel/:channel_id/", RestController, init)
    get("/update/region/:region/site/:site_id/channel/:channel_id/", RestController, update)
end

Bukdu.start(8080)
