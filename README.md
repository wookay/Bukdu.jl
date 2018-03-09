# Bukdu 🌌

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

### Rendering JSON

```julia
using Octo.Adapters.SQLite

Repo.config(
    adapter = Octo.Adapters.SQLite,
    database = joinpath(@__DIR__, "test.sqlite")
)

struct User
    name::String
end

Schema.model(User, table_name="users", primary_key="id")

struct UserController <: ApplicationController
    conn::Conn
end

function index(::UserController)
    render(JSON, Repo.all(User))
end

function show(c::UserController)
    render(JSON, Repo.get(User, c.params.id))
end

Router() do
    resources("/users", UserController, only=[index, show])
end
```
