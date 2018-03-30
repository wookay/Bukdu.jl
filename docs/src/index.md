# Bukdu.jl

Bukdu 🌌  is a web development framework for [Julia](https://julialang.org).

It's influenced by [Phoenix framework](http://phoenixframework.org).

```julia
using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    render(JSON, "Hello World")
end

routes() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)
```
