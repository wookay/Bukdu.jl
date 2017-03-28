# Bukdu 🌌

  [![Travis CI](https://api.travis-ci.org/wookay/Bukdu.jl.svg?branch=master)](https://travis-ci.org/wookay/Bukdu.jl)
  [![CircleCI](https://circleci.com/gh/wookay/Bukdu.jl.svg?style=svg)](https://circleci.com/gh/wookay/Bukdu.jl)
  [![AppVeyor](https://ci.appveyor.com/api/projects/status/v1af95637qm7j582?svg=true)](https://ci.appveyor.com/project/wookay/bukdu-jl)
  [![Codecov](https://codecov.io/gh/wookay/Bukdu.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/wookay/Bukdu.jl)
  [![Coveralls](https://coveralls.io/repos/github/wookay/Bukdu.jl/badge.svg?branch=master)](https://coveralls.io/github/wookay/Bukdu.jl?branch=master)


Bukdu is a web development framework for Julia (http://julialang.org).

It's influenced by Phoenix framework (http://phoenixframework.org).

```julia
importall Bukdu

type WelcomeController <: ApplicationController
end

index(::WelcomeController) = "hello world"

Router() do
    get("/", WelcomeController, index)
end

Bukdu.start(8080)
```


### Endpoint

Use `Endpoint` to define the plug pipelines.

* plug `Plug.Logger` to write the event logs.
* plug `Plug.Static` to serve the static files.
* plug `Router` to give the routes into the Endpoint.

```julia
Endpoint() do
    plug(Plug.Logger)
    plug(Plug.Static, at="/", from="public")
    plug(Router)
end
```


### Working with params

Put `conn::Conn` to the controller.
Now, `params` could be accessed by indexing the controller. For example

```julia
importall Bukdu

type CalculateController <: ApplicationController
    conn::Conn
end

function my_fn(c::CalculateController)
    q = c[:params]
    x, y = map(v -> parse(Int, v), (q[:x], q[:y]))
    render(JSON, x + 2*y)
end

Router() do
    get("/my_fn", CalculateController, my_fn)
end

Bukdu.start(8080)
```

Check it by querying with parameters.
http://localhost:8080/my_fn?x=2&y=3


### Deploy on Heroku

Bukdu can be deployed on Heroku. Go to the demo site (https://bukdu.herokuapp.com).


### Jupyter notebook
* [Bukdu.ipynb](https://github.com/wookay/Bukdu.jl/blob/master/examples/jupyter/Bukdu.ipynb)
