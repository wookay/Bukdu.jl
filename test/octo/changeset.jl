importall Bukdu
importall Bukdu.Octo
import Bukdu.Octo: |>

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

lhs = Assoc(attach=FormFile())
lhs2 = Assoc(attach=FormFile())
rhs = Assoc(attach=FormFile("one.png","",UInt8[0]))
rhs2 = Assoc(attach=FormFile("one.png","",UInt8[0]))
@test Assoc() == setdiff(lhs, lhs2)
@test Assoc() == setdiff(rhs, rhs2)
@test Assoc(attach=FormFile()) == setdiff(lhs, rhs)
@test Assoc(attach=FormFile("one.png","",UInt8[0])) == setdiff(rhs, lhs)
