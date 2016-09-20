# module Bukdu

function render(::Type{HTML}, obj::Any)
    filtering(render,HTML,obj) do
        obj
    end
end
