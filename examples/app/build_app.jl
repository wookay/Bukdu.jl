using PackageCompiler
DIR_PATH = joinpath(@__DIR__, "Hello")
APP_PATH = joinpath(dirname(DIR_PATH), "compiled")
PackageCompiler.create_app(DIR_PATH, APP_PATH; force=true)
