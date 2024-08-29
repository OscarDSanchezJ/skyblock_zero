local generator_power_production = 30
sbz_api.register_generator("sbz_power:simple_charge_generator", {
    description = "Simple Charge Generator",
    tiles = { "simple_charge_generator.png" },
    groups = { matter = 1, sbz_machine = 1, pipe_connects = 1 },
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
item_image[3.4,1.9;1,1;sbz_resources:core_dust]
list[context;main;3.5,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[]
]])

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
            pos = pos,
        })
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 1)


        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
            pos = pos,
        })

        meta:set_int("count", 10)
    end,

    action = function(pos, node, meta)
        local count = meta:get_int("count")
        count = count - 1
        meta:set_int("count", count)
        local inv = meta:get_inventory()

        -- check if fuel is there
        if not inv:contains_item("main", "sbz_resources:core_dust") then
            minetest.add_particlespawner({
                amount = 10,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = -0.5, y = -0.5, z = -0.5 },
                maxvel = { x = 0.5, y = 0.5, z = 0.5 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 5,
                maxexptime = 10,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "error_particle.png",
                glow = 10
            })
            meta:set_string("infotext", "Stopped")
            return 0
        end
        if count <= 0 then
            meta:set_int("count", 10)
            local stack = inv:get_stack("main", 1)
            if stack:is_empty() then
                meta:set_string("infotext", "Stopped")
                return 0
            end

            stack:take_item(1)
            inv:set_stack("main", 1, stack)

            minetest.add_particlespawner({
                amount = 25,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = 0, y = 5, z = 0 },
                maxvel = { x = 0, y = 5, z = 0 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 1,
                maxexptime = 3,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "charged_particle.png",
                glow = 10
            })
        end
        meta:set_string("infotext", "Running")
        return generator_power_production
    end,
    input_inv = "main",
    output_inv = "main",
    info_generated = 30,
})


minetest.register_craft({
    output = "sbz_power:simple_charge_generator",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_resources:antimatter_dust",    "sbz_power:simple_charged_field" },
        { "sbz_resources:matter_blob",      "sbz_resources:matter_annihilator", "sbz_resources:matter_blob" },
        { "sbz_power:simple_charged_field", "sbz_resources:matter_blob",        "sbz_power:simple_charged_field" }
    }
})

sbz_api.register_generator("sbz_power:simple_charged_field", {
    description = "Simple Charged Field",
    drawtype = "glasslike",
    tiles = { "simple_charged_field.png" },
    groups = { matter = 1, cracky = 3, sbz_machine = 1 },
    sunlight_propagates = true,
    walkable = false,
    power_generated = 3,
    on_dig = function(pos, node, digger)
        minetest.sound_play("charged_field_shutdown", {
            gain = 5.0,
            max_hear_distance = 32,
            pos = pos,
        })
        minetest.node_dig(pos, node, digger)
    end,
    info_extra = "Decays after some time"
})
minetest.register_craft({
    output = "sbz_power:simple_charged_field",
    recipe = {
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" },
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" },
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" }
    }
})
minetest.register_abm({
    label = "Simple Charged Field Particles",
    nodenames = { "sbz_power:simple_charged_field" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 5,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -2, y = -2, z = -2 },
            maxvel = { x = 2, y = 2, z = 2 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 10,
            maxexptime = 20,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "charged_particle.png",
            glow = 10
        })
    end,
})
minetest.register_abm({
    label = "Simple Charged Field Decay",
    nodenames = { "sbz_power:simple_charged_field" },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.after(1, function()
            -- field decayed
            minetest.set_node(pos, { name = "sbz_power:charged_field_residue" })

            -- plop
            minetest.sound_play("decay", { pos = pos, gain = 1.0 })

            -- more particles!
            minetest.add_particlespawner({
                amount = 100,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = -5, y = -5, z = -5 },
                maxvel = { x = 5, y = 5, z = 5 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 10,
                maxexptime = 20,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "charged_particle.png",
                glow = 10
            })
        end)
    end,
})

minetest.register_node("sbz_power:charged_field_residue", {
    description = "Charged Field Residue",
    drawtype = "glasslike",
    tiles = { "charged_field_residue.png" },
    groups = { unbreakable = 1 },
    sunlight_propagates = true,
    walkable = true,
    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher.is_fake_player then return end
        displayDialougeLine(puncher:get_player_name(), "The residue is still decaying.")
    end,
})
minetest.register_abm({
    label = "Charged Field Residue Decay",
    nodenames = { "sbz_power:charged_field_residue" },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        -- residue decayed
        minetest.set_node(pos, { name = "air" })

        -- plop, again
        minetest.sound_play("decay", { pos = pos, gain = 1.0 })
    end,
})

