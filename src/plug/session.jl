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
    for (cook, oven) in ovens
        oven.expires < t && push!(keys, cook)
    end
    keys
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

# periodically deleting expired cookies

global next_cleaning_at = Dates.now() + Dates.Hour(1)

function set_next_cleaning_at(t::DateTime)
    global next_cleaning_at = t
end

function delete_expired_cookies(t::DateTime)
    for cook in expired_cookies(t)
        delete!(ovens, cook)
    end
    set_next_cleaning_at(t + Dates.Hour(1))
end

function hourly_cleaning_expired_cookies(t::DateTime)
    next_cleaning_at < t && delete_expired_cookies(t)
end

end # module Bukdu.Plug.SessionData
