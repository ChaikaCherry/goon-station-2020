// Some misc goods for trade and stuff
//
// CONTENTS:
// Resource container
// Flockburger
// Flocknugget
// Incapacitor
// Flockpod

/////////////////////
// GNESIS CONTAINER
/////////////////////
/obj/item/reagent_containers/gnesis
	name = "fluid-filled octahedron"
	desc = "An octahedral container with a moving fluid inside it. It's not clear how to get the contents of it out."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "minicache"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "beaker"
	rc_flags = RC_VISIBLE | RC_SPECTRO

/obj/item/reagent_containers/gnesis/New()
	..()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("flockdrone_fluid", 50)

////////////////
// FLOCKBURGER
////////////////
/obj/item/reagent_containers/food/snacks/burger/flockburger
	name = "flockburger"
	desc = "Nothing says delicious like a mouth full of glass!"
	icon_state = "flockburger"
	initial_reagents = list("silicon"=10,"limeade"=5,"radium"=1)

////////////////
// FLOCKNUGGET
////////////////
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock
	name = "flocknugget"
	desc = "Well, it isn't any more artificial than your normal chicken nugget. Probably a lot crunchier, too."
	icon_state = "flocknugget0"
	amount = 2
	initial_volume = 20

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock/heal(var/mob/M)
	if (icon_state == "flocknugget0")
		icon_state = "flocknugget1"
	return ..()

////////////////
// INCAPACITOR
////////////////
/obj/item/gun/energy/flock
	name = "incapacitor"
	desc = "A clunky projectile weapon of alien machine origin. It appears to have been based off of a couple pictures of regular human guns, but with no clear understanding of ergonomics."
	icon_state = "incapacitor"
	item_state = "incapacitor"
	force = 1.0
	rechargeable = 0 // yeah this is weird alien technology good fucking luck charging it
	cell = new/obj/item/ammo/power_cell/self_charging
	current_projectile = new/datum/projectile/energy_bolt/flockdrone
	projectiles = null
	is_syndicate = 1 // it's less that this is a syndicate weapon and more that replicating it isn't trivial
	custom_cell_max_capacity = 100

/obj/item/gun/energy/flock/New()
	current_projectile = new/datum/projectile/energy_bolt/flockdrone
	projectiles = list(current_projectile)
	..()

////////////
// FLOCKPOD
////////////