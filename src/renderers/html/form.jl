# module Bukdu

immutable FormFile
    filename::String
    content_type::String
    data::Vector{UInt8}
end
