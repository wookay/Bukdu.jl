# module Bukdu

export render

struct UnknownModuleError <: Exception
    msg::String
end

"""
    render
"""
function render
end

function render(::Type{Text}, data)::Render
    Render("text/plain; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

function render(::Type{HTML}, data)::Render
    Render("text/html; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

function render(::Type{JSON}, data)::Render
    Render("application/json; charset=utf-8", unsafe_wrap(Vector{UInt8}, JSON2.write(data)))
end

function render(::Type{JavaScript}, data)::Render
    Render("application/javascript; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

# application/wasm

function render(m::Module, data)::Render # throws UnknownModuleError
    if nameof(m) == :JSON
        render(JSON, data)
    elseif nameof(m) == :HTML5
        render(HTML, data)
    else
        throws(UnknownModuleError(string(m)))
    end
end

# module Bukdu
