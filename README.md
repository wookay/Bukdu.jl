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

# Bukdu.stop()
```
