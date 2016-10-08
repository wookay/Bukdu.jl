importall Bukdu
importall Bukdu.Octo
using Base.Test

vector = Assoc(Vector([(:name, String)]))

@test String == vector[:name]
@test_throws KeyError vector[:age]

push!(vector, (:age, Int))

@test [:name, :age] == keys(vector)
@test [String, Int] == values(vector)
@test haskey(vector, :age)
@test !haskey(vector, :locker)

for (k,v) in vector
end

vector = Assoc(Vector([(:join, 0), (:where, 1), (:where, 2)]))
@test [:join, :where, :where] == keys(vector)
@test [0, 1, 2] == values(vector)
@test [:where, :where] == [k for (k,v) in vector if :where==k]
@test [1, 2] == [v for (k,v) in vector if :where==k]
@test [] == [v for (k,v) in vector if :locker==k]
@test haskey(vector, :where)

l = Assoc([(:author,"bar")])
r = Assoc([(:title,"title")])
@test r == Assoc([(:title,"title")])
@test Assoc([(:title,"title")]) == setdiff(r, l)

merge!(l, r)
@test Assoc([(:author,"bar"), (:title,"title")]) == l

@test !isempty(l)
empty!(l)
@test isempty(l)

@test "" == stringmime("text/html", l)
@test """(<strong>:title</strong>, <strong>"title"</strong>)
""" == stringmime("text/html", r)

assoc = combine(Vector{String}, Assoc(a="1", a="2", b="3"), :a)
@test assoc == Assoc(b="3", a=["1", "2"])

assoc = combine(Vector{Int}, Assoc(a="1", a="2", b="3"), :a)
@test assoc == Assoc(b="3", a=[1, 2])

assoc = combine(Vector{Float64}, Assoc(a="1", a="2", b="3"), :a)
@test assoc == Assoc(b="3", a=[1.0, 2.0])
