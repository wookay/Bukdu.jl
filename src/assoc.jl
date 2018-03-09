struct Assoc
    __bukdu_dict::Dict{String, String}
end

function Base.getindex(assoc::Assoc, key::String)
    if haskey(assoc.__bukdu_dict, key)
        assoc.__bukdu_dict[key]
    else
        string()
    end
end

function Base.getproperty(assoc::Assoc, prop::Symbol)
    if :__bukdu_dict == prop
        getfield(assoc, prop)
    else
        getindex(assoc, String(prop))
    end
end

function Base.getindex(assoc::Assoc, key::Symbol)
    getindex(assoc, String(key))
end
