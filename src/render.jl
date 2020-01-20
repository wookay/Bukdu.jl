# module Bukdu

export render

struct UnknownModuleError <: Exception
    msg::String
end

"""
    render(::Type{Text}, data)::Render
"""
function render(::Type{Text}, data)::Render
    Render("text/plain; charset=utf-8", string, data)
end

"""
    render(::Type{HTML}, data)::Render
"""
function render(::Type{HTML}, data)::Render
    Render("text/html; charset=utf-8", string, data)
end

"""
    render_json(data)::Render
"""
function render_json(data)::Render
    Render("application/json; charset=utf-8", JSON.json, data)
end

"""
    render(::Type{Julia}, data)::Render
"""
function render(::Type{Julia}, data)::Render
    Render("application/julia; charset=utf-8", repr, data)
end

"""
    render(::Type{JavaScript}, data)::Render
"""
function render(::Type{JavaScript}, data)::Render
    Render("application/javascript; charset=utf-8", string, data)
end

# application/wasm

function render(m::Module, data)::AbstractRender # throw UnknownModuleError
    if nameof(m) === :JSON
        render_json(data)
    elseif nameof(m) === :HTML5
        render(HTML, data)
    else
        throw(UnknownModuleError(string(m)))
    end
end

# module Bukdu
