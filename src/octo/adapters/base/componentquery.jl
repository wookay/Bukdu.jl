# module Bukdu.Octo.LoadAdapterBase

# ComponentQuery
function statement(adapter::AdapterBase, com::ComponentQuery)::String
    action = Base.function_name(com.action)
    if action in [:create, :create_if_not_exists]
        create_table_statement(adapter, action, com)
    elseif action in [:rename]
        rename_table_statement(adapter, action, com)
    elseif action in [:alter]
        alter_table_statement(adapter, action, com)
    elseif action in [:drop]
        drop_table_statement(adapter, action, com)
    end
end

function create_table_column_phrases(adapter::AdapterBase, action::Symbol, com::ComponentQuery)::Vector{String}
    phrases = Vector{String}()
    primary_key = ""
    for column in com.table.value.columns
        if column.typ <: Schema.PrimaryKey
            primary_key = string(uppercase("primary key"), " (", column.name, ")")
        end
        push!(phrases, column_phrase_type(column))
    end
    !isempty(primary_key) && push!(phrases, primary_key)
    phrases
end

function create_table_statement(adapter::AdapterBase, action::Symbol, com::ComponentQuery)::String
    column_phrases = create_table_column_phrases(adapter, action, com)
    string(uppercase("create"),
           ' ',
           uppercase("table"),
           ' ',
           :create_if_not_exists == action ? string(uppercase("if not exists"), ' ') : "",
           com.table_name,
           ' ',
           "(\n",
           join(map(phrase -> string("    ", phrase), column_phrases), ",\n"),
           "\n);")
end

function rename_table_statement(adapter::AdapterBase, action::Symbol, com::ComponentQuery)::String
    string(uppercase("rename"),
           ' ',
           uppercase("table"),
           ' ',
           com.table_name,
           ";")
end

function alter_table_statement(adapter::AdapterBase, action::Symbol, com::ComponentQuery)::String
    string(uppercase("alter"),
           ' ',
           uppercase("table"),
           ' ',
           com.table_name,
           ";")
end

function drop_table_statement(adapter::AdapterBase, action::Symbol, com::ComponentQuery)::String
    string(uppercase("drop"),
           ' ',
           uppercase("table"),
           ' ',
           com.table_name,
           ";")
end
