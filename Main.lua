settings.define("fireweb.websitecenter", {
    description = "This setting controls where FireWeb gets web pages from.",
    default = "https://github.com/emir4169/FireWeb",
})
settings.define("fireweb.updateplace", {
    description = "This setting controls where FireWeb puts updated versions.",
    default = "/FireWeb.lua",
})
local webcenter = settings.get("fireweb.websitecenter")
local mainTerm = term
local currentTerm = term.current()
local running = true
local w, h = term.getSize();
local function FireWeb_Updater()
	local updater_success, updater_download = pcall(function() return http.get("https://raw.githubusercontent.com/emir4169/FireWeb/master/Main.lua") end)
	local data = updater_download.readAll()
	local f = io.open(settings.get("fireweb.updateplace"), "w")
f:write(data)
f:close()
end
if not arcos then
	FireWeb_Updater()
end
_G.fireweb = {}
_G.fireweb.nastyhacks = {}
_G.fireweb.nastyhacks.errorchecking = {}
local function page(page)
	local tPage = {};
	for i in string.gmatch(page, "[^://]+") do
		table.insert(tPage, i)
	end
	if tPage[1] and tPage[2] then
		local WebProtocol = tPage[1] --Extra variables for better readability.
		local PageName = tPage[2]
		local download = http.get(webcenter.."/"..WebProtocol.."/"..PageName)
		_G.fireweb.nastyhacks.errorchecking.success = success
		_G.fireweb.nastyhacks.errorchecking.download = download
	end
	if not tPage[1] and tPage[2] then
		_G.fireweb.nastyhacks.errorchecking.success = false
	end
	_G.customerror = function(message)
		print("FireWeb Error: "..message) 
	end -- Replaces the built in error handler with the FireWeb error handler, This will allow recovery from an error.
	if not _G.fireweb.nastyhacks.errorchecking.success or type(_G.fireweb.nastyhacks.errorchecking.download) ~= "table" then
		if tPage[1] and tPage[2] then
		customerror("The download for "..PageName.." in the protocol "..WebProtocol.." has failed, this could be a connection issue")
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
		term.setCursorPos(1,2)
		term.setBackgroundColor(colors.lightGray)

		for i=2, w-1 do
			term.setCursorPos(i,2)
			print(" ")
		end

		local input = ""
		local e, button, x, y = os.pullEventRaw();
		if e == "terminate" then 
			
		elseif e == "mouse_click" then
			if x >= 2 and x <= w-1 and y == 2 then
				for i=2, w-1 do
					term.setCursorPos(i,2)
					print(" ")
				end
	
				term.setCursorPos(2,2)
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
