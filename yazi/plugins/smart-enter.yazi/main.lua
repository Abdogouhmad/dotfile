--- @since 25.5.31
--- @sync entry

-- Enter a directory, or open the hovered/selected file(s).

local function entry()
	local tab = cx.active
	local hovered = tab.current.hovered
	if not hovered then
		return
	end

	if #tab.selected > 0 then
		ya.emit("open", {})
	elseif hovered.cha.is_dir then
		ya.emit("enter", {})
	else
		ya.emit("open", { hovered = true })
	end
end

return { entry = entry }
