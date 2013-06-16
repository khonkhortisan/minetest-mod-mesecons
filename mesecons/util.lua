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

function mesecon:findmetanum(metarules, findrule)
	--get the number of which metarule the rule is in
	if rules[1].x then
		return 1
	end
	for m,metarule in ipairs(metarules) do
		for _,rule in ipairs(metarule) do
			if cmpPos(findrule, rule) then
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

function mesecon:is_metarule_on(states,metanum)
	state = 1
	for state, name in ipairs(states) do
		if name == nodename then
			break
		end
	end
	--state -= 1
	state =state- 1
	binstate = dec2bin(state)
	metanum = metanum or 1
	return binstate[binstate:len()-(metanum-1)] == "1"
end

--is_on ipairs(metarules[metanum])

--if state, offstate, or onstate use old behavior

--process states for node.name to get state
--decimal state to binary state
--check rules for that metarule bit

--number of metarules to binary bits
--rule to metarule
--turn on/off bit
--change node to states[binary to decimal + 1]
--
--number of metarules is #rules
--

function mesecon:addPosRule(p, r)
	print("mesecon:addPosRule")
	return {x = p.x + r.x, y = p.y + r.y, z = p.z + r.z}
end

function mesecon:cmpPos(p1, p2)
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
