// Contains:
//
// - obj/item/weapon parent (now unused and commented out)
// - Esword
// - Dagger
// - Butcher's knife
// - Axe
// - Fireaxe
// - Baseball Bat
// - Ban me
// - Katana
// - Bloodthirsty Blade
// - Fragile Sword

////////////////////////////////////////////// Weapon parent //////////////////////////////////
/* unused now
/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
*/
/////////////////////////////////////////////// Esword /////////////////////////////////////////

/obj/item/sword
	name = "cyalume saber"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	item_state = "sword0"
	var/active = 0.0
	var/bladecolor = "G"
	var/list/valid_colors = list("R","O","Y","G","C","B","P","Pi","W")
	hit_type = DAMAGE_BLUNT
	force = 1
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	is_syndicate = 1
	mats = 18
	contraband = 5
	desc = "An illegal weapon that, when activated, uses cyalume to create an extremely dangerous saber. Can be concealed when deactivated."
	stamina_damage = 35
	stamina_cost = 30
	stamina_crit_chance = 35
	var/do_stun = 1 //controlled by itemspecial for csword. sorry.
	var/active_force = 60
	var/inactive_force = 1
	var/state_name = "sword"
	var/off_w_class = 2

	New()
		..()
		src.bladecolor = pick(valid_colors)
		if (prob(1))
			src.bladecolor = null
		src.setItemSpecial(/datum/item_special/swipe/csaber)

/obj/item/sword/attack(mob/target, mob/user, def_zone, is_special = 0)
	if(ishuman(user))
		if(active)
			if (handle_parry(target, user))
				return 1

			if (!is_special)
#ifdef USE_STAMINA_DISORIENT
				target.do_disorient(205, weakened = 50, stunned = 50, disorient = 40, remove_stamina_below_zero = 0)
#else
				target.changeStatus("stunned", 50)
				target.changeStatus("weakened", 5 SECONDS)
#endif

			var/mob/living/carbon/human/U = user
			if(U.gender == MALE) playsound(get_turf(U), pick('sound/weapons/male_cswordattack1.ogg','sound/weapons/male_cswordattack2.ogg'), 70, 0, 0, max(0.7, min(1.2, 1.0 + (30 - U.bioHolder.age)/60)))
			else playsound(get_turf(U), pick('sound/weapons/female_cswordattack1.ogg','sound/weapons/female_cswordattack2.ogg'), 70, 0, 0, max(0.7, min(1.4, 1.0 + (30 - U.bioHolder.age)/50)))
			..()
		else
			if (user.a_intent == INTENT_HELP)
				user.visible_message("<span class='combat bold'>[user] [pick_string("descriptors.txt", pick("mopey", "borg_shake"))] baps [target] on the [pick("nose", "forehead", "wrist", "chest")] with \the [src]'s handle!</span>")
				if(prob(3))
					SPAWN_DBG(2)
						target.visible_message("<span class='bold'>[target.name]</span> flops over in shame!")
						target.changeStatus("stunned", 50)
						target.changeStatus("weakened", 5 SECONDS)
			else
				..()

