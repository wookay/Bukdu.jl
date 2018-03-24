# Bukdu.jl

Bukdu 🌌  is a web development framework for [Julia](https://julialang.org).

It's influenced by [Phoenix framework](http://phoenixframework.org).

```julia
using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)
```
