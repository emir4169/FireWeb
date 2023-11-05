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
_G.normalerror = _G.error -- This saves a copy of the built in error handler.
local w, h = term.getSize();
local function FireWeb_Updater()
local updater_success, updater_download = pcall(function() http.get("https://raw.githubusercontent.com/emir4169/FireWeb/master/Main.lua") end)
local data = response.readAll()
local f = io.open(settings.get("fireweb.updateplace"), "w")
f:write(data)
f:close()
end

local function page(page)
	_G.error = function(message)
	print("FireWeb Error: "..message) 
	end -- Replaces the built in error handler with the FireWeb error handler, This will allow recovery from an error.
	local tPage = {};
	for i in string.gmatch(page, "[^://]+") do
		table.insert(tPage, i)
	end
	if tPage[1] and tPage[2] then
		local WebProtocol = tPage[1] --Extra variables for better readability.
		local PageName = tPage[2]
		local success, download = pcall(function() http.get(webcenter.."/"..WebProtocol.."/"..PageName) end)
		_G.success = success
	else 
		_G.success = false
	end
	if not _G.success then
		if tPage[1] and tPage[2] then
		error("The download for "..PageName.." in the protocol "..WebProtocol.." has failed, this could be a connection issue")
		--error("Unable to connect to "..tPage[2].."\n in Protocol "..tPage[1]) Remnant from WebCraft. Has been replaced with more helpful error messsage.
		end
	end
	_G.success = nil

	local handler = download.readAll()
	download.close()
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
	while running do
		loadstring(handler)
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
		local _, button, x, y = os.pullEvent("mouse_click");

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