/obj/item/sword/proc/handle_parry(mob/target, mob/user)
	if (target != user && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/sword/S = H.find_type_in_hand(/obj/item/sword, "right")
		if (!S)
			S = H.find_type_in_hand(/obj/item/sword, "left")
		if (S && S.active)
			var/obj/itemspecialeffect/clash/C = unpool(/obj/itemspecialeffect/clash)
			if(target.gender == MALE) playsound(get_turf(target), pick('sound/weapons/male_cswordattack1.ogg','sound/weapons/male_cswordattack2.ogg'), 70, 0, 0, max(0.7, min(1.2, 1.0 + (30 - H.bioHolder.age)/60)))
			else playsound(get_turf(target), pick('sound/weapons/female_cswordattack1.ogg','sound/weapons/female_cswordattack2.ogg'), 70, 0, 0, max(0.7, min(1.4, 1.0 + (30 - H.bioHolder.age)/50)))
			C.setup(H.loc)
			var/matrix/m = matrix()
			m.Turn(rand(0,360))
			C.transform = m
			var/matrix/m1 = C.transform
			m1.Scale(2,2)
			C.pixel_x = 32*(user.x - target.x)*0.5
			C.pixel_y = 32*(user.y - target.y)*0.5
			animate(C,transform=m1,time=8)
			H.remove_stamina(40)
			if (ishuman(user))
				var/mob/living/carbon/human/U = user
				U.remove_stamina(15)

			return 1
	return 0


/obj/item/sword/attack_self(mob/user as mob)
	if (user.bioHolder.HasEffect("clumsy") && prob(50))
		user.visible_message("<span style=\"color:red\"><b>[user]</b> fumbles [src] and cuts \himself.</span>")
		user.TakeDamage(user.hand == 1 ? "l_arm" : "r_arm", 5, 5)
		take_bleeding_damage(user, user, 5)
	src.active = !( src.active )
	if (src.active)
		boutput(user, "<span style=\"color:blue\">The sword is now active.</span>")
		hit_type = DAMAGE_CUT
		if(ishuman(user))
			var/mob/living/carbon/human/U = user
			if(U.gender == MALE) playsound(get_turf(U),"sound/weapons/male_cswordstart.ogg", 70, 0, 0, max(0.7, min(1.2, 1.0 + (30 - U.bioHolder.age)/60)))
			else playsound(get_turf(U),"sound/weapons/female_cswordturnon.ogg" , 100, 0, 0, max(0.7, min(1.4, 1.0 + (30 - U.bioHolder.age)/50)))
		src.force = active_force
		if (src.bladecolor)
			if (!(src.bladecolor in src.valid_colors))
				src.bladecolor = null
		src.icon_state = "[state_name]1-[src.bladecolor]"
		src.item_state = "[state_name]1-[src.bladecolor]"
		src.w_class = 4
		user.unlock_medal("The Force is strong with this one", 1)
	else
		boutput(user, "<span style=\"color:blue\">The sword can now be concealed.</span>")
		hit_type = DAMAGE_BLUNT
		if(ishuman(user))
			var/mob/living/carbon/human/U = user
			if(U.gender == MALE) playsound(get_turf(U),"sound/weapons/male_cswordturnoff.ogg", 70, 0, 0, max(0.7, min(1.2, 1.0 + (30 - U.bioHolder.age)/60)))
			else playsound(get_turf(U),"sound/weapons/female_cswordturnoff.ogg", 100, 0, 0, max(0.7, min(1.4, 1.0 + (30 - U.bioHolder.age)/50)))
		src.force = inactive_force
		src.icon_state = "[state_name]0"
		src.item_state = "[state_name]0"
		src.w_class = off_w_class
	user.update_inhands()
	src.add_fingerprint(user)
	..()

/obj/item/sword/custom_suicide = 1
/obj/item/sword/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (!src.active)
		return 0

	user.visible_message("<span style='color:red'><b>[user] stabs [src] through [his_or_her(user)] chest.</b></span>")
	take_bleeding_damage(user, null, 250, DAMAGE_STAB)
	user.TakeDamage("chest", 200, 0)
	user.updatehealth()
	SPAWN_DBG(500)
		if (user && !isdead(user))
			user.suiciding = 0
	return 1

/obj/item/sword/vr
	icon = 'icons/effects/VR.dmi'
	inhand_image_icon = 'icons/effects/VR_csaber_inhand.dmi'
	valid_colors = list("R","Y","G","C","B","P","W","Bl")

/obj/item/sword/discount
	name = "d-saber"
	desc = "A discount cyalume saber. Commonly called a d-saber."
	state_name = "d_sword"
	icon_state = "d_sword0"
	item_state = "d_sword0"
	valid_colors = list("R")
	off_w_class = 3
	active_force = 18
	inactive_force = 8
	hit_type = DAMAGE_BLUNT

	New()
		..()
		bladecolor = "R"
		processing_items.Add(src)

	examine()
		set src in usr
		src.desc = "It is set to [src.active ? "on" : "off"]."
		..()
		return



/obj/item/sword/discount/attack(mob/target, mob/user, def_zone, is_special = 0)
	//hhaaaaxxxxxxxx. overriding the disorient for my own effect
	is_special = 1
	if (active)
		hit_type = DAMAGE_BURN
	else
		hit_type = DAMAGE_BLUNT

	//returns TRUE if parried. So stop here
	if (..())
		return

	if (active)
		target.do_disorient(65, weakened = 0, stunned = 0, disorient = 30, remove_stamina_below_zero = 0)

		if (prob(30))
			boutput(user, "<span style=\"color:red\">The sword shorted out! The laser turned off!</span>")
			hit_type = DAMAGE_BLUNT
			if(ishuman(user))
				var/mob/living/carbon/human/U = user
				if(U.gender == MALE) playsound(get_turf(U),"sound/weapons/male_cswordturnoff.ogg", 70, 0, 0, max(0.7, min(1.2, 1.0 + (30 - U.bioHolder.age)/60)))
				else playsound(get_turf(U),"sound/weapons/female_cswordturnoff.ogg", 100, 0, 0, max(0.7, min(1.4, 1.0 + (30 - U.bioHolder.age)/50)))
			active = 0
			force = inactive_force
			icon_state = "[state_name]0"
			item_state = "[state_name]0"
			w_class = off_w_class
			user.update_inhands()

///////////////////////////////////////////////// Dagger /////////////////////////////////////////////////

/obj/item/dagger
	name = "sacrificial dagger"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "dagger"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "knife"
	force = 5.0
	throwforce = 15.0
	throw_range = 5
	hit_type = DAMAGE_STAB
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	desc = "Gets the blood to run out juuuuuust right."
	burn_type = 1
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 50
	pickup_sfx = "sound/items/blade_pull.ogg"

/obj/item/dagger/throw_impact(atom/A)
	if(iscarbon(A))
		if (ismob(usr))
			A:lastattacker = usr
			A:lastattackertime = world.time
		A.changeStatus("weakened", 10 SECONDS)
		take_bleeding_damage(A, null, 5, DAMAGE_CUT)
		playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)

