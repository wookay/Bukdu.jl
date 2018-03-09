using Documenter, Bukdu

makedocs(
    modules = [Bukdu],
    clean = false,
    format = :html,
    sitename = "Bukdu.jl",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
    ],
    html_prettyurls = !("local" in ARGS),
)
