import JSON

function render(modul::Module, obj::Any)::Conn
    if :JSON == Base.module_name(JSON)
        Conn(200, Dict("content-type"=>"application/json"), JSON.json(obj), Dict{String,String}(), Dict{String,String}())
    else
        CONN_NOT_FOUND
    end
end
