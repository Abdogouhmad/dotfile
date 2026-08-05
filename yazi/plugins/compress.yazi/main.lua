--- @since 26.1.1

-- Create a zip/7z archive from the hovered or selected files/folders using 7-zip.
-- Usage: plugin compress   (defaults to .zip)
--        plugin compress --format=7z

local ctx = ya.sync(function()
	local tab = cx.active
	local paths = {}
	for _, url in pairs(tab.selected) do
		paths[#paths + 1] = tostring(url)
	end
	local h = tab.current.hovered
	if #paths == 0 and h then
		paths[1] = tostring(h.url)
	end
	local name = h and h.name or tab.current.cwd.name
	return paths, name, tostring(tab.current.cwd)
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

local function entry(self, job)
	local urls, defname, cwd = ctx()
	if #urls == 0 then
		return ya.notify { title = "Compress", content = "Nothing to compress", level = "warn", timeout = 3 }
	end

	local sevenzip = find_7z()
	if not sevenzip then
		return ya.notify { title = "Compress", content = "7-zip not found (install `7zip` or `p7zip`)", level = "error", timeout = 5 }
	end

	local fmt = job and job.args and job.args.format or "zip"
	local ext = fmt == "7z" and ".7z" or ".zip"

	local value, event = ya.input {
		pos = { "top-center", y = 2, w = 50 },
		title = "Archive name:",
		value = defname .. ext,
	}
	if event ~= 1 then
		return
	end
	local name = value
	if not name:match("%.%w+$") then
		name = name .. ext
	end

	local target = tostring(Url(cwd):join(name))
	local cmd = Command(sevenzip):arg("a"):arg("-y"):arg(fmt == "7z" and "-t7z" or "-tzip"):arg(target)
	for _, u in ipairs(urls) do
		cmd = cmd:arg(u)
	end

	local output, err = cmd:output()
	if err then
		ya.notify { title = "Compress", content = tostring(err), level = "error", timeout = 5 }
	elseif not output.status.success then
		ya.notify { title = "Compress", content = "Failed:\n" .. (output.stderr or ""), level = "error", timeout = 5 }
	else
		ya.notify { title = "Compress", content = "Created " .. name, level = "info", timeout = 3 }
	end
end

return { entry = entry }
