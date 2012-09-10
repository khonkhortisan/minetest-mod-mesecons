for x=-1, 1 do for z=-1, 1 do
	rules = {}
	nodename = "mesecons_extrawires:crossing"
	if x == -1 then
		nodename = nodename .. "A"
		table.insert(rules, {x=-1, y=0, z=0})
	end
	if z == 1 then
		nodename = nodename .. "B"
		table.insert(rules, {x=0, y=0, z=1})
	end
	if x == 1 then
		nodename = nodename .. "C"
		table.insert(rules, {x=1, y=0, z=0})
	end
	if z == -1 then
		nodename = nodename .. "D"
		table.insert(rules, {x=0, y=0, z=-1})
	end
	mesecon:add_rules(nodename, rules)
	mesecon:register_effector(nodename, nodename, all_rules)
	if nodename == "mesecons_extrawires:crossing" then
		description = "Insulated Crossing"
		groups = {dig_immediate = 3, mesecon = 3, mesecon_conductor_craftable=1}
	else
		description = "You hacker you!"
		drop = "mesecons_extrawires:crossing"
		groups = {dig_immediate = 3, not_in_creative_inventory=1, mesecon = 3}
		mesecon:add_receptor_node(nodename, rules)
	end
	minetest.register_node(nodename, {
		drawtype = "nodebox",
		description = description,
		tiles = {
			"jeija_insulated_wire_sides.png",
		},
		paramtype = "light",
		walkable = false,
		stack_max = 99,
		selection_box = {
			type = "fixed",
			fixed = { -16/32-0.0001, -18/32, -16/32-0.001, 16/32+0.001, -5/32, 16/32+0.001 },
		},
		node_box = {
			type = "fixed",
			fixed = {
				{ -16/32-0.001, -17/32, -3/32, 16/32+0.001, -13/32, 3/32 },
				{ -3/32, -17/32, -16/32-0.001, 3/32, -13/32, -6/32 },
				{ -3/32, -13/32, -9/32, 3/32, -6/32, -6/32 },
				{ -3/32, -9/32, -9/32, 3/32, -6/32, 9/32 },
				{ -3/32, -13/32, 6/32, 3/32, -6/32, 9/32 },
				{ -3/32, -17/32, 6/32, 3/32, -13/32, 16/32+0.001 },
			},
		},
		groups = groups,
		drop = "mesecons_insulated:insulated_off",
	})
end end

function receptor_set(pos, rules, on)
	if on then
		mesecon:receptor_on(pos, rules)
	else
		mesecon:receptor_off(pos, rules)
	end
end

function update_plus(pos, name)
	vL = {
		a = string.find(name, "A")~=nil,
		b = string.find(name, "B")~=nil,
		c = string.find(name, "C")~=nil,
		d = string.find(name, "D")~=nil,
	}
	rL = yc_get_real_portstates(pos)
	L = {
		a = rL.c and not vL.c,
		b = rL.d and not vL.d,
		c = rL.a and not vL.a,
		d = rL.b and not vL.b,
	}
	newname = "mesecons_extrawires:crossing"
	if L.a then newname = newname .. "A" end
	if L.b then newname = newname .. "B" end
	if L.c then newname = newname .. "C" end
	if L.d then newname = newname .. "D" end
	if newname ~= name then
		minetest.env:add_node(pos, {name = newname})
	end
	if L.a ~= vL.a then
		receptor_set(pos, mesecon:get_rules("mesecons_extrawires:crossingA"), L.a)
		if not L.a and yc_get_real_portstates(pos).a then
			--catch signal changing direction while on
			update_plus(pos, newname)
		end
	end
	if L.b ~= vL.b then
		receptor_set(pos, mesecon:get_rules("mesecons_extrawires:crossingB"), L.b)
		if not L.b and yc_get_real_portstates(pos).b then
			update_plus(pos, newname)
		end
	end
	if L.c ~= vL.c then
		receptor_set(pos, mesecon:get_rules("mesecons_extrawires:crossingC"), L.c)
		if not L.c and yc_get_real_portstates(pos).c then
			update_plus(pos, newname)
		end
	end
	if L.d ~= vL.d then
		receptor_set(pos, mesecon:get_rules("mesecons_extrawires:crossingD"), L.d)
		if not L.c and yc_get_real_portstates(pos).d then
			update_plus(pos, newname)
		end
	end
end

mesecon:register_on_signal_change(function(pos, node)
	if string.find(node.name, "mesecons_extrawires:crossing")~=nil then
		update_plus(pos, node.name)
	end
end)