/obj/item/dagger/attack(target as mob, mob/user as mob)
	playsound(target, "sound/impact_sounds/Flesh_Stab_1.ogg", 60, 1)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(!isdead(C))
			take_bleeding_damage(C, user, 5, DAMAGE_STAB)
	..()

/obj/item/dagger/smile
	name = "switchblade"
	force = 10.0
	throw_range = 10
	throwforce = 10.0

/obj/item/dagger/smile/attack(mob/living/target as mob, mob/user as mob)
	if(prob(10))
		var/say = pick("Why won't you smile?","Smile!","Why aren't you smiling?","Why is nobody smiling?","Smile like you mean it!","That is not a smile!","Smile, [target.name]!","I will make you smile, [target.name].","[target.name] didn't smile!")
		user.say(say)
	..()

/obj/item/dagger/syndicate
	name = "syndicate dagger"
	desc = "An ornamental dagger for syndicate higher-ups. It sounds fancy, but it's basically the munitions company equivalent of those glass cubes with the company logo frosted on."

/obj/item/dagger/syndicate/specialist //Infiltrator class knife
	name = "syndicate combat knife"
	desc = "A light but robust combat knife that allows you to move faster in fights."
	icon_state = "combat_knife"

	setupProperties()
		..()
		setProperty("movespeed", -0.5)

/obj/item/dagger/throwing_knife
	name = "cheap throwing knife"
	// icon = 'icons/obj/weapons.dmi'
	icon_state = "throwing_knife"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "ninjaknife"
	force = 8.0
	throwforce = 11.0
	throw_range = 10
	flags = FPRINT | TABLEPASS | USEDELAY //| NOSHIELD
	desc = "Like many knives, these can be thrown. Unlike many knives, these are made to be thrown."


	throw_impact(atom/A)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			C.do_disorient(stamina_damage = 60, weakened = 0, stunned = 0, disorient = 40, remove_stamina_below_zero = 1)
			C.emote("twitch_v")
			A:lastattacker = usr
			A:lastattackertime = world.time
			random_brute_damage(C, throwforce)

			take_bleeding_damage(A, null, 5, DAMAGE_CUT)
			playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)

/obj/item/nunchucks
	name = "nunchucks"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "nunchucks"
	item_state = "nunchucks"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	force = 8.0
	throwforce = 6.0
	throw_range = 7
	hit_type = DAMAGE_BLUNT
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	desc = "An ancient and questionably effective weapon."
	burn_type = 0
	stamina_damage = 45
	stamina_cost = 25
	stamina_crit_chance = 60
	// pickup_sfx = "sound/items/blade_pull.ogg"

	New()
		..()
		src.setItemSpecial(/datum/item_special/nunchucks)

