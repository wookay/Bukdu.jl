# module Bukdu.Octo.Migration

import ..PrimaryKey

immutable SchemaMigration
    id::PrimaryKey{Int}
    version::String
    inserted_at::DateTime
end