--[[
minetest.register_craft({
	type = "shapeless",
	output = "mesecons_extrawires:crossing",
	recipe = {
		"mesecons_insulated:insulated_off",
		"mesecons_insulated:insulated_off",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mesecons_insulated:insulated_off 2",
	recipe = {
		"mesecons_extrawires:crossing",
	},
})
--]]

---automatic crossing---

function can_neighbor_link(frompos, topos)
	local k = 1
	fromnode = minetest.env:get_node(frompos)
	rules = {}
	if mesecon:is_conductor(fromnode.name) then
		rules = mesecon:conductor_get_rules(fromnode)
	elseif mesecon:is_receptor_node(fromnode.name)
		or mesecon:is_receptor_node_off(fromnode.name) then
		rules = mesecon:receptor_get_rules(fromnode)
	elseif mesecon:is_effector(fromnode.name) then
		rules = mesecon:effector_get_input_rules(fromnode)
	else
		return false
	end
	for k, rule in ipairs(rules) do
		if  frompos.x + rule.x == topos.x
		and frompos.y + rule.y == topos.y
		and frompos.z + rule.z == topos.z then
				return true
		end
	end
	return false
end

function get_possible_neighbor_links(pos)
	rulesA = mesecon:get_rules("mesecons_microcontroller:microcontroller0001")
	rulesB = mesecon:get_rules("mesecons_microcontroller:microcontroller0010")
	rulesC = mesecon:get_rules("mesecons_microcontroller:microcontroller0100")
	rulesD = mesecon:get_rules("mesecons_microcontroller:microcontroller1000")
	L = {
		a = can_neighbor_link({x=pos.x+rulesA[1].x, y=pos.y+rulesA[1].y, z=pos.z+rulesA[1].z}, pos),
		b = can_neighbor_link({x=pos.x+rulesB[1].x, y=pos.y+rulesB[1].y, z=pos.z+rulesB[1].z}, pos),
		c = can_neighbor_link({x=pos.x+rulesC[1].x, y=pos.y+rulesC[1].y, z=pos.z+rulesC[1].z}, pos),
		d = can_neighbor_link({x=pos.x+rulesD[1].x, y=pos.y+rulesD[1].y, z=pos.z+rulesD[1].z}, pos),
	}
	return L
end

function update_crossing(pos, dir, add)
	name = minetest.env:get_node(pos).name
	if string.find(name, "mesecons_insulated:insulated_")==nil and
	   name ~= "mesecons_extrawires:crossing" then
		return --not crossable
	end
	L = get_possible_neighbor_links(pos)
	if not add then
		--if uncrossing, pretend that side doesn't connect
		L.a = L.a and dir.x ~= -1
		L.b = L.b and dir.z ~= 1
		L.c = L.c and dir.x ~= 1
		L.d = L.d and dir.z ~= -1
	end
	if (L.a and 1 or 0)
	 + (L.b and 1 or 0)
	 + (L.c and 1 or 0)
	 + (L.d and 1 or 0) >= 3 then
		--connected on enough sides to cross
		if string.find(name, "mesecons_insulated:insulated_")~=nil then
			minetest.env:add_node(pos, {name = "mesecons_extrawires:crossing"})
			update_crossing({
				x=pos.x+dir.x,
				y=pos.y+dir.y,
				z=pos.z+dir.z,
			}, dir, add)
		end
	else
		--not enough sides to cross
		if name == "mesecons_extrawires:crossing" then
			if L.a or L.c then
				param2 = 0
			else
				param2 = 1
			end
			minetest.env:add_node(pos, {name = "mesecons_insulated:insulated_off", param2 = param2})
			update_crossing({
				x=pos.x+dir.x,
				y=pos.y+dir.y,
				z=pos.z+dir.z,
			}, dir, add)
		end
	end
end

function spread_crossing(pos, add)
	update_crossing({x=pos.x-1, y=pos.y, z=pos.z}, {x=-1, y=0, z=0}, add)
	update_crossing({x=pos.x, y=pos.y, z=pos.z+1}, {x=0, y=0, z=1}, add)
	update_crossing({x=pos.x+1, y=pos.y, z=pos.z}, {x=1, y=0, z=0}, add)
	update_crossing({x=pos.x, y=pos.y, z=pos.z-1}, {x=0, y=0, z=-1}, add)
	update_crossing(pos, {x=0, y=0, z=0}, add)
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode)
	if minetest.get_item_group(newnode.name, "mesecon") > 1 then
		spread_crossing(pos, true)
	elseif minetest.get_item_group(oldnode.name, "mesecon") > 1 then
		spread_crossing(pos, false)
	end
end)
minetest.register_on_dignode(function(pos, oldnode, digger)
	if minetest.get_item_group(oldnode.name, "mesecon") > 1 then
		spread_crossing(pos, false)
	end
end)

