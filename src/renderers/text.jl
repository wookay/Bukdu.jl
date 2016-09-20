# module Bukdu

function render(::Type{Text}, args...)::Conn
    filtering(render,Text,args...) do
        obj = isempty(args) ? "": first(args)
        Conn(200, Dict("Content-Type"=>"text/plain"), isa(obj, String) ? obj : string(obj), Dict{String,String}(), Dict{String,String}(), Dict{Symbol,String}(), Dict{Symbol,String}())
    end
end
