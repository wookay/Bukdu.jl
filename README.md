# Bukdu.jl 🌌

|  **Documentation**                        |  **Build Status**                                                  |
|:-----------------------------------------:|:------------------------------------------------------------------:|
|  [![][docs-latest-img]][docs-latest-url]  |  [![][actions-img]][actions-url]  [![][codecov-img]][codecov-url]  |


`Bukdu.jl` is a web development framework for [Julia](https://julialang.org).

It's influenced by [Phoenix framework](https://phoenixframework.org).

 * ☕️   You can [make a donation](https://wookay.github.io/donate/) to support this project.


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

![hello.svg](https://wookay.github.io/docs/Bukdu.jl/assets/bukdu/hello.svg)


[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://wookay.github.io/docs/Bukdu.jl/

[actions-img]: https://github.com/wookay/Bukdu.jl/workflows/CI/badge.svg
[actions-url]: https://github.com/wookay/Bukdu.jl/actions

[codecov-img]: https://codecov.io/gh/wookay/Bukdu.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/wookay/Bukdu.jl/branch/master
