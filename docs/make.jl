using Documenter, Bukdu
using Bukdu.HTML5.Form

makedocs(
    build = joinpath(@__DIR__, "local" in ARGS ? "build_local" : "build"),
    modules = [Bukdu],
    clean = false,
    format = :html,
    sitename = "Bukdu.jl 🌌",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
        "controllers" => "controllers.md", # ApplicationController Conn
        "renders" => "renders.md", # render Render
        "Router" => "Router.md", # Router
        "Actions" => "Actions.md", # Actions
        "HTML5.Form" => "HTML5/Form.md", # HTML5.Form
    ],
    html_prettyurls = !("local" in ARGS),
)
