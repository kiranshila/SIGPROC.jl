using RadioTransients
using Documenter

ENV["GKSwstype"] = "100"

DocMeta.setdocmeta!(RadioTransients, :DocTestSetup, :(using RadioTransients); recursive=true)

makedocs(;
         modules=[RadioTransients],
         authors="Kiran Shila <me@kiranshila.com> and contributors",
         repo="https://github.com/kiranshila/RadioTransients.jl/blob/{commit}{path}#{line}",
         sitename="RadioTransients.jl",
         format=Documenter.HTML(;
                                prettyurls=get(ENV, "CI", "false") == "true",
                                canonical="https://kiranshila.github.io/RadioTransients.jl",
                                assets=String[]),
         pages=["Home" => "index.md",
                "Examples" => "examples.md",
                "API" => "api.md"])

deploydocs(;
           repo="github.com/kiranshila/RadioTransients.jl",
           devbranch="main")