/obj/item/quarterstaff
	name = "quarterstaff"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quarterstaff"
	item_state = "quarterstaff"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	uses_multiple_icon_states = 1
	force = 13.0
	throwforce = 6.0
	throw_range = 5
	hit_type = DAMAGE_BLUNT
	w_class = 3.0
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	desc = "An ancient and effective weapon. It's not just a stick alright!"
	stamina_damage = 65
	stamina_cost = 35
	stamina_crit_chance = 60
	// pickup_sfx = "sound/items/blade_pull.ogg"
	// can_disarm = 1
	two_handed = 0
	var/use_two_handed = 1
	var/status = 0
	var/one_handed_force = 7
	var/two_handed_force = 13

	New()
		..()
		src.setItemSpecial(/datum/item_special/simple)

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (!use_two_handed || setTwoHanded(!src.status))
			src.status = !src.status
			// playsound(get_turf(src), "sparks", 75, 1, -1)
			if (src.status)
				setProperty("meleeprot", 3)
				setProperty("movespeed", 0.1)
				force = two_handed_force
				src.setItemSpecial(/datum/item_special/nunchucks)
			else
				setProperty("meleeprot", 0)
				setProperty("movespeed", 0)
				force = one_handed_force
				src.setItemSpecial(/datum/item_special/simple)

			can_disarm = src.status
			item_state = status ? "quarterstaff2" : "quarterstaff1"
			user.update_inhands()
		else
			user.show_text("You need two free hands in order to activate the [src.name].", "red")

		..()

	dropped(mob/user)
		setTwoHanded(0)
		status = 0
		..()
////////////////////////////////////////// Butcher's knife /////////////////////////////////////////

/obj/item/knife_butcher //Idea stolen from the welder!
	name = "Butcher's Knife"
	desc = "A huge knife."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife_b"
	item_state = "knife_b"
	force = 5.0
	throwforce = 15.0
	throw_speed = 4
	throw_range = 8
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	hit_type = DAMAGE_STAB
	var/makemeat = 1

/obj/item/knife_butcher/throw_impact(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if (ismob(usr))
			A:lastattacker = usr
			A:lastattackertime = world.time
		C.changeStatus("weakened", 6 SECONDS)
		C.force_laydown_standup()
		random_brute_damage(C, 20)
		take_bleeding_damage(C, null, 10, DAMAGE_CUT)

		playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)

/obj/item/knife_butcher/attack(target as mob, mob/user as mob)
	if (!istype(src,/obj/item/knife_butcher/predspear) && ishuman(target) && ishuman(user))
		if (scalpel_surgery(target,user))
			return

	playsound(target, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)

	if (iscarbon(target))
		var/mob/living/carbon/C = target
		if (!isdead(C))
			random_brute_damage(C, 20)
			take_bleeding_damage(C, user, 10, DAMAGE_STAB)
		else
			if (src.makemeat)
				logTheThing("combat", user, C, "butchers [C]'s corpse with the [src.name] at [log_loc(C)].")
				var/sourcename = C.real_name
				var/sourcejob = "Stowaway"
				if (C.mind && C.mind.assigned_role)
					sourcejob = C.mind.assigned_role
				else if (C.ghost && C.ghost.mind && C.ghost.mind.assigned_role)
					sourcejob = C.ghost.mind.assigned_role
				for (var/i=0, i<3, i++)
					var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/meat = new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat(get_turf(C))
					meat.name = sourcename + meat.name
					meat.subjectname = sourcename
					meat.subjectjob = sourcejob
				if (C.mind)
					C.ghostize()
					qdel(C)
					return
				else
					qdel(C)
					return
	..()
	return

/obj/item/knife_butcher/custom_suicide = 1
/obj/item/knife_butcher/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span style='color:red'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
	blood_slash(user, 25)
	user.TakeDamage("head", 150, 0)
	user.updatehealth()
	return 1

/////////////////////////////////////////////////// Hunter Spear ////////////////////////////////////////////

