--- @since 26.1.1

-- Extract the hovered or selected archive(s) into the current directory using 7-zip.
-- Named `extract-here` because yazi's built-in plugin names (e.g. `extract`) are
-- reserved and user plugins with those names are ignored.

local ctx = ya.sync(function()
	local tab = cx.active
	local paths = {}
	for _, url in pairs(tab.selected) do
		paths[#paths + 1] = tostring(url)
	end
	local h = tab.current.hovered
	if #paths == 0 and h and not h.cha.is_dir then
		paths[1] = tostring(h.url)
	end
	return paths, tostring(tab.current.cwd)
end)

local function find_7z()
	for _, bin in ipairs({ "7zz", "7z", "7za" }) do
		local output, err = Command(bin):arg("i"):output()
		if not err and output.status.success then
			return bin
		end
	end
	return nil
end

local function entry()
	local urls, cwd = ctx()
	if #urls == 0 then
		return ya.notify { title = "Extract", content = "Nothing to extract", level = "warn", timeout = 3 }
	end

	local sevenzip = find_7z()
	if not sevenzip then
		return ya.notify { title = "Extract", content = "7-zip not found (install `7zip` or `p7zip`)", level = "error", timeout = 5 }
	end

	for _, u in ipairs(urls) do
		local output, err = Command(sevenzip):arg("x"):arg("-y"):arg("-o" .. cwd):arg(u):output()
		if err then
			return ya.notify { title = "Extract", content = tostring(err), level = "error", timeout = 5 }
		elseif not output.status.success then
			return ya.notify { title = "Extract", content = "Failed:\n" .. (output.stderr or ""), level = "error", timeout = 5 }
		end
	end

	ya.notify { title = "Extract", content = "Extracted " .. #urls .. " archive(s)", level = "info", timeout = 3 }
end

return { entry = entry }
