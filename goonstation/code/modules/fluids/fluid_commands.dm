///////////////////
//Admin Commands///
///////////////////
client/proc/enable_waterflow(var/enabled as num)
	set name = "Set Fluid Flow Enabled"
	set desc = "0 to disable, 1 to enable"
	set category="Debug"
	admin_only
	waterflow_enabled = !!enabled

client/proc/delete_fluids()
	set name = "Delete All Fluids"
	set desc = "Probably safe to run. Probably."
	set category="Debug"
	admin_only

	var/exenabled = waterflow_enabled
	enable_waterflow(0)
	var/i = 0
	SPAWN_DBG(0)
		for(var/obj/fluid/fluid in world)
			if (fluid.pooled) continue

			for (var/mob/living/M in fluid.loc)
				fluid.HasExited(M,M.loc)
				M.show_submerged_image(0)
			for(var/obj/O in fluid.loc)
				if (O.submerged_images)
					fluid.HasExited(O,O.loc)
					O.show_submerged_image(0)
			if(fluid.group)
				fluid.group.evaporate()
			else
				if( fluid.loc )//for some reason there's a chance for this to be null.
					fluid.loc:active_liquid = null
				fluid.removed()
			i++
			if(!(i%30))
				sleep(2)

		enable_waterflow(exenabled)

client/proc/special_fullbright()
	set name = "Static Sea Light"
	set desc = "Helps when server load is heavy. Doesn't affect trench."
	set category="Debug"
	set hidden = 1
	admin_only

	message_admins("[key_name(src)] is making all Z1 Sea Lights static...")
	SPAWN_DBG(0)
		for(var/turf/space/fluid/F in world)
			if (F.z == 1)
				F.fullbright = 0.5
			LAGCHECK(LAG_REALTIME)
		message_admins("Sea Lights are now Static.")

client/proc/replace_space()
	set name = "Replace All Space Tiles With Ocean"
	set desc = "uh oh."
	set category="Debug"
	admin_only

	var/list/L = list()
	var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
	if(searchFor)
		for(var/R in childrentypesof(/datum/reagent))
			if(findtext("[R]", searchFor)) L += R
	else
		L = childrentypesof(/datum/reagent)
	var/type = 0
	if(L.len == 1)
		type = L[1]
	else if(L.len > 1)
		type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
	else
		usr.show_text("No reagents matching that name", "red")
		return
	if(!type) return
	var/datum/reagent/reagent = new type()

	logTheThing("admin", src, "began to convert all space tiles into an ocean of [reagent.id].")
	message_admins("[key_name(src)] began to convert all space tiles into an ocean of [reagent.id]. Oh no.")

	SPAWN_DBG(0)
		ocean_reagent_id = reagent.id
		var/datum/reagents/R = new /datum/reagents(100)
		R.add_reagent(reagent.id, 100)
		ocean_name = "ocean of " + R.get_master_reagent_name()
		ocean_color = R.get_average_color()
		qdel(R)

		for(var/turf/space/S in world)
			LAGCHECK(LAG_HIGH)
			new /turf/space/fluid( locate(S.x, S.y, S.z) )
		message_admins("Finished space replace!")
		map_currently_underwater = 1

client/proc/replace_space_exclusive()
	set name = "Replace All Station-Zlevel Space Tiles With Ocean"
	set desc = "This is the safer one."
	set category="Debug"
	admin_only

	var/list/L = list()
	var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
	if(searchFor)
		for(var/R in childrentypesof(/datum/reagent))
			if(findtext("[R]", searchFor)) L += R
	else
		L = childrentypesof(/datum/reagent)
	var/type = 0
	if(L.len == 1)
		type = L[1]
	else if(L.len > 1)
		type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
	else
		usr.show_text("No reagents matching that name", "red")
		return
	if(!type) return
	var/datum/reagent/reagent = new type()

	logTheThing("admin", src, "began to convert all station space tiles into an ocean of [reagent.id].")
	message_admins("[key_name(src)] began to convert all station space tiles into an ocean of [reagent.id].")

	SPAWN_DBG(0)
		ocean_reagent_id = reagent.id
		var/datum/reagents/R = new /datum/reagents(100)
		R.add_reagent(reagent.id, 100)
		ocean_name = "ocean of " + R.get_master_reagent_name()
		ocean_color = R.get_average_color()
		qdel(R)

#ifndef UNDERWATER_MAP
		for(var/turf/space/S in world)
			if (S.z != 1) continue
			LAGCHECK(LAG_REALTIME)
			new /turf/space/fluid( locate(S.x, S.y, S.z) )
#endif
		message_admins("Finished space replace!")
		map_currently_underwater = 1


client/proc/update_ocean_lighting()
	admin_only
	SPAWN_DBG(0)
		for(var/turf/space/fluid/S in world)
			S.update_light()
			LAGCHECK(LAG_REALTIME)
		message_admins("Finished space light update!!!")


client/proc/dereplace_space()
	set name = "Replace All Ocean Tiles With Space"
	set desc = "uh oh."
	set category="Debug"
	admin_only

	logTheThing("admin", src, "began to convert all ocean tiles into space.")
	message_admins("[key_name(src)] began to convert all ocean tiles into space.")

	SPAWN_DBG(0)
		map_currently_underwater = 0
		for(var/turf/space/fluid/F in world)
			LAGCHECK(LAG_HIGH)
			new /turf/space( locate(F.x, F.y, F.z) )

		message_admins("Finished space dereplace!")
		map_currently_underwater = 0