/obj/item/knife_butcher/predspear
	name = "Hunting Spear"
	desc = "A very large, sharp spear."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "predspear"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "knife_b"
	force = 8.0
	throwforce = 35.0
	throw_speed = 6
	throw_range = 10
	makemeat = 0

/////////////////////////////////////////////////// Axe ////////////////////////////////////////////

/obj/item/axe
	name = "Axe"
	desc = "An energised battle axe."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "axe0"
	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	var/active = 0.0
	hit_type = DAMAGE_CUT
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	contraband = 80
	flags = FPRINT | CONDUCT | NOSHIELD | TABLEPASS | USEDELAY
	tool_flags = TOOL_CUTTING
	stamina_damage = 50
	stamina_cost = 45
	stamina_crit_chance = 5

// vvv what the heck why?? vvv
//obj/item/axe/attack(target as mob, mob/user as mob)
//	..()

/obj/item/axe/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		boutput(user, "<span style=\"color:blue\">The axe is now energised.</span>")
		src.hit_type = DAMAGE_BURN
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = 5
	else
		boutput(user, "<span style=\"color:blue\">The axe can now be concealed.</span>")
		src.hit_type = DAMAGE_CUT
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = 5
	src.add_fingerprint(user)
	user.update_inhands()
	return

/obj/item/axe/custom_suicide = 1
/obj/item/axe/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span style='color:red'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
	blood_slash(user, 25)
	user.TakeDamage("head", 150, 0)
	user.updatehealth()
	return 1

/obj/item/axe/vr
	icon = 'icons/effects/VR.dmi'

/////////////////////////////////////////////////// Fire Axe ////////////////////////////////////////////

/obj/item/fireaxe
	name = "fire axe"
	desc = "An axe with a pick-shaped end on the back, intended to be used to get through doors and windows in an emergency."
	icon = 'icons/obj/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "fireaxe"
	item_state = "fireaxe"
	flags = FPRINT | CONDUCT | TABLEPASS | USEDELAY
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING //TOOL_CHOPPING flagged items to 4 times as much damage to doors.
	damtype = "brute"
	hit_type = DAMAGE_CUT
	click_delay = 10
	two_handed = 0

	w_class = 3
	force = 15
	throwforce = 5
	throw_speed = 2
	throw_range = 4
	stamina_damage = 10
	stamina_cost = 15
	stamina_crit_chance = 2

	proc/set_values()
		if(two_handed)
			src.click_delay = 15
			force = 30
			throwforce = 20
			throw_speed = 4
			throw_range = 8
			stamina_damage = 30
			stamina_cost = 20
			stamina_crit_chance = 5
		else
			src.click_delay = 10
			force = 15
			throwforce = 5
			throw_speed = 2
			throw_range = 4
			stamina_damage = 10
			stamina_cost = 15
			stamina_crit_chance = 2
		return

	attack_self(mob/user as mob)
		if(ishuman(user))
			if(two_handed)
				setTwoHanded(0) //Go 1-handed.
				set_values()
			else
				if(!setTwoHanded(1)) //Go 2-handed.
					boutput(user, "<span style=\"color:red\">Can't switch to 2-handed while your other hand is full.</span>")
				else
					set_values()
		..()

	attack_hand(var/mob/user as mob) // todo: maybe make the base/twohand delays into vars. maybe.
		src.two_handed = 0
		set_values()
		return ..()

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

///////////////////////////////// Baseball Bat ////////////////////////////////////////////////////////////

/obj/item/bat
	name = "Baseball Bat"
	desc = "Play ball! Note: Batter is responsible for any injuries sustained due to ball-hitting."
	icon = 'icons/obj/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "baseballbat"
	item_state = "baseballbat"
	hit_type = DAMAGE_BLUNT
	force = 12
	throwforce = 7
	stamina_damage = 24
	stamina_cost = 30
	stamina_crit_chance = 15

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

/obj/item/ratstick
	name = "rat stick"
	desc = "Used for killing rats... Among other things."
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon = 'icons/obj/weapons.dmi'
	icon_state = "ratstick"
	item_state = "ratstick"
	hit_type = DAMAGE_BLUNT
	force = 10
	throwforce = 7
	stamina_damage = 35
	stamina_cost = 25
	stamina_crit_chance = 35

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

	attack(var/atom/A as mob|obj|turf, var/mob/user as mob)
		if (prob(50))
			hit_type = DAMAGE_BLUNT
			hitsound = "sound/impact_sounds/Generic_Hit_1.ogg"

		else
			hit_type = DAMAGE_CUT
			hitsound = "sound/impact_sounds/Blade_Small_Bloody.ogg"
		return ..()
