importall Bukdu
importall Bukdu.Octo

type User
    name::String
    username::String
end

using Base.Test

model = default(User)
params = Dict("user[name]"=>"José", "user[username]"=>"josevalim")

@test_throws MethodError validates(model, params)

function validates(model::User, params)
    model |>
    cast(params, [:name, :username]) |>
    validate_length(:username, min= 1, max= 20)
end

@test isa(validates(model, params), Changeset)
