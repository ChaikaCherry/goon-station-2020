/datum/movement_controller/pod
	var
		obj/machinery/vehicle/owner

		next_move = 0


		input_x = 0
		input_y = 0
		input_dir = 0

		velocity_x = 0
		velocity_y = 0
		velocity_dir = 0
		velocity_magnitude = 0

		velocity_max = 6
		velocity_max_no_input = 5
		accel = 3

		min_delay = 14

	New(owner)
		src.owner = owner

	disposing()
		owner = null
		..()

	keys_changed(mob/user, keys, changed)
		if (istype(src.owner, /obj/machinery/vehicle/escape_pod))
			return

		if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
			if (!owner.engine) // fuck it, no better place to put this, only triggers on presses
				boutput(user, "[owner.ship_message("WARNING! No engine detected!")]")
				return

			input_x = 0
			input_y = 0
			if (keys & KEY_FORWARD)
				input_y += 1
			if (keys & KEY_BACKWARD)
				input_y -= 1
			if (keys & KEY_RIGHT)
				input_x += 1
			if (keys & KEY_LEFT)
				input_x -= 1

			var/input_magnitude = vector_magnitude(input_x, input_y)
			if (input_magnitude)
				input_x /= input_magnitude
				input_y /= input_magnitude
				input_dir = vector_to_dir(input_x,input_y)

			owner.dir = input_dir
			owner.facing = input_dir

			if (input_x || input_y)
				user.attempt_move()


	process_move(mob/user, keys)
		if (istype(src.owner, /obj/machinery/vehicle/escape_pod))
			return

		if (next_move > world.time)
			return next_move - world.time

		velocity_magnitude = 0
		if (user && user == owner.pilot && !user.getStatusDuration("stunned") && !user.getStatusDuration("weakened") && !user.getStatusDuration("paralysis") && !isdead(user))
			if (owner && owner.engine && owner.engine.active)

				velocity_x	+= input_x * accel
				velocity_y  += input_y * accel

				//normalize and force speed cap
				velocity_magnitude = vector_magnitude(velocity_x, velocity_y)
				var/vel_max = velocity_max + max(owner.speed,0)
				if (!input_x && !input_y)
					vel_max = velocity_max_no_input

				if (velocity_magnitude > vel_max)
					velocity_x /= velocity_magnitude
					velocity_y /= velocity_magnitude

					velocity_x *= vel_max
					velocity_y *= vel_max

				velocity_dir = vector_to_dir(velocity_x,velocity_y)
				owner.flying = velocity_dir

		if (!velocity_magnitude)
			velocity_magnitude = vector_magnitude(velocity_x, velocity_y)


		var/delay = 0

		if (velocity_magnitude)
			delay = 10 / velocity_magnitude

		if (velocity_dir & (velocity_dir-1))
			delay *= 1.4

		delay = min(delay,min_delay)

		if (delay)
			var/target_turf = get_step(owner, velocity_dir)

			owner.glide_size = (32 / delay) * world.tick_lag
			step(owner, velocity_dir)
			owner.glide_size = (32 / delay) * world.tick_lag

			if (owner.loc != target_turf)
				velocity_x = 0
				velocity_y = 0
				velocity_magnitude = 0

			for(var/mob/M in owner) //hey maybe move this somewhere better later. idk man its all chill thou, its all cool, dont worry about it buddy
				M.glide_size = owner.glide_size
				M.animate_movement = SYNC_STEPS

		else
			delay = 1 // stopped

		next_move = world.time + delay
		return delay

	hotkey(mob/user, name)
		switch (name)
			if ("fire")
				owner.fire_main_weapon() // just, fuck it.

	modify_keymap(datum/keymap/keymap, client/C)
		keymap.merge(C.get_keymap("pod"))