/////////////////////////////////////////////////// Ban me ////////////////////////////////////////////

/obj/item/banme
	name = "ban me"
	desc = "Sometimes known as a... what is this?"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "banh_mi"
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/banme/attack(mob/M, mob/user)
	boutput(M, "<span style=\"color:red\"><b>You have been BANNED by [user]!</b></span>")
	boutput(user, "<span style=\"color:red\"><b>You have BANNED [M]!</b></span>")
	playsound(loc, 'sound/vox/banned.ogg', 60, 1)
	return

/////////////////////////////////////////////////// Katana ////////////////////////////////////////////
//PS the description can be shortened if you find it annoying and you are a jerk.

//You probably want to spawn the sheath in instead of this.
/obj/item/katana
	name = "katana"
	desc = "That's it. I'm sick of all this 'Masterwork Cyalume Saber' bullshit that's going on in the SS13 system right now. Katanas deserve much better than that. Much, much better than that. I should know what I'm talking about. I myself commissioned a genuine katana in Space Japan for 2,400,000 Nuyen (that's about 20,000 credits) and have been practicing with it for almost 2 years now. I can even cut slabs of solid mauxite with my katana. Space Japanese smiths spend light-years working on a single katana and fold it up to a million times to produce the finest blades known to space mankind. Katanas are thrice as sharp as Syndicate sabers and thrice as hard for that matter too. Anything a c-saber can cut through, a katana can cut through better. I'm pretty sure a katana could easily bisect a drunk captain wearing full captain's armor with a simple tap. Ever wonder why the Syndicate never bothered conquering Space Japan? That's right, they were too scared to fight the disciplined Space Samurai and their space katanas of destruction. Even in World War 72, Nanotrasen soldiers targeted the men with the katanas first because their killing power was feared and respected."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	hit_type = DAMAGE_CUT
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	force = 15 //Was at 5, but that felt far too weak. C-swords are at 60 in comparison. 15 is still quite a bit of damage, but just not insta-crit levels.
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	is_syndicate = 1
	contraband = 7 //Fun fact: sheathing your katana makes you 100% less likely to be tazed by beepsky, probably
	w_class = 4
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	// pickup_sfx = "sound/items/blade_pull.ogg"
	custom_suicide = 1
	var/obj/itemspecialeffect/katana_dash/start/start
	var/obj/itemspecialeffect/katana_dash/mid/mid1
	var/obj/itemspecialeffect/katana_dash/mid/mid2
	var/obj/itemspecialeffect/katana_dash/end/end
	var/delimb_prob = 100

	New()
		..()
		start = new/obj/itemspecialeffect/katana_dash/start(src)
		mid1 = new/obj/itemspecialeffect/katana_dash/mid(src)
		mid2 = new/obj/itemspecialeffect/katana_dash/mid(src)
		end = new/obj/itemspecialeffect/katana_dash/end(src)
		src.setItemSpecial(/datum/item_special/katana_dash)

/obj/item/katana/attack(mob/living/carbon/human/target as mob, mob/user as mob)
	if(target == user) //Can't cut off your own limbs, dumbo
		return ..()
	var/zoney = user.zone_sel.selecting
	var/mob/living/carbon/human/H = target
	if (handle_parry(H, user))
		return
	switch(zoney)
		if("head")
			if(!target.limbs.r_arm && !target.limbs.l_arm && !target.limbs.l_leg && !target.limbs.r_leg) //Does the target not have all of their limbs?
				target.organHolder.drop_organ("head") //sever_limb doesn't apply to heads :(
			return ..()
		if("chest")
			return ..()
		if("r_arm")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
		if("l_arm")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
		if("r_leg")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
		if("l_leg")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
	..()

