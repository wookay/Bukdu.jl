# module Bukdu.Octo.Query

column_phrase_type(::Type{Bool}, options::Dict{Symbol,Any})::String     = "BOOL"
column_phrase_type(::Type{String}, options::Dict{Symbol,Any})::String   = "VARCHAR(255)"
column_phrase_type(::Type{Int}, options::Dict{Symbol,Any})::String      = "INT"
column_phrase_type(::Type{BigInt}, options::Dict{Symbol,Any})::String   = "BIGINT"
column_phrase_type(::Type{Float64}, options::Dict{Symbol,Any})::String  = "FLOAT(8)"
column_phrase_type(::Type{Date}, options::Dict{Symbol,Any})::String     = "DATE"
column_phrase_type(::Type{DateTime}, options::Dict{Symbol,Any})::String = "DATETIME"

function column_phrase_type(column::ColumnPhrase)::String
    if column.typ <: Schema.PrimaryKey
       column_phrase_primary_key(column)
    else
       string(column.name, ' ', column_phrase_type(column.typ, column.options))
    end
end

function column_phrase_primary_key(column::ColumnPhrase)::String
    auto_increment = true
    not_null = true
    if haskey(column.options, :auto_increment)
        auto_increment = column.options[:auto_increment]
    end
    if haskey(column.options, :not_null)
        not_null = column.options[:not_null]
    end
    string(column.name,
           ' ',
           column_phrase_type(first(column.typ.parameters), column.options),
           not_null ? string(' ', uppercase("not null")) : "",
           auto_increment ? string(' ', uppercase("auto_increment")) : ""
    )
end
