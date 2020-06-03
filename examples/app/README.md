### Building an executable

  * https://github.com/JuliaLang/PackageCompiler.jl

  * `]` key
```julia
(v1.1) pkg> add PackageCompiler
```

#### Create App (executable)
```julia
using PackageCompiler
DIR_PATH = @__DIR__
APP_PATH = joinpath(DIR_PATH; "compiled")
PackageCompiler.create_app(DIR_PATH, APP_PATH; force=true)
```

#### Run App
- `Windows`

   Open command windows in `examples\app\compiled\bin` and run
   ```cmd
   ...\bin>start Hello
   ```

- `Linux`
   ```sh
   $ nohup ./bin/Hello &
   [1] 1488
   appending output to nohup.out

   $ tail nohup.out
   Bukdu Listening on 127.0.0.1:8080

   $ jobs -l
   [1]  + 1488 running    nohup ./builddir/hello

   $ kill -9 1488
   ```

#### Communication with Server
```julia
using HTTP
res = HTTP.HTTP.request("GET",
    "http://localhost:8080/")
```
