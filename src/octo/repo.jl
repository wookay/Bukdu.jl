# module Bukdu.Octo

import ..Bukdu

module Repo

export schema, has_many

import ..Bukdu: Logger
import ..Assoc

models = Dict{Type,Any}()
relations = Dict{Type,Vector}()

module A
end # module Bukdu.Octo.Repo.A

function type_generate(T::Type)
    type_name = Symbol(replace(string(T), '.', '_'))
    lines = String[]
    fields = Assoc(id=Int)
    for i in 1:nfields(T)
        push!(fields, (fieldname(T, i), fieldtype(T, i)))
    end
    for (relation,name,FT) in relations[T]
        push!(fields, (name, Base.Generator.name))
    end
    push!(lines, "type $type_name")
    for (name,typ) in fields
        push!(lines, "    $name::$typ")
    end
    push!(lines, string("    ", type_name, "(", join(["$name::$typ" for (name,typ) in fields], ", "), ") = new(", join(keys(fields), ", "), ")"))
    push!(lines, "end")
    code = join(lines, "\n")
    eval(A, parse(code))
    models[T] = getfield(A, type_name)
end

function schema(block::Function, T::Type)
    relations[T] = Vector()
    block(T)
    type_generate(T)
end

function has_many(T::Type, name::Symbol, FT::Type)
    push!(relations[T], (:has_many,name,FT))
end

function get(T::Type, id::Int)
    typ = models[T]
    typ(1, "foo bar", (i for i in 1:1))
end

end # module Bukdu.Octo.Repo

import .Repo: schema, has_many
