using Documenter
using Bukdu
using Bukdu.HTML5.Form

makedocs(
    build = joinpath(@__DIR__, "local" in ARGS ? "build_local" : "build"),
    modules = [Bukdu],
    clean = false,
    format = Documenter.HTML(),
    sitename = "Bukdu.jl 🌌",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
        "controllers" => "controllers.md", # ApplicationController Conn
                                           # Assoc
        "renders" => "renders.md",         # Render
                                           # render
        "routes" => "routes.md",           # routes pipeline
                                           # get post delete patch put resources
                                           # Routing.empty!
        "plugs" => "plugs.md",             # Plug plug
        "Actions" => "Actions.md",         # Actions
        "HTML5.Form" => "HTML5/Form.md",   # change
                                           # form_for text_input submit
        "Changeset" => "changeset.md",     # Changeset
        "CLI" => "CLI.md",                 # CLI
        "System" => "System.md",           # System
        "Router" => "Router.md",           # Router
        "Utils" => "Utils.md",             # Utils
    ],
)