/obj/item/katana/proc/handle_parry(mob/target, mob/user)
	if (target != user && ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H.find_type_in_hand(/obj/item/katana, "right") || H.find_type_in_hand(/obj/item/katana, "left"))
			var/obj/itemspecialeffect/clash/C = unpool(/obj/itemspecialeffect/clash)
			playsound(get_turf(target), pick("sound/effects/sword_clash1.ogg","sound/effects/sword_clash1.ogg"), 70, 0, 0, max(0.7, min(1.2, 1.0 + (30 - H.bioHolder.age)/60)))
			C.setup(H.loc)
			var/matrix/m = matrix()
			m.Turn(rand(0,360))
			C.transform = m
			var/matrix/m1 = C.transform
			m1.Scale(2,2)
			C.pixel_x = 32*(user.x - target.x)*0.5
			C.pixel_y = 32*(user.y - target.y)*0.5
			animate(C,transform=m1,time=8)
			H.remove_stamina(60)
			if (ishuman(user))
				var/mob/living/carbon/human/U = user
				U.remove_stamina(20)

			return 1
	return 0

/obj/item/katana/suicide(var/mob/user as mob)
	user.visible_message("<span style=\"color:red\"><b>[user] thrusts [src] through their stomach!</b></span>")
	var/say = pick("Kono shi wa watashinokazoku ni meiyo o ataeru","Haji no mae no shi", "Watashi wa kyo nagura reta.", "Teki ga katta", "Shinjiketo ga modotte kuru")
	user.say(say)
	blood_slash(user, 25)
	user.TakeDamage("chest", 150, 0)
	user.updatehealth()
	SPAWN_DBG(100)
		if (user)
			user.suiciding = 0
	return 1

/obj/item/katana/self_destructing // for the dojo ronin to wield
	force = 30

	dropped(mob/user)
		..()
		if (isturf(src.loc))
			del(src)
			return

/obj/item/katana/reverse
	icon_state = "katana_reverse"
	name = "reverse blade katana"
	desc = "A sword whose blade is on the wrong side. Crafted by a master who grew to hate the death his weapons caused; which was weird since Oppenheimer has him beat by several orders of magnitude. Considered worthless by many, only a true virtuoso can unleash it's potential."

	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	hit_type = DAMAGE_BLUNT
	force = 18
	throwforce = 5.0
	throw_range = 6
	contraband = 5 //Fun fact: sheathing your katana makes you 100% less likely to be tazed by beepsky, probably
	delimb_prob = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/katana_dash/reverse)

/obj/item/katana_sheath
	name = "katana sheath"
	desc = "It can clean a bloodied katana, and also allows for easier storage of a katana"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana_sheathed"
	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "sheathedhand"
	hit_type = DAMAGE_BLUNT
	force = 1
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 3
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY | ONBELT
	is_syndicate = 1
	var/obj/item/katana/sword_inside = 1
	var/sheathed_state = "katana_sheathed"
	var/sheath_state = "katana_sheath"

	var/ih_sheathed_state = "sheathedhand"
	var/ih_sheath_state = "sheathhand"
	var/sword_path = /obj/item/katana

	New()
		..()
		var/obj/item/katana/K = new sword_path()
		sword_inside = K
		K.set_loc(src)

	attack_hand(mob/living/carbon/human/user as mob)
		if(user.r_hand == src || user.l_hand == src || user.belt == src)
			if(src.sword_inside) //Checks if a katana is inside
				sword_inside.clean_forensic()
				boutput(user, "You draw [sword_inside] from your sheath.")
				icon_state = sheath_state
				item_state = ih_sheath_state
				user.put_in_hand_or_drop(sword_inside)
				sword_inside = null //No more sword inside.
				user.update_clothing()
			else
				return ..()//Katana doesn't exist, and takes the sheath off your belt or switches hands.

		else
			return ..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/katana) && !src.sword_inside && !W.cant_drop == 1)
			icon_state = sheathed_state
			item_state = ih_sheathed_state
			user.u_equip(W)
			W.set_loc(src)
			user.update_clothing()
			src.sword_inside = W //katana SHOULD be in the sheath now.
			boutput(user, "<span style=\"color:blue\">You sheathe [W] in [src].</span>")
		else
			..()
			if(W.cant_drop == 1)
				boutput(user, "<span style=\"color:blue\">You can't sheathe the [W] while its attached to your arm.</span>")

