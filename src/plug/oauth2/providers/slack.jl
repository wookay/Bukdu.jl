# module Bukdu.Plug.OAuth2

struct Slack <: Provider
end

authorize_uri(::Type{Slack}) = "https://slack.com/oauth/authorize"
access_token_uri(::Type{Slack}) = "https://slack.com/api/oauth.access"
