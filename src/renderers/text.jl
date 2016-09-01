# module Bukdu

function render(T::Type{Text}, obj::Any)::Conn
    filtering(render,T,obj) do
        Conn(200, Dict("Content-Type"=>"text/plain"), isa(obj, String) ? obj : string(obj), Dict{String,String}(), Dict{String,String}(), Dict{Symbol,String}(), Dict{Symbol,String}())
    end
end
