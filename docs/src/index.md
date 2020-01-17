# Bukdu.jl 🌌

<https://github.com/wookay/Bukdu.jl>

`Bukdu.jl` is a web development framework for [Julia](https://julialang.org).

It's influenced by [Phoenix framework](https://phoenixframework.org).

```julia
using Bukdu

struct WelcomeController <: ApplicationController
    conn::Conn
end

function index(c::WelcomeController)
    render(asJSON, "Hello World")
end

routes() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)
```

![hello.svg](https://wookay.github.io/docs/Bukdu.jl/assets/bukdu/hello.svg)


### RESTful API Demo

There's [examples/rest](https://github.com/wookay/Bukdu.jl/tree/master/examples/rest) for RESTful API examples.

Visit [Bukdu on Heroku](https://sevenstars.herokuapp.com) and check its [source code](https://github.com/wookay/heroku-sevenstars).
(A sleeping heroku page, it will become active again after a short delay.)


### Modifying actions at runtime

```sh
Bukdu/examples $ julia -i welcome.jl
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.0.0 (2018-08-08)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/

INFO: Bukdu Listening on: 127.0.0.1:8080
julia> 
```

Visit http://127.0.0.1:8080 on your web browser.

``` julia
julia> function index(c::WelcomeController)
           render(asJSON, "Love")
       end
index (generic function with 1 method)
```

That's it! Refresh your page of the web browser.


### Requirements

The project has reworked based on [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) in [Julia 1.0](https://julialang.org/downloads/).

`julia>` type `]` key

```julia
(v1.0) pkg> add Bukdu
```
