using FileWatching # FolderMonitor

dir = "."
fm = FolderMonitor(dir)

function reload_chrome()
   run(`osascript chrome.scpt`)
end

watching_files = ["test.css"]

loop = Task() do
    while fm.open
        (fname, events) = wait(fm)::Pair
        println("fname ", fname)
        fname in watching_files && reload_chrome()
    end
end
schedule(loop)
