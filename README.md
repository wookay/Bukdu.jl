# Bukdu 🌌

[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://wookay.github.io/docs/Bukdu.jl/)

[![Travis CI](https://api.travis-ci.org/wookay/Bukdu.jl.svg?branch=sevenstars)](https://travis-ci.org/wookay/Bukdu.jl)


Bukdu 🌌 is a web development framework for Julia (https://julialang.org).

It's influenced by Phoenix framework (http://phoenixframework.org).

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
