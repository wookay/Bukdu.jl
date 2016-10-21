module test_octo_repo

importall Bukdu
importall Bukdu.Octo
import Base.Test: @test, @test_throws

type User
    name::String
end

type Comment
    body::String
end

@test !haskey(Repo.models, User)

schema(User) do user
    has_many(user, :comments, Comment)
end

@test haskey(Repo.models, User)

user = Repo.get(User, 1)
@test isa(user, Repo.models[User])
@test isa(user.id, Int)
@test isa(user.name, String)
@test 1 == user.id
@test "foo bar" == user.name

@test isa(user.comments, Base.Generator)

end # module test_octo_repo
