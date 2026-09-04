# module Bukdu

import .HT: get, post, delete, patch, put, options, query
using .HT: head

const routing_verbs = [get, post, delete, patch, put, options, query]

struct AnonymousController <: ApplicationController
    conn::Conn
end

for routing_verb in routing_verbs
    verb::Symbol = nameof(routing_verb)
    method = (uppercase ∘ String)(verb)

    @eval function $verb(path::String, ::Type{C}, action) where C <: ApplicationController
        HT.register!(bukdu_router[], $method, path, (C, action))
    end

    if verb ∈ (:get, :post)
        @eval function $verb(f, path::String)
            action = c -> f(c.conn)
            HT.register!(bukdu_router[], $method, path, (AnonymousController, action))
        end
    end
end # for

function routes(f)
    middleware = Middleware()
    bukdu_router[] = HT.Router(HT.Handlers.default404, HT.Handlers.default405, middleware)
    f()
end
