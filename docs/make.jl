using Documenter, JqData

makedocs(
    modules = [JqData],
    sitename="JqData.jl",
    pages=Any[
        "Home" => "index.md",
    ],
)

push!(LOAD_PATH,"../src")

deploydocs(
    repo = "github.com/hzgzh/JqData.jl",
)