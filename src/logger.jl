# module Bukdu

module Logger

const level_false =   0
const level_fatal = 100
const level_error = 200
const level_warn  = 300
const level_info  = 400
const level_debug = 500

"""
    Logger.level::Union{Bool,Symbol}

Get the current Logger level.
"""
level = :info::Union{Bool,Symbol}

const levels = Dict{Union{Bool,Symbol},Int}(
    false  => level_false,
    :fatal => level_fatal,
    :error => level_error,
    :warn  => level_warn,
    :info  => level_info,
    :debug => level_debug
)

settings = Dict(
    :level => level_info,
    :have_color => 1==Base.JLOptions().color || Base.have_color,
    :have_datetime => false,
    :info_prefix => "INFO",
    :info_sub => "",
    :path_padding => 39,
    :hide => []
)

fatal(block::Function) = settings[:level] >= level_fatal && fatal(block())
error(block::Function) = settings[:level] >= level_error && error(block())
warn(block::Function)  = settings[:level] >= level_warn && warn(block())
info(block::Function)  = settings[:level] >= level_info && info(block())
debug(block::Function) = settings[:level] >= level_debug && debug(block())

fatal(block::Function, condition::Function) = settings[:level] >= level_fatal && condition() && fatal(block())
error(block::Function, condition::Function) = settings[:level] >= level_error && condition() && error(block())
warn(block::Function, condition::Function)  = settings[:level] >= level_warn && condition() && warn(block())
info(block::Function, condition::Function)  = settings[:level] >= level_info && condition() && info(block())
debug(block::Function, condition::Function) = settings[:level] >= level_debug && condition() && debug(block())

fatal(args...; kw...) = settings[:level] >= level_fatal && print_log(:magenta, "FATAL", "", args...; kw...)
error(args...; kw...) = settings[:level] >= level_error && print_log(:red, "ERROR", "", args...; kw...)
warn(args...; kw...)  = settings[:level] >= level_warn && print_log(:yellow, "WARN ", "", args...; kw...)
info(args...; kw...)  = settings[:level] >= level_info && print_info(args...; kw...)
debug(args...; kw...) = settings[:level] >= level_debug && print_log(:cyan, "DEBUG", "", args...; kw...)

"""
    Logger.set_level(lvl::Union{Symbol,Bool})

Set the log level.
Options: `:debug`, `:info`, `:error`, `:warn`, `:fatal`, `false`

```julia
julia> Logger.set_level(false)
false
```
"""
function set_level(lvl::Union{Symbol,Bool}) # throw ArgumentError
    if haskey(levels, lvl)
        global level
        settings[:level] = levels[lvl]
        level = lvl
    else
        valids = join(map(repr, keys(levels)), ", ")
        throw(ArgumentError("invalid argument for level"))
    end
end

function hide(T::Type)
    push!(settings[:hide], T)
end

function inner_stackframes(stackframes::Vector{StackFrame}, with_color::Function)
    pat = r"(.* at )(?P<file>.*.jl):(?P<lineno>\d*)"
    string('\n', join(map(stackframes) do frame
        str = string(frame)
        m = match(pat, str)
        isa(m, RegexMatch) ? string(m[1], with_color(:bold, m[:file]), ':', with_color(:bold, m[:lineno])) : str
    end, '\n'))
end

function inner_contents(args...)
    if 1 == length(args)
        arg = first(args)
        if any(x->isa(arg,x), [Array, Tuple])
            if isa(arg, Vector{StackFrame})
                settings[:have_color] ? inner_stackframes(arg, with_color) : arg
            else
                inner_contents(arg...)
            end
        else
            arg
        end
    else
        join(map(inner_contents, args), ' ')
    end
end

function print_log(color::Symbol, prefix::String, sub::String, args...; LF=true)
    print(string(
        settings[:have_datetime] ? rpad(string(Dates.now()), 24) : "",
        with_color(color, rpad(prefix, 5)),
        ' ',
        isempty(sub) ? "" : string(sub, ' '),
        inner_contents(args...),
        (LF ? "\n" : "")))
end

function print_info(args...; kw...)
    prefix = settings[:info_prefix]
    sub = string(settings[:info_sub])
    print_log(:green, prefix, sub, args...; kw...)
end

function have_datetime(enabled::Bool)
    settings[:have_datetime] = enabled
end

function have_color(enabled::Bool)
    settings[:have_color] = enabled
end

function set_path_padding(padding::Int)
    settings[:path_padding] = padding
end

function with_color(name::Symbol, text)::String
    if settings[:have_color]
        local dict = Dict(:color => Base.color_normal)
        function set_color(c)
            dict[:color] = c
        end
        if name in [:olive]
            if haskey(Base.text_colors, 64)
                :olive==name && set_color(Base.text_colors[64])
            end
        else
            haskey(Base.text_colors, name) && set_color(Base.text_colors[name])
        end
        if Base.color_normal == dict[:color]
            string(text)
        else
            string(dict[:color], text, Base.color_normal)
        end
    else
        string(text)
    end
end

function trail(s::String, n)::String
    length(s) > n > 2 ? string(s[1:n-2], "..") : s
end

const verb_colors = Dict(
    :post => :yellow,
    :delete => :red,
    :head => :olive,
    :options => :olive,
    :patch => :magenta,
    :put => :magenta
)

function debug_verb(verb::Symbol, path::String)::Tuple
    verb_color = verb in keys(verb_colors) ? verb_colors[verb] : :normal
    method = lpad(uppercase(string(verb)), 4)
    verb = with_color(verb_color, method)
    path_pad = settings[:path_padding] - length(method)
    trailed_path = trail(path, path_pad)
    rpaded_path = with_color(:bold, rpad(trailed_path, path_pad))
    (verb, rpaded_path)
end

function debug_verb(verb::Symbol, path::String, ex)::Tuple
    tuple(debug_verb(verb, path)..., ex)
end

end # module Bukdu.Logger
