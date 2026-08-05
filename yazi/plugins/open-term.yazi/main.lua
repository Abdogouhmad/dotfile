--- @since 26.1.1
--- @sync entry

-- Open a terminal (kitty) in the current directory, or the hovered directory.

local function entry()
	local tab = cx.active
	local hovered = tab.current.hovered
	local target = hovered and hovered.cha.is_dir and tostring(hovered.url) or tostring(tab.current.cwd)

	ya.emit("shell", {
		"--",
		"kitty --directory " .. ya.quote(target),
		orphan = true,
	})
end

return { entry = entry }
