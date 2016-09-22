importall Bukdu

import Bukdu.Octo: default, change

type User
    name::String
    age::Int
end

form = change(default(User), name="jack")

using Base.Test
@test """<label for="user_name">Name</label>""" == Tag.label(form, :name, "Name")
