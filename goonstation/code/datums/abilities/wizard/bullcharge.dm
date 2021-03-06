/datum/targetable/spell/bullcharge
	name = "Bull's Charge"
	desc = "Records the casters movement for 4 seconds after which the spell will fire and throw & heavily damage everyone in it's recorded Path."
	icon_state = "bullc" // Vaguely matching placeholder.
	targeted = 0
	cooldown = 150
	requires_robes = 1
	offensive = 1

	cast()
		if(!holder)
			return
		holder.owner.say("RAMI TIN")
		var/mob/living/carbon/human/O = holder.owner
		if(O && istype(O.wear_suit, /obj/item/clothing/suit/wizrobe/necro) && istype(O.head, /obj/item/clothing/head/wizard/necro))
			playsound(holder.owner.loc, "sound/voice/wizard/BullChargeGrim.ogg", 50, 0, -1)
		else if(holder.owner.gender == "female")
			playsound(holder.owner.loc, "sound/voice/wizard/BullChargeFem.ogg", 50, 0, -1)
		else
			playsound(holder.owner.loc, "sound/voice/wizard/BullChargeLoud.ogg", 50, 0, -1)

		var/list/path = list()
		var/turf/first = holder.owner.loc
		var/turf/prev = first
		for(var/i = 0, i < 40, i++)
			var/turf/curr = holder.owner.loc
			animate_bullspellground(curr, "#aaddff")
			if(prev != curr)
				path += curr
				prev = curr
			sleep(1)

		playsound(holder.owner.loc, "sound/voice/animal/bull.ogg", 25, 1, -1)

		var/list/affected = list()
		var/obj/effects/bullshead/B = new/obj/effects/bullshead(first)
		for(var/turf/T in path)
			B.dir = get_dir(B, T)
			B.loc = T
			animate_bullspellground(T, "#5599ff")
			for (var/atom/movable/M in T)
				if (M.anchored || affected.Find(M) || M == holder.owner)
					continue
				affected += M
				SPAWN_DBG(0) M.throw_at(get_edge_cheap(T, B.dir), 30, 1)
				if (ismob(M))
					var/mob/some_idiot = M
					some_idiot.changeStatus("weakened", 3 SECONDS)
					some_idiot.TakeDamage("chest", 33, 0, 0, DAMAGE_BLUNT)
			sleep(1)

		qdel(B)

/obj/effects/bullshead
	name = "magic"
	desc = "i aint gotta explain shit"
	density = 0
	opacity = 0
	anchored = 1
	pixel_x = -32
	pixel_y = -32
	icon = 'icons/effects/96x96.dmi'
	icon_state = "bull"

	New()
		src.alpha = 245
		animate(src, alpha = 1, time = 30)
