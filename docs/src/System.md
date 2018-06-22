# Bukdu.System

```@docs
Bukdu.System.halted_error
Bukdu.System.not_applicable
Bukdu.System.internal_error
Bukdu.System.not_found
```

### Debugging the requests and responses on the fly

Bukdu provides a way to catch the requests and responses.

```julia-repl
julia> Bukdu.System.catch_request(route::Bukdu.Route, req) = @debug "REQ " req.headers
julia> Bukdu.System.catch_response(route::Bukdu.Route, resp) = @debug "RESP" resp.headers resp.status
```

```@docs
Bukdu.System.catch_request
Bukdu.System.catch_response
```
