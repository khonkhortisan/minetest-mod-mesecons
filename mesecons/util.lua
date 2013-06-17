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

function mesecon:rulepairs(rules)
	--strips metarules, leaving only rules
	print("mesecon:rulepairs")
	shallowrules = {}
	for _,metarule in ipairs(rules) do
		if metarule.x then
			table.insert(shallowrules,metarule)
		else for _,rule in ipairs(metarule) do
			table.insert(shallowrules,rule)
		end end
	end
	return ipairs(shallowrules)
end

function mesecon:ruletometa(findrule, metarules)
	print("mesecon:ruletometa")
	--get the number of which metarule the rule is in
	if not findrule or metarules[1].x then
		return 1
	end
	for m,metarule in ipairs(metarules) do
		for _,rule in ipairs(metarule) do
			print("mesecon:ruletometa mesecon:cmpPos "..dump(findrule).." "..dump(rule))
			if mesecon:cmpPos(findrule, rule) then
				return m
			end
		end
	end
end

if dec2bin then
	print("dec2bin added to commonlib, remove here")
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
	print("mesecon:getstate")
	for state, name in ipairs(states) do
		if name == nodename then
			return state
		end
	end
end

function mesecon:getbinstate(nodename, states)
	print("mesecon:getbinstate")
	return dec2bin(mesecon:getstate(nodename, states)-1)
end

function mesecon:is_metarule_on(binstate,metanum)
	print("is_metarule_on "..binstate.." "..metanum)
	metanum = metanum or 1
	return binstate[binstate:len()-(metanum-1)] == "1"
end

function mesecon:set_metarule(binstate,metanum,bit)
	print("mesecon:set_metarule, "..binstate..", "..metanum..", "..bit)
	if bit == "1" and not mesecon:is_metarule_on(binstate,metanum) then
		binstate = dec2bin(tonumber(binstate,2)+math.pow(10,metanum-1))
	elseif bit == "0" and mesecon:is_metarule_on(binstate,metanum) then
		binstate = dec2bin(tonumber(binstate,2)-math.pow(10,metanum-1))
	end
end

function mesecon:invertRule(r)
	return {x = -r.x, y = -r.y, z = -r.z}
end

function mesecon:addPosRule(p, r)
	print("mesecon:addPosRule")
	return {x = p.x + r.x, y = p.y + r.y, z = p.z + r.z}
end

function mesecon:cmpPos(p1, p2)
	print("mesecon:cmpPos")
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
