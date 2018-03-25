using Documenter, Bukdu

makedocs(
    build = joinpath(@__DIR__, "local" in ARGS ? "build_local" : "build"),
    modules = [Bukdu],
    clean = false,
    format = :html,
    sitename = "Bukdu.jl 🌌",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
        "HTML5.Form" => "HTML5/Form.md",
    ],
    html_prettyurls = !("local" in ARGS),
)
