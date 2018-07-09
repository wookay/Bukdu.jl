# Bukdu 🌌

|  **Documentation**                        |  **Build Status**                                                                                 |
|:-----------------------------------------:|:-------------------------------------------------------------------------------------------------:|
|  [![][docs-latest-img]][docs-latest-url]  |  [![][travis-img]][travis-url] [![][appveyor-img]][appveyor-url] [![][codecov-img]][codecov-url]  |


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

![hello.svg](https://wookay.github.io/docs/Bukdu.jl/assets/bukdu/hello.svg)


### Bukdu versions
  - Bukdu v0.2.0 for Julia 0.6 (https://github.com/wookay/Bukdu.jl/tree/v0.2.0)
  - Bukdu v0.3.0 for Julia 0.7 (https://github.com/wookay/Bukdu.jl/tree/v0.3.0)


### RESTful API Demo

Visit [Bukdu on Heroku](https://sevenstars.herokuapp.com)
and check its [source code](https://github.com/wookay/heroku-sevenstars).
(A sleeping heroku page, it will become active again after a short delay.)


### Modifying actions at runtime

```sh
Bukdu/examples $ julia -i welcome.jl
               _
   _       _ _(_)_     |  A fresh approach to technical computing
  (_)     | (_) (_)    |  Documentation: https://docs.julialang.org
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 0.7.0-beta.3 (2018-06-24 10:12 UTC)
 _/ |\__'_|_|_|\__'_|  |  Commit c4d24e60f1* (0 days old master)
|__/                   |  x86_64-apple-darwin17.4.0

INFO: Bukdu Listening on: 127.0.0.1:8080
julia> function index(c::WelcomeController)
           render(JSON, "Love")
       end
index (generic function with 1 method)
```
That's it! Refresh your page of the web browser.


### Requirements

The project has reworked based on [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) in [Julia 0.7 beta](https://julialang.org/downloads/nightlies.html).

`julia>` type `]` key

```julia
(v0.7) pkg> add Bukdu
```



[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://wookay.github.io/docs/Bukdu.jl/

[travis-img]: https://api.travis-ci.org/wookay/Bukdu.jl.svg?branch=master
[travis-url]: https://travis-ci.org/wookay/Bukdu.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/v1af95637qm7j582/branch/master?svg=true
[appveyor-url]: https://ci.appveyor.com/project/wookay/bukdu-jl/branch/master

[codecov-img]: https://codecov.io/gh/wookay/Bukdu.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/wookay/Bukdu.jl/branch/master