/obj/item/katana_sheath/reverse
	name = "katana sheath"
	desc = "It can clean a bloodied katana, and also allows for easier storage of a katana"
	icon_state = "sheath_reverse1"
	item_state = "sheath_reverse1"

	sheathed_state = "sheath_reverse1"
	sheath_state = "sheath_reverse0"
	ih_sheathed_state = "sheath_reverse1"
	ih_sheath_state = "sheath_reverse0"
	sword_path = /obj/item/katana/reverse

	attackby(obj/item/W as obj, mob/user as mob)
		if (W.type == /obj/item/katana)
			boutput(user, "<span style=\"color:red\">The [W] can't fit into [src].</span>")
			return
		..()

/*
 *							--- Non-electronic Swords ---
 * Below are two swords, the first grows stronger the more you use it, but resets when dropped.
 * The other grows weaker the more you use it, but can be restored with a whetstone.
 * Kinda just proof-of-concepts + me learning about numbers. ~ Gannets
*/

/obj/item/bloodthirsty_blade
	name = "Bloodthirsty Blade"
	desc = "A mysterious blade that hungers for blood & revels in strife. Grows stronger when used for malicious means."
	icon = 'icons/obj/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	wear_image_icon = 'icons/mob/back.dmi' //todo back sprites
	icon_state = "claymore"
	item_state = "longsword"
	flags = ONBACK
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING
	contraband = 5
	w_class = 4
	force = 0
	throwforce = 5
	stamina_damage = 25
	stamina_cost = 25
	stamina_crit_chance = 15
	two_handed = 1
	pickup_sfx = "sound/items/blade_pull.ogg"

	New()
		..()
		name = "[pick("Mysterious","Foreboding","Menacing","Terrifying","Malevolent","Ghastly","Bloodthirsty","Vengeful","Loathsome")] [pick("Sword","Blade","Slicer","Knife","Dagger","Cutlass","Gladius","Cleaver","Chopper","Claymore","Zeitgeist")] of [pick("T'pire Weir Isles","Ballingry","Mossmorran","Auchtertool","Kirkcaldy","Auchmuirbridge","Methil","Muiredge","Swords")]"
		src.setItemSpecial(/datum/item_special/swipe)

	/obj/item/bloodthirsty_blade/attack(target as mob, mob/user as mob)
		playsound(target, "sound/impact_sounds/Blade_Small_Bloody.ogg", 60, 1)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(!isdead(C))
				force += 5
				boutput(user, "<span style=\"color:red\">The [src] delights in the bloodshed, you can feel it grow stronger!</span>")
				take_bleeding_damage(C, user, 5, DAMAGE_STAB)
		..()

	dropped(mob/user)
		..()
		if (isturf(src.loc))
			user.visible_message("<span style='color:red'>As the [src] falls from [user]'s hands, it seems to become duller!</span>")
			force = 5
			return

//obj/item/bloodthirsty_blade/scifi //the same thing but with fancy future sprites

obj/item/fragile_sword
	name = "fragile sword"
	desc = "This great blade has seen many battles, as such it dulls quickly when used."
	icon = 'icons/obj/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "fragile_sword"
	item_state = "fragile_sword"
	hit_type = DAMAGE_CUT
	contraband = 5
	w_class = 4
	force = 60
	throwforce = 60
	stamina_damage = 25
	stamina_cost = 25
	stamina_crit_chance = 15
	pickup_sfx = "sound/items/blade_pull.ogg"
	var/minimum_force = 5
	var/maximum_force = 70

	attack(target as mob, mob/user as mob)
		playsound(target, "sound/impact_sounds/Blade_Small_Bloody.ogg", 60, 1)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(!isdead(C))
				if(force >= minimum_force)
					force -= 5
					boutput(user, "<span style=\"color:red\">The [src]'s edge dulls slightly on impact!</span>")
					take_bleeding_damage(C, user, 5, DAMAGE_STAB)
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/whetstone))
			if(force <= maximum_force)
				force += 5
				boutput(user, "<span style=\"color:blue\">You sharpen the blade of the [src] with the whetstone.</span>")
				playsound(loc, "sound/items/blade_pull.ogg", 60, 1)
		..()

//obj/item/fragile_sword/scifi

obj/item/whetstone
	name = "whetstone"
	desc = "A stone that can sharpen a blade and restore it to it's former glory."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "whetstone"