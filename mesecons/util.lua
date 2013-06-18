function mesecon:swap_node(pos, name)
	local node = minetest.env:get_node(pos)
	local data = minetest.env:get_meta(pos):to_table()
	node.name = name
	minetest.env:add_node(pos, node)
	minetest.env:get_meta(pos):from_table(data)
end

function mesecon:move_node(pos, newpos)
	local node = minetest.env:get_node(pos)
	local meta = minetest.env:get_meta(pos):to_table()
	minetest.env:remove_node(pos)
	minetest.env:add_node(newpos, node)
	minetest.env:get_meta(pos):from_table(meta)
end

--[[ new functions:
mesecon:flattenrules(allrules)
mesecon:rule2bit(findrule, allrules)
mesecon:rule2meta(findrule, allrules)
dec2bin(n)
mesecon:getstate(nodename, states)
mesecon:getbinstate(nodename, states)
mesecon:get_bit(binary, bit)
mesecon:set_bit(binary, bit, value)
mesecon:invertRule(r)
--]]

function mesecon:flattenrules(allrules)
	--print("mesecon:flattenrules")
--[[
	{
		{
			{xyz},
			{xyz},
		},
		{
			{xyz},
			{xyz},
		},
	}
--]]
	--print(dump(allrules))
	if allrules[1] and
	   allrules[1].x then
		return allrules
	end

	local shallowrules = {}
	for _, metarule in ipairs( allrules) do
	for _,     rule in ipairs(metarule ) do
		table.insert(shallowrules, rule)
	end
	end
	return shallowrules
--[[
	{
		{xyz},
		{xyz},
		{xyz},
		{xyz},
	}
--]]
end

function mesecon:rule2bit(findrule, allrules)
	--print("mesecon:rule2bit")
	--get the bit of the metarule the rule is in, or bit 1
	if allrules[1].x or not findrule then
		--print("mesecon:rule2bit ERROR")
		return 1
	end
	for m,metarule in ipairs( allrules) do
	for _,    rule in ipairs(metarule ) do
		--print("mesecon:rule2bit mesecon:cmpPos "..dump(findrule).." "..dump(rule))
		if mesecon:cmpPos(findrule, rule) then
			return m
		end
	end
	end
end

function mesecon:rule2meta(findrule, allrules)
	--get the metarule the rule is in, or allrules
	--print("mesecon:ruletometa2 "..dump(findrule).." "..dump(metarules))

	if allrules[1].x then
		return allrules
	end

	if not(findrule) then
		return mesecon:flattenrules(allrules)
	end

	for m, metarule in ipairs( allrules) do
	for _,     rule in ipairs(metarule ) do
		if mesecon:cmpPos(findrule, rule) then
			return metarule
		end
	end
	end
end

if convert_base then
	print(
		"base2dec is tonumber(num,base1)\n"..
		"commonlib needs dec2base(num,base2)\n"..
		"and it needs base2base(num,base1,base2),\n"..
		"which is dec2base(tonumber(num,base1),base2)"
	)
else
	function dec2bin(n)
		local x, y = math.floor(n / 2), n % 2
		if (n > 1) then
			return dec2bin(x)..y
		else
			return ""..y
		end
	end
end

function mesecon:getstate(nodename, states)
	--print("mesecon:getstate")
	for state, name in ipairs(states) do
		if name == nodename then
			return state
		end
	end
	error(nodename.." doesn't mention itself in "..dump(states))
end

function mesecon:getbinstate(nodename, states)
	--print("mesecon:getbinstate "..nodename.." "..dump(states))
	return dec2bin(mesecon:getstate(nodename, states)-1)
end

function mesecon:get_bit(binary,bit)
	--print("get_bit "..binary.." "..bit)
	bit = bit or 1
	local c = binary:len()-(bit-1)
	return binary:sub(c,c) == "1"
end

function mesecon:set_bit(binary,bit,value)
	--print("mesecon:set_bit, "..binary..", "..bit..", "..value)
	if value == "1" then
		--print("value = 1")
		if not mesecon:get_bit(binary,bit) then
			--print("not on")
			return dec2bin(tonumber(binary,2)+math.pow(2,bit-1))
		end
	elseif value == "0" then
		--print("value = 0")
		if mesecon:get_bit(binary,bit) then
			--print("on")
			return dec2bin(tonumber(binary,2)-math.pow(2,bit-1))
		end
	end
	return binary
	
end

function mesecon:invertRule(r)
	return {x = -r.x, y = -r.y, z = -r.z}
end

function mesecon:addPosRule(p, r)
	--print("mesecon:addPosRule")
	return {x = p.x + r.x, y = p.y + r.y, z = p.z + r.z}
end

function mesecon:cmpPos(p1, p2)
	--print("mesecon:cmpPos")
	return (p1.x == p2.x and p1.y == p2.y and p1.z == p2.z)
end

function mesecon:tablecopy(table) -- deep table copy
	local newtable = {}

	for idx, item in pairs(table) do
		if type(item) == "table" then
			newtable[idx] = mesecon:tablecopy(item)
		else
			newtable[idx] = item
		end
	end

	return newtable
end
