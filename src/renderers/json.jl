import JSON

function render(::Type{Val{:JSON}}, obj::Any)::Conn
    Conn(200, Dict("Content-Type"=>"application/json"), JSON.json(obj), Dict{String,String}(), Dict{String,String}())
end
