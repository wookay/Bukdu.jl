# Bukdu.Runtime

Debugging the requests and responses on the fly.

```julia-repl
julia> Bukdu.Runtime.catch_request(route::Bukdu.Route, req) = @debug "REQ " req.headers
julia> Bukdu.Runtime.catch_response(route::Bukdu.Route, resp) = @debug "RESP" resp.headers String(resp.body)
```

```@docs
Bukdu.Runtime.catch_request
Bukdu.Runtime.catch_response
```
