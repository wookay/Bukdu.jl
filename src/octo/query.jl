# module Bukdu.Octo

module Query

export SubQuery, Field, from
export Predicate

import ..Repo
import ..Assoc
import ..Logger
import Base: in, isless, ==, !, &, |

models = Dict{Type,Any}()

type SubQuery
  #defstruct [:query, :params, :types, :fields, :sources, :select, :cache, :take]
end

type Field
    name::Symbol
end


module A

import ..Field

end # module Bukdu.Octo.Query.A

include("query/predicate.jl")

function from(T::Type; kw...)::SubQuery
    SubQuery()
end

function from(; kw...)::SubQuery
    SubQuery()
end

function type_generate(T::Type)
    type_name = Symbol(replace(string(T), '.', '_'))
    lines = String[]
    fields = Assoc(id=:Field)
    for i in 1:nfields(T)
        push!(fields, (fieldname(T, i), :Field))
    end
    for (typ, vec) in Repo.relations
        for (relation,name,FT) in vec
            if FT==T && :has_many==relation
                push!(fields, (Symbol(lowercase(string(typ.name.name, "_id"))), :Field))
            end
        end
    end
    push!(lines, "type $type_name")
    for (name,typ) in fields
        push!(lines, "    $name::$typ")
    end
    push!(lines, "end")
    code = join(lines, "\n")
    eval(A, parse(code))
    models[T] = getfield(A, type_name)
end

function in(T::Type)
    typ = haskey(models, T) ? models[T] : type_generate(T)
    typ([Field(name) for name in fieldnames(typ)]...)
end

end # module Bukdu.Octo.Query
