# module Bukdu.Plug.OAuth2

import Requests, JSON
import HttpCommon: parsequerystring
import ..Assoc

include("providers/github.jl")
include("providers/facebook.jl")
include("providers/slack.jl")
