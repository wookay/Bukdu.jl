# module Bukdu

function get_datatype_name(t)
    if isdefined(Base, :datatype_name)
        Base.datatype_name(t)
    else
        t.name.name
    end
end
