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
                                           # Assoc
        "renders" => "renders.md", # Render
                                   # render
        "routes" => "routes.md", # routes pipeline
                                 # get post delete patch put resources
                                 # Router.request Routing.empty!
        "plugs" => "plugs.md", # Plug plug
        "Actions" => "Actions.md", # Actions
        "HTML5.Form" => "HTML5/Form.md", # change
                                         # form_for text_input submit
        "Changeset" => "changeset.md", # Changeset
        "CLI" => "CLI.md", # CLI
        "Utils" => "Utils.md", # Utils
    ],
    html_prettyurls = !("local" in ARGS),
)