-- Starlight Collector
sbz_api.register_generator("sbz_power:starlight_collector", {
    description = "Starlight Collector",
    drawtype = "nodebox",
    tiles = { "starlight_collector.png", "matter_blob.png", "matter_blob.png", "matter_blob.png", "matter_blob.png", "matter_blob.png" },
    groups = { matter = 1, pipe_connects = 1 },
    sunlight_propagates = true,
    walkable = true,
    node_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
    },
    use_texture_alpha = "clip",

    power_generated = 1,
})

minetest.register_craft({
    output = "sbz_power:starlight_collector",
    recipe = {
        { "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium" },
        { "sbz_power:power_pipe",        "sbz_power:power_pipe",        "sbz_power:power_pipe" },
        { "sbz_resources:matter_blob",   "sbz_resources:matter_blob",   "sbz_resources:matter_blob" }
    }
})
minetest.register_abm({
    label = "Starlight Collector Particles",
    nodenames = { "sbz_power:starlight_collector" },
    interval = 1,
    chance = 0.5,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 2,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y + 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 1, z = pos.z + 0.5 },
            minvel = { x = 0, y = -2, z = 0 },
            maxvel = { x = 0, y = -1, z = 0 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 1,
            maxexptime = 1,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = true,
            vertical = false,
            texture = "star.png",
            glow = 10
        })
    end,
})

sbz_api.register_generator("sbz_power:antimatter_generator", {
    description = "Antimatter generator",
    info_extra = {
        "Generates 120 power",
        "Needs 1 antimatter/s and 1 matter/s",
    },
    groups = { matter = 1, pipe_connects = 1 },
    tiles = {
        "antimatter_gen_top.png",
        "antimatter_gen_top.png",
        "antimatter_gen_side.png"
    },
    input_inv = "input",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        inv:set_size("input", 2)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]

item_image[1.4,1.9;1,1;sbz_resources:matter_dust]
list[context;input;1.5,2;1,1;]

item_image[5.7,1.9;1,1;sbz_resources:antimatter_dust]
list[context;input;5.8,2;1,1;1]

list[current_player;main;0.2,5;8,4;]
listring[]
]])
    end,
    action = function(pos, node, meta, supply, demand)
        local inv = meta:get_inventory()
        local list = inv:get_list("input")
        if list[1]:get_name() == "sbz_resources:antimatter_dust" then
            if list[2]:is_empty() then
                list[2] = list[1]
                list[1] = ItemStack("")
            elseif list[2]:get_name() == "sbz_resources:matter_dust" then
                local antimatter_stack = list[1]
                local matter_stack = list[2]
                list[1] = matter_stack
                list[2] = antimatter_stack
            end
        end
        inv:set_list("input", list)

        if inv:contains_item("input", "sbz_resources:matter_dust") and inv:contains_item("input", "sbz_resources:antimatter_dust") then
            inv:remove_item("input", "sbz_resources:matter_dust")
            inv:remove_item("input", "sbz_resources:antimatter_dust")
            meta:set_string("infotext", "Running")
            return 120
        end

        meta:set_string("infotext", "Can't react")
        return 0
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if to_list == "input" then
            local stackname = (minetest.get_inventory { type = "player", name = player:get_player_name() }):get_stack(
                from_list, from_index):get_name() -- beautiful
            if stackname == "sbz_resources:matter_dust" or stackname == "sbz_resources:antimatter_dust" then
                return count
            else
                return 0
            end
        end
        return count
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "input" then
            if stack:get_name() == "sbz_resources:matter_dust" or stack:get_name() == "sbz_resources:antimatter_dust" then
                return stack:get_count()
            end
            return 0
        end
        return stack:get_count()
    end
})

minetest.register_craft({
    output = "sbz_power:antimatter_generator",
    recipe = {
        { "sbz_resources:reinforced_matter", "sbz_resources:reinforced_matter", "sbz_resources:reinforced_matter" },
        { "sbz_resources:matter_dust",       "sbz_meteorites:neutronium",       "sbz_resources:antimatter_dust" },
        { "sbz_resources:reinforced_matter", "sbz_resources:reinforced_matter", "sbz_resources:reinforced_matter" }
    }
})
