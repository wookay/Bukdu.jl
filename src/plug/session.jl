# module Bukdu.Plug

immutable Session
end


module SessionData

import ....Bukdu: Conn
import HttpCommon: Cookie

immutable CookieOven
    cookie::Cookie
    expires::DateTime
end

ovens = Dict{String,CookieOven}()

function expired_cookies(t::DateTime)::Vector{String}
    keys = Vector{String}()
    for (k,oven) in ovens
        oven.expires < t && push!(keys, k)
    end
    keys
end

# periodically delete expired cookies
function delete_expired_cookies!(t::DateTime)
    for k in expired_cookies(t)
        delete!(ovens, k)
    end
end

function has_cookie(cook::String)::Bool
    haskey(ovens, cook)
end

function get_cookie(cook::String)::Cookie
    ovens[cook].cookie
end

function set_cookie(cookie::Cookie)::String
    cook = cookie.value
    ovens[cook] = CookieOven(cookie, Dates.now() + Dates.Hour(1))
    cook
end

function delete_cookie!(cook::String)
    delete!(ovens, cook)
end

end # module Bukdu.Plug.SessionData
