module Utils # Bukdu

"""
    Utils.read_stdout(f)
"""
function read_stdout(f)
    oldout = stdout
    rdout, wrout = redirect_stdout()
    out = @async read(rdout, String)
    f()
    redirect_stdout(oldout)
    close(wrout)
    rstrip(fetch(out))
end

end # module Bukdu.Utils
