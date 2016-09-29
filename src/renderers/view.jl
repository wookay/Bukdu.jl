# module Bukdu

immutable View <: ApplicationView
end

function Logger.log_message{AV<:ApplicationView}(::Type{AV})
    Logger.settings[:info_sub] = AV.name.name
end
