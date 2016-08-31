# module Bukdu

module Logger

import ..Bukdu: ApplicationController, ApplicationLayout, ApplicationView, LayoutDivision

const level_false = 0
const level_info = 2
const level_warn = 3
const level_error = 5

settings = Dict(
    :level => level_false,
    :debug_prefix => string(Base.text_colors[:yellow], "DEBUG", Base.color_normal, ' ')
)

function info(block::Function)
    settings[:level] >= level_info && info(block()...)
end

 function warn(block::Function)
    settings[:level] >= level_warn && warn(block()...)
end

 function error(block::Function)
    settings[:level] >= level_error && error(block()...)
end

function info(args...)
    settings[:level] >= level_info && print_log(:green, "INFO", args...)
end

function warn(args...)
    settings[:level] >= level_warn && print_log(:cyan, "WARN", args...)
end

function error(args...)
    settings[:level] >= level_warn && print_log(:red, "ERROR", args...)
end

function debug(args...)
    println(settings[:debug_prefix], join(args, ' '))
end

function print_log(color::Symbol, prefix::String, args...)
    println(string(Base.text_colors[color], prefix, Base.color_normal, ' ', join(args, ' ')))
end

function set_level(level::Union{Symbol,Bool})
    opts = Dict(false=>level_false, :info=>level_info, :warn=>level_warn, :error=>level_error)
    if haskey(opts, level) 
        settings[:level] = opts[level]
    end
end

function set_debug_prefix(pre, prefix)
    settings[:debug_prefix] = string(Base.text_colors[:yellow], pre, Base.color_normal, ""==prefix ? ' ' : " $prefix ")
end

log_message{AL<:ApplicationLayout}(D::LayoutDivision{AL}) = set_debug_prefix("DEBUG", D)
log_message{AV<:ApplicationView}(V::Type{AV}) = set_debug_prefix("DEBUG", V.name.name)
log_message(modul::Module) = set_debug_prefix("DEBUG", Base.module_name(modul))

function log_message{AC<:ApplicationController}(c::AC)
    controller = AC
    action = Base.function_name(c[:action])
    set_debug_prefix("DEBUG", string(AC, '.', action))
end

function log_message(prefix::String)
    if isempty(prefix)
        settings[:debug_prefix] = ""
    else
        set_debug_prefix(prefix, "")
    end
end

end # module Bukdu.Logger
