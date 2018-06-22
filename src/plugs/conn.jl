# module Bukdu.Plug

# follow the https://github.com/elixir-plug/plug/blob/master/lib/plug/conn.ex

"""
    Conn
"""
mutable struct Conn <: AbstractPlug
    request::Deps.Request

    # Fetchable fields
    # cookies           # the request cookies with the response cookies  FIXME
    body_params::Assoc  # Plug.Parsers
    query_params::Assoc # fetch_query_params
    path_params::Assoc
    params::Assoc       # merge(body_params, query_params, path_params)

    # Connection fields
    halted::Bool        # the boolean status on whether the pipeline was halted
end
Conn(request::Deps.Request) = Conn(request, Assoc(), Assoc(), Assoc(), Assoc(), false)

# module Bukdu.Plug
