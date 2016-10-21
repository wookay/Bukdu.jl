module test_octo_query_predicate

importall Bukdu.Octo.Query
import Base.Test: @test, @test_throws

@test Predicate(>,3,:name) == (3 > Field(:name))
@test Predicate(>,3,:name) == (Field(:name) < 3)
@test Predicate(<,3,:name) == (3 < Field(:name))
@test Predicate(<,3,:name) == (Field(:name) > 3)

@test Predicate(!,<,3,:name) == (3 >= Field(:name))
@test Predicate(!,<,3,:name) == (Field(:name) <= 3)
@test Predicate(!,>,3,:name) == (3 <= Field(:name))
@test Predicate(!,>,3,:name) == (Field(:name) >= 3)

@test Predicate(==,3,:name)   == (3 == Field(:name))
@test Predicate(==,3,:name)   == (Field(:name) == 3)
@test Predicate(!,==,3,:name) == (3 != Field(:name))
@test Predicate(!,==,3,:name) == (Field(:name) != 3)

@test Predicate(&,Predicate(==,3,:name),Predicate(<,25,:age)) ==
    (3 == Field(:name)) & (Field(:age) > 25)

@test Predicate(|,Predicate(==,3,:name),Predicate(<,25,:age)) ==
    (3 == Field(:name)) | (Field(:age) > 25)

@test Predicate(in,:user_id,[1,2]) == (Field(:user_id) in [1,2])

end # module test_octo_query_predicate
