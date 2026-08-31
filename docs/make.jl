using Documenter
using Bukdu

makedocs(
    build = joinpath(@__DIR__, "local" in ARGS ? "build_local" : "build"),
    modules = [Bukdu],
    clean = false,
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        assets = ["assets/custom.css"],
    ),
    sitename = "Bukdu.jl 🌌",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
        "server" => "server.md",           # Bukdu.start Bukdu.stop
        "render" => "render.md",           # render
        "routes" => "routes.md",           # routes
        "Actions" => "Actions.md",         # Actions
    ],
)
