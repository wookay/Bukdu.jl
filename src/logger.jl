# module Bukdu

module Logger

import ..Bukdu: ApplicationController, ApplicationLayout, ApplicationView, LayoutDivision

const level_false =   0
const level_fatal = 100
const level_error = 200
const level_warn  = 300
const level_info  = 400
const level_debug = 500

settings = Dict(
    :level => level_info,
    :have_color => Base.have_color,
    :info_prefix => "INFO",
    :info_sub => ""
)

fatal(block::Function) = settings[:level] >= level_fatal && fatal(block()...)
error(block::Function) = settings[:level] >= level_error && error(block()...)
warn(block::Function)  = settings[:level] >= level_warn && warn(block()...)
info(block::Function)  = settings[:level] >= level_info && info(block()...)
debug(block::Function) = settings[:level] >= level_debug && debug(block()...)

fatal(args...) = settings[:level] >= level_fatal && print_log(:magenta, "FATAL", args...)
error(args...) = settings[:level] >= level_error && print_log(:red, "ERROR", args...)
warn(args...)  = settings[:level] >= level_warn && print_log(:yellow, "WARN ", args...)
info(args...)  = settings[:level] >= level_info && print_info(args...)
debug(args...) = settings[:level] >= level_debug && print_log(:green, "DEBUG", args...)

function print_info(args...)
    prefix = settings[:info_prefix]
    sub = string(settings[:info_sub])
    print_log(:blue, prefix, sub, args...)
end

function with_color(color::Symbol, text)::String
    if settings[:have_color]
        string(Base.text_colors[color], text, Base.color_normal)
    else
        string(text)
    end
end

function print_log(color::Symbol, prefix::String, args...)
    print(with_color(color, prefix), ' ')
    println(join(map(el->isa(el, StackFrame) ? "\n$el" :
                         isa(el, Vector{StackFrame}) ? "\n" * join(el, '\n') :
                             el, args), ' '))
end

function set_level(level::Union{Symbol,Bool})
    opts = Dict(false=>level_false, :fatal=>level_fatal, :error=>level_error, :warn=>level_warn, :info=>level_info, :debug=>level_debug)
    if haskey(opts, level)
        settings[:level] = opts[level]
    end
end

function have_color(color::Bool)
    settings[:have_color] = color
end

## log_message
function log_message(prefix::String)
    settings[:info_prefix] = prefix
end

function log_message{AL<:ApplicationLayout}(D::LayoutDivision{AL})
    settings[:info_sub] = D
end

function log_message{AV<:ApplicationView}(V::Type{AV})
    settings[:info_sub] = V.name.name
end

function log_message(modul::Module)
    settings[:info_sub] = Base.module_name(modul)
end

function log_message{AC<:ApplicationController}(c::AC)
    controller = AC
    action = Base.function_name(c[:action])
    settings[:info_sub] = string(AC, '.', action)
end

end # module Bukdu.Logger
