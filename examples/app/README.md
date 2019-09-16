### Building an executable

  * https://github.com/JuliaLang/PackageCompiler.jl#building-an-executable

  * `]` key
```julia
(v1.1) pkg> dev PackageCompiler
```

```sh
$ julia ~/.julia/dev/PackageCompiler/juliac.jl -vae hello.jl

$ ./builddir/hello
Bukdu Listening on 127.0.0.1:8080
```

```sh
$ nohup ./builddir/hello &
[1] 1488
appending output to nohup.out

$ tail nohup.out
Bukdu Listening on 127.0.0.1:8080

$ jobs -l
[1]  + 1488 running    nohup ./builddir/hello

$ kill -9 1488
```
