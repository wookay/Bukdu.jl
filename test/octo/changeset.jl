module test_octo_changeset

importall Bukdu
importall Bukdu.Octo
import Bukdu.Octo: |>
import Bukdu.Plug: Upload
import Base.Test: @test, @test_throws

type User
    name::String
    username::String
end

model = default(User)
params = Dict("user_name"=>"José", "user_username"=>"josevalim")

@test_throws MethodError validates(model, params)

function validates(model::User, params)
    model |>
    cast(params, [:name, :username]) |>
    validate_length(:username, min= 1, max= 20)
end

@test isa(validates(model, params), Changeset)

lhs = Assoc(attach=Upload())
lhs2 = Assoc(attach=Upload())
rhs = Assoc(attach=Upload("one.png", "image/png", UInt8[0]))
rhs2 = Assoc(attach=Upload("one.png", "image/png", UInt8[0]))
@test Assoc() == setdiff(lhs, lhs2)
@test Assoc() == setdiff(rhs, rhs2)
@test Assoc(attach=Upload()) == setdiff(lhs, rhs)
@test Assoc(attach=Upload("one.png", "image/png", UInt8[0])) == setdiff(rhs, lhs)

@test_throws ArgumentError change(nothing)
changeset = change(model)
@test isa(changeset, Changeset)
@test model == changeset.model
@test isempty(changeset.changes)

end # module test_octo_changeset
