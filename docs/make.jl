using SIGPROC
using Documenter

ENV["GKSwstype"] = "100"

DocMeta.setdocmeta!(SIGPROC, :DocTestSetup, :(using SIGPROC); recursive=true)

makedocs(;
         modules=[SIGPROC],
         authors="Kiran Shila <me@kiranshila.com> and contributors",
         repo="https://github.com/kiranshila/SIGPROC.jl/blob/{commit}{path}#{line}",
         sitename="RadioTransients.jl",
         format=Documenter.HTML(;
                                prettyurls=get(ENV, "CI", "false") == "true",
                                canonical="https://kiranshila.github.io/SIGPROC.jl",
                                assets=String[]),
         pages=["Home" => "index.md",
                "Examples" => "examples.md",
                "API" => "api.md"])

deploydocs(;
           repo="github.com/kiranshila/SIGPROC.jl",
           devbranch="main")
