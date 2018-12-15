# https://discourse.julialang.org/t/write-a-rest-interface-like-flask/18538

# Bukdu v0.3.4
using Bukdu

struct RestController <: ApplicationController
    conn::Conn
end

function init(c::RestController, region::String, site_id::Int, channel_id::Int)
    render(JSON, (:init, region, site_id, channel_id))
end

function update(c::RestController, region::String, site_id::Int, channel_id::Int)
    render(JSON, (:update, region, site_id, channel_id))
end

function build_params(c::RestController)
    region::String = c.params.region
    site_id::Int, channel_id::Int = parse.(Int, (c.params.site_id, c.params.channel_id))
    (c, region, site_id, channel_id)
end

init(c::RestController) = init(build_params(c)...)
update(c::RestController) = update(build_params(c)...)

routes() do
    get("/init/region/:region/site/:site_id/channel/:channel_id/", RestController, init)
    get("/update/region/:region/site/:site_id/channel/:channel_id/", RestController, update)
end

Bukdu.start(8080)

#=
curl localhost:8080/init/region/west/site/1/channel/2/
curl localhost:8080/update/region/west/site/1/channel/2/
=#
