# module Bukdu

export render

struct UnknownModuleError <: Exception
    msg::String
end

"""
    render(::Type{Text}, data)::Render
"""
function render(::Type{Text}, data)::Render
    Render("text/plain; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

"""
    render(::Type{HTML}, data)::Render
"""
function render(::Type{HTML}, data)::Render
    Render("text/html; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

"""
    render(::Type{JSON}, data)::Render
"""
function render(::Type{JSON}, data)::Render
    Render("application/json; charset=utf-8", unsafe_wrap(Vector{UInt8}, JSON2.write(data)))
end

"""
    render(::Type{JavaScript}, data)::Render
"""
function render(::Type{JavaScript}, data)::Render
    Render("application/javascript; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

# application/wasm

function render(m::Module, data)::AbstractRender # throw UnknownModuleError
    if nameof(m) == :JSON
        render(JSON, data)
    elseif nameof(m) == :HTML5
        render(HTML, data)
    else
        throw(UnknownModuleError(string(m)))
    end
end

# module Bukdu
