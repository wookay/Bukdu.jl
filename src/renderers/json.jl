# module Bukdu

import JSON

function render(T::Type{Val{:JSON}}, obj::Any)::Conn
    filtering(render,T,obj) do
        Conn(200, Dict("Content-Type"=>"application/json"), JSON.json(obj), Dict{String,String}(), Dict{String,String}(), Dict{Symbol,String}(), Dict{Symbol,String}())
    end
end
