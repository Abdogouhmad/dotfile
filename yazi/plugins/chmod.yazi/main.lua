--- @since 26.1.1

-- Toggle the executable bit of the hovered file.

local hovered_path = ya.sync(function()
	local tab = cx.active
	return tab.current.hovered and tostring(tab.current.hovered.url)
end)

local function entry()
	local path = hovered_path()
	if not path then
		return
	end

	local _, err = Command("sh"):arg("-c"):arg('if [ -x "$1" ]; then chmod -x "$1"; else chmod +x "$1"; fi'):arg("chmod"):arg(path):output()
	if err then
		ya.notify { title = "Chmod", content = tostring(err), level = "error", timeout = 5 }
	end
end

return { entry = entry }
