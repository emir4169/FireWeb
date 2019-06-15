if not term.isColor() then
	printError("Sorry! Only Advanced Computers can use WebCraft!");
end

local mainTerm = term
local currentTerm = term.current()
local running = true

local w, h = term.getSize();
		
local function page(page)
	local tPage = {};
	for i in string.gmatch(page, "[^://]+") do
		table.insert(tPage, i)
	end

	local download = http.get("https://github.com/CCTech-ComputerCraft/WebCraft/"..tPage[1].."/"..tPage[2])

	if not download then
		error("Unable to connect to "..tPage[2].."\n in Protocol "..tPage[1])
	end

	local handler = download.readAll()
	download.close()
	local file = fs.open("tmp/"..tPage[2], "w")
	file.write(handler)
	file.close()

	local wind = window.create(currentTerm, 1, 2, w, h)
	term.redirect(wind)

	while running do
		shell.run("tmp/"..tPage[2])
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

bar()