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
