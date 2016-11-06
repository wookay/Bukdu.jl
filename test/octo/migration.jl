module test_octo_migration

import Bukdu: Logger
importall Bukdu.Octo
importall .Octo.Schema
import .Adapter: NoAdapterError
import Base.Test: @test, @test_throws

# Logger.set_level(:debug)

Repo.migration(v"1.0") do
end

Repo.migration(v"1.1") do
    ~ create(:table, "people") do t
          add(t, :first_name, String)
          add(t, :last_name, Nullable{String}, varchar=30, default="hello")
          add(t, :age, Int)
      end
end

Repo.migration(v"1.2") do
    + alter(:table, "people") do t
        add(t, :first_name, String)
        add(t, :last_name, String)
        add(t, :age, Int)
      end
    - alter(:table, "people") do t
        add(t, :first_name, String)
        add(t, :last_name, Nullable{String})
        add(t, :age, Int)
      end
end

adapter = Database.setup(Adapter.MySQL) do adapter
    Adapter.connect(adapter, host="127.0.0.1", user="test", pass="test", db="mysqltest")
end

migrate(adapter, v"1.1")

migrate(adapter, v"1.2")

migrate(adapter, v"1.1")

migrate(adapter, v"1.0")

Database.reset()

end # module test_octo_migration
