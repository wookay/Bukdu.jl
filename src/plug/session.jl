# module Bukdu.Plug

immutable Session
end

const bukdu_cookie_id = "bukdu_cookie"

module SessionData

immutable Oven
    cookies::Dict{String,String}
    expires::DateTime
end

stores = Dict{String,Oven}()

function expired_cookies()::Vector{String}
    t = Dates.now()
    keys = Vector{String}()
    for (k,oven) in stores
        oven.expires < t && push!(keys, k)
    end
    keys
end

function delete_cookie(cook::String)
    delete!(stores, cook)
end

# periodically delete expired cookies
function delete_expired_cookies!()
    for k in expired_cookies()
        delete!(stores, k)
    end
end

function has_cookie(cook::String)::Bool
    haskey(stores, cook)
end

function get_cookie(cook::String)::Dict{String,String}
    stores[cook].cookies
end

function store_cookies(cookies::Dict{String,String})::String
    cook = string(Base.Random.uuid1())
    stores[cook] = Oven(cookies, Dates.now() + Dates.Hour(1))
    cook
end

end # module Bukdu.Plug.SessionData

import ..Conn

function put_session(conn::Conn, key::Symbol, value)
end
