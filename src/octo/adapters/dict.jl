# module Bukdu.Octo.Database

dict = Dict()

function get(::Type{Adapter{Dict}}, T::Type, id::Int)
    typ = models[T]
    C = relations[T][1][3]
    typ(1, "foo bar", (C("$i") for i in 1:2))
end

function insert(::Type{Adapter{Dict}}, T::Type; kw...)
    typ = models[T]
    assoc = Assoc(kw)
    !haskey(dict, T) && merge!(dict, Dict(T=>Dict()))
    id = length(dict[T]) + 1
    assoc[:id] = id
    ass = typed_assoc(typ, assoc)
    Logger.info("ass", ass)
    fields = map(fieldnames(typ)) do name
        if haskey(assoc, name)
            assoc[name]
        else
            ft = fieldtype(typ, name)
            if ft <: Base.Generator
                Base.Generator(identity, [])
            else
                default(ft)
            end
        end
    end
    dict[T][id] = typ(fields...)
end
