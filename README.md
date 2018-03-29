# Bukdu 🌌

|  **Documentation**                        |  **Build Status**                                                 |
|:-----------------------------------------:|:-----------------------------------------------------------------:|
|  [![][docs-latest-img]][docs-latest-url]  |  [![][travis-img]][travis-url] [![][appveyor-img]][appveyor-url]  |


Bukdu 🌌 is a web development framework for Julia (https://julialang.org).

It's influenced by Phoenix framework (http://phoenixframework.org).

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


### REST API Demo

Visit [Bukdu sevenstars on Heroku](https://sevenstars.herokuapp.com)
and check its [source code](https://github.com/wookay/heroku-sevenstars).
(A sleeping heroku page, it will become active again after a short delay.)


### Requirements

The project has reworked based on [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) in [Julia 0.7 DEV](https://julialang.org/downloads/nightlies.html).

```julia
using Pkg
Pkg.clone("https://github.com/wookay/Bukdu.jl.git")
Pkg.checkout("Bukdu", "sevenstars")
```



[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://wookay.github.io/docs/Bukdu.jl/

[travis-img]: https://api.travis-ci.org/wookay/Bukdu.jl.svg?branch=sevenstars
[travis-url]: https://travis-ci.org/wookay/Bukdu.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/v1af95637qm7j582/branch/sevenstars?svg=true
[appveyor-url]: https://ci.appveyor.com/project/wookay/bukdu-jl/branch/sevenstars
