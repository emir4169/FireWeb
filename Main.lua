settings.define("fireweb.websitecenter", {
	description = "This setting controls where FireWeb gets web pages from.",
	default = {"https://raw.githubusercontent.com/emir4169/FireWeb/master", "http://mirkoplace.duckdns.org/arcos/webcenter"},
})
settings.define("fireweb.updateplace", {
	description = "This setting controls where FireWeb puts updated versions.",
	default = "/FireWeb.lua",
})
local webcenter = settings.get("fireweb.websitecenter", {"https://raw.githubusercontent.com/emir4169/FireWeb/master", "http://mirkoplace.duckdns.org/arcos/webcenter"})
local mainTerm = term
local currentTerm = term.current()
local running = true
local w, h = term.getSize();
local function FireWeb_Updater()
	local updater_success, updater_download = pcall(function() return http.get(
		"https://raw.githubusercontent.com/emir4169/FireWeb/master/Main.lua") end)
	local data = updater_download.readAll()
	local f = io.open(settings.get("fireweb.updateplace"), "w")
	f:write(data)
	f:close()
end
if settings.get("fireweb.update", true) then
	FireWeb_Updater()
end
function string:split(pat)
	pat = pat or '%s+'
	local st, g = 1, self:gmatch("()(" .. pat .. ")")
	local function getter(segs, seps, sep, cap1, ...)
		st = sep and seps + #sep
		return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
	end
	return function() if st then return getter(st, g()) end end
end

_G.fireweb = {}
_G.fireweb.nastyhacks = {}
_G.fireweb.nastyhacks.errorchecking = {}
local function page(apage)
	local temp = {};
	for i in apage:split("://") do
		table.insert(temp, i)
	end
	_G.fireweb.nastyhacks.errorchecking.success = false
	local tPage = { table.remove(temp, 1), table.concat(temp, "://") }
	if tPage[1] and tPage[2] then
		local WebProtocol = tPage[1] --Extra variables for better readability.
		local PageName = tPage[2]
		for _, i in ipairs(webcenter) do
			local download = http.get(i .. "/" .. WebProtocol .. "/" .. PageName)
			if type(download) == "table" and download.getResponseCode() == 200 then
				_G.fireweb.nastyhacks.errorchecking.download = download
				_G.fireweb.nastyhacks.errorchecking.success = true
				break
			end 
		end
	end
	if not tPage[1] and tPage[2] then
		_G.fireweb.nastyhacks.errorchecking.success = false
	end
	_G.customerror = function(message)
		print("FireWeb Error: " .. message)
	end -- Replaces the built in error handler with the FireWeb error handler, This will allow recovery from an error.
	if not _G.fireweb.nastyhacks.errorchecking.success then
		if tPage[1] and tPage[2] then
			term.redirect(currentTerm)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.black)
			term.clear()
			term.setCursorPos(1, 1)
			print("The download for " ..
			tPage[2] .. " in the protocol " .. tPage[1] .. " has failed, this could be a connection issue")
			print("Returned type: " .. type(fireweb.nastyhacks.errorchecking.download))
			-- require("cc.pretty").pretty_print(fireweb.nastyhacks.errorchecking.download)
			error()
			--error("Unable to connect to "..tPage[2].."\n in Protocol "..tPage[1]) Remnant from WebCraft. Has been replaced with more helpful error messsage.
		end
	end
	_G.fireweb.nastyhacks.errorchecking.success = nil

	local handler = _G.fireweb.nastyhacks.errorchecking.download.readAll()
	_G.fireweb.nastyhacks.errorchecking.download.close()
	--Will rewrite how tmp works in a later commit.
	--local file = fs.open("tmp/"..tPage[2], "w")
	--file.write(handler)
	--file.close()

	local wind = window.create(currentTerm, 1, 2, w, h)
	term.redirect(wind)
	-- This is replaced with a loadstring way of doing it until i rewrite how tmp works.
	--while running do
	--shell.run("tmp/"..tPage[2])
	--end
	local err, res = pcall(load(handler, "@page.lua", nil, _G))
	if err then
		term.setCursorPos(1, 1)
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
		print(res)
	end
end

local function bar()
	while running do
		term.setBackgroundColor(colors.white)
		term.clear()
		term.setCursorPos(1, 2)
		term.setBackgroundColor(colors.lightGray)

		for i = 2, w - 1 do
			term.setCursorPos(i, 2)
			print(" ")
		end

		local input = ""
		local e, button, x, y = os.pullEventRaw();
		if e == "terminate" then
			error()
		elseif e == "mouse_click" then
			if x >= 2 and x <= w - 1 and y == 2 then
				for i = 2, w - 1 do
					term.setCursorPos(i, 2)
					print(" ")
				end

				term.setCursorPos(2, 2)
				input = read();
			end
			local tInput = {}
			for i in string.gmatch(input, "%S+") do
				table.insert(tInput, i)
			end

			if #tInput == 1 then
				if tInput[1] ~= nil then
					page(input)
				end
			end
		end
	end
end
if term.isColor() then
	bar()
else
	input = read()
	local tInput = {}
	for i in string.gmatch(input, "%S+") do
		table.insert(tInput, i)
	end

	if #tInput == 1 then
		if tInput[1] ~= nil then
			page(input)
		end
	end
end
