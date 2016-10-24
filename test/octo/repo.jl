module test_octo_repo

importall Bukdu
importall Bukdu.Octo
importall Bukdu.Octo.Repo
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

@test_throws NoAdapterError Repo.insert(User, name="foo bar")

Repo.set_adapter(Dict)

user = Repo.insert(User, name="foo bar")
comment = Repo.insert(Comment, user_id=user.id, body="1")
comment = Repo.insert(Comment, user_id=user.id, body="2")

user = Repo.get(User, 1)
@test isa(user, Repo.models[User])
@test isa(user.id, Int)
@test isa(user.name, String)
@test 1 == user.id
@test "foo bar" == user.name

@test isa(user.comments, Base.Generator)

comments = user.comments
@test 2 == length(comments)
@test [Comment("1"),Comment("2")] == collect(comments)

end # module test_octo_repo
