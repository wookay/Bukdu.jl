module test_octo_query_predicate

import Bukdu.Octo.Schema: Field
import Bukdu: Logger
importall Bukdu.Octo.Query
import Base.Test: @test, @test_throws

type User
    name
    age
end

name = Field(User, :name)
age = Field(User, :age)

@test Predicate(>,3,name) ≈ (3 > name)
@test Predicate(>,3,name) ≈ (name < 3)
@test Predicate(<,3,name) ≈ (3 < name)
@test Predicate(<,3,name) ≈ (name > 3)

@test Predicate(!,<,3,name) ≈ (3 >= name)
@test Predicate(!,<,3,name) ≈ (name <= 3)
@test Predicate(!,>,3,name) ≈ (3 <= name)
@test Predicate(!,>,3,name) ≈ (name >= 3)

@test Predicate(==,3,name)   ≈ (3 == name)
@test Predicate(==,3,name)   ≈ (name == 3)
@test Predicate(!,==,3,name) ≈ (3 != name)
@test Predicate(!,==,3,name) ≈ (name != 3)

@test Predicate(and, Predicate(==,3,name),Predicate(<,25,age)) ≈
    (3 == name) & (age > 25)

@test Predicate(and, Predicate(==,3,name),Predicate(<,25,age)) ≈
    and(3 == name, age > 25)

@test Predicate(or,Predicate(==,3,name),Predicate(<,25,age)) ≈
    (3 == name) | (age > 25)

@test Predicate(or,Predicate(==,3,name),Predicate(<,25,age)) ≈
    or(3 == name, age > 25)

end # module test_octo_query_predicate
