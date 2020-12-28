local mpv_scripts_dir = os.getenv("HOME") .. "/.config/mpv/scripts/"
function load(subdir) dofile(mpv_scripts_dir .. subdir) end

load("mpv-reload/reload.lua")

load("mpv-image-viewer/scripts/image-positioning.lua")
load("mpv-image-viewer/scripts/detect-image.lua")
