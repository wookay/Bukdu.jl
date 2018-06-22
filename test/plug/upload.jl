module test_plug_upload

import Bukdu.Plug: Upload
import Base.Test: @test

lhs = Upload()
rhs = Upload()
@test lhs == rhs

end # module test_plug_upload
