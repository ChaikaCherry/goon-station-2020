var/datum/score_tracker/score_tracker

/datum/score_tracker
	// Nice to have somewhere to centralize this shit so w/e
	var/score_calculated = 0
	var/final_score_all = 0
	var/grade = "The Aristocrats!"
	// SECURITY DEPARTMENT
	// var/score_crew_evacuation_rate = 0 save this for later to keep categories balanced
	var/score_crew_survival_rate = 0
	var/score_enemy_failure_rate = 0
	var/final_score_sec = 0
	// ENGINEERING DEPARTMENT
	var/score_power_outages = 0
	var/score_structural_damage = 0
	var/final_score_eng = 0
	// RESEARCH DEPARTMENT
	// CIVILIAN DEPARTMENT
	var/score_cleanliness = 0
	var/score_expenses = 0
	var/final_score_civ = 0
	var/most_xp = "OH NO THIS IS BROKEN"
	var/score_text = null
	var/tickets_text = null

	proc/calculate_score()
		if (score_calculated != 0)
			return
		// Even if its the end of the round it'd probably be nice to just calculate this once and let players grab that
		// instead of calculating it again every time a player wants to look at the score

		// SECURITY DEPARTMENT SECTION
		var/crew_count = 0
		var/fatalities = 0
		var/traitor_objectives = 0
		var/traitor_objectives_failed = 0

		for (var/datum/mind/M in ticker.minds)
			if (M.current && istype(M.current,/mob/dead/observer/))
				var/mob/dead/observer/O = M.current
				if (O.observe_round)
					continue
			if (M in ticker.mode.traitors) // if you're an antag, you're not considered crew
				continue

			crew_count++ // good job you're one of the crew, get counted upon

			if (!M.current || (M.current && isdead(M.current))) // DEAD
				fatalities++

		for (var/datum/mind/traitor in ticker.mode.traitors)
			for (var/datum/objective/objective in traitor.objectives)
				traitor_objectives++
#ifdef CREW_OBJECTIVES
				if (istype(objective, /datum/objective/crew)) continue
#endif
				if (istype(objective, /datum/objective/miscreant)) continue
				if (!objective.check_completion())
					traitor_objectives_failed++

		// special case - if there were no antags for w/e reason you get a free pass i guess?
		if (traitor_objectives == 0)
			score_enemy_failure_rate = 100
		else
			score_enemy_failure_rate = get_percentage_of_fraction_and_whole(traitor_objectives_failed,traitor_objectives)

		score_crew_survival_rate = get_percentage_of_fraction_and_whole(fatalities,crew_count)

		score_crew_survival_rate = CLAMP(score_crew_survival_rate,0,100)
		score_enemy_failure_rate = CLAMP(score_enemy_failure_rate,0,100)

		final_score_sec = (score_crew_survival_rate + score_enemy_failure_rate) * 0.5

		// ENGINEERING DEPARTMENT SECTION
		// also civ cleanliness counted here cos fuck calling a world loop more than once
		var/apc_count = 0
		var/apcs_powered = 0
		var/station_areas = 0
		var/undamaged_areas = 0
		var/clean_areas = 0

		//checking power levels
		for (var/obj/machinery/power/apc/A in machines)
			if (!istype(A.area,/area/station/))
				continue
			apc_count++
			for (var/obj/item/cell/C in A.contents)
				if (get_percentage_of_fraction_and_whole(C.charge,C.maxcharge) >= 85)
					apcs_powered++
			//LAGCHECK(LAG_LOW)

		//checking mess
		for(var/area/station/AR in world)
			station_areas++
			if (get_percentage_of_fraction_and_whole(AR.calculate_structure_value(),AR.initial_structure_value) >= 50)
				undamaged_areas++
			if (AR.calculate_area_cleanliness() >= 80)
				clean_areas++
			//LAGCHECK(LAG_LOW)

		score_power_outages = get_percentage_of_fraction_and_whole(apcs_powered,apc_count)
		score_structural_damage = get_percentage_of_fraction_and_whole(undamaged_areas,station_areas)

		score_power_outages = CLAMP(score_power_outages,0,100)
		score_structural_damage = CLAMP(score_structural_damage,0,100)

		final_score_eng = (score_power_outages + score_structural_damage) * 0.5

		// RESEARCH DEPARTMENT SECTION
		// yeah coming soon or w/e idgaf, fucking academics

		// CIVILIAN DEPARTMENT SECTION
		if (!istype(wagesystem))
			// something glitched out and broke so give them a free pass on it
			score_expenses = 100
		else
			var/profit_target = 300000
			var/totalfunds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
			if (totalfunds == 0)
				score_expenses = 0
			if (totalfunds != totalfunds) //let's see if someone sets the budget to -NaN!
				score_expenses = 100
			else
				score_expenses = get_percentage_of_fraction_and_whole(totalfunds,profit_target)

		score_cleanliness = get_percentage_of_fraction_and_whole(clean_areas,station_areas)

		score_expenses = CLAMP(score_expenses,0,100)
		score_cleanliness = CLAMP(score_cleanliness,0,100)
		final_score_civ = (score_expenses + score_cleanliness) * 0.5

		var/xp_winner = null
		var/curr_xp = 0
		for(var/x in xp_earned)
			if(xp_earned[x] > curr_xp)
				curr_xp = xp_earned[x]
				xp_winner = x

		if(xp_winner)
			most_xp = "[xp_winner]!"
		else
			most_xp = "No one. Dang."

		// AND THE WINNER IS.....

		var/department_score_sum = 0
		department_score_sum = final_score_sec + final_score_eng + final_score_civ

		if (department_score_sum == 0 || department_score_sum != department_score_sum) //check for 0 and for NaN values
			final_score_all = 0
		else
			final_score_all = round(department_score_sum / 3)

		switch(final_score_all)
			if (100 to INFINITY) grade = "NanoTrasen's Finest"
			if (90 to 99) grade = "The Pride of Science Itself"
			if (91 to 95) grade = "Ambassadors of Discovery"
			if (86 to 90) grade = "Missionaries of Science"
			if (81 to 85) grade = "Promotions for Everyone"
			if (76 to 80) grade = "An Excellent Pursuit of Progress"
			if (71 to 75) grade = "Lean Mean Machine Thirteen"
			if (66 to 70) grade = "Best of a Good Bunch"
			if (61 to 65) grade = "Worthy Citizens"
			if (56 to 60) grade = "Ambiguously Ambivalent"
			if (51 to 55) grade = "Not Bad, but Not Good"
			if (46 to 50) grade = "Ambivalently Average"
			if (41 to 45) grade = "Not Worthy of Praise"
			if (36 to 40) grade = "Extremely Unsatisfactory"
			if (31 to 35) grade = "A Bad Bunch"
			if (26 to 30) grade = "The Undesireables"
			if (21 to 25) grade = "Outclassed by Lab Monkeys"
			if (16 to 20) grade = "A Wretched Heap of Scum and Incompetence"
			if (11 to 15) grade = "A Waste of Perfectly Good Oxygen"
			if (06 to 10) grade = "You're All Fired"
			if (01 to 05) grade = "Engine Fodder"
			if (-INFINITY to 0) grade = "Even the Engine Deserves Better"
			else grade = "Somebody fucked something up."

		score_calculated = 1
		boutput(world, "<b>Final Rating: <font size='4'>[final_score_all]%</font></b>")
		boutput(world, "<b>Grade: <font size='4'>[grade]</font></b>")

		for(var/mob/E in mobs)
			if(E.client)
				if (E.client.preferences.view_score)
					E.scorestats()

		return

/mob/proc/scorestats()
	if (score_tracker.score_calculated == 0)
		return

	if (!score_tracker.score_text)
		score_tracker.score_text = {"<B>Round Statistics and Score</B><BR><HR>"}
		score_tracker.score_text += "<B><U>TOTAL SCORE: [round(score_tracker.final_score_all)]%</U></B><BR>"
		score_tracker.score_text += "<B><U>GRADE: [score_tracker.grade]</U></B><BR>"
		score_tracker.score_text += "<BR>"

		score_tracker.score_text += "<B><U>SECURITY DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "<B>Crew Member Survival Rate:</B> [round(score_tracker.score_crew_survival_rate)]%<BR>"
		score_tracker.score_text += "<B>Enemy Objective Failure Rate:</B> [round(score_tracker.score_enemy_failure_rate)]%<BR>"
		score_tracker.score_text += "<B>Total Department Score:</B> [round(score_tracker.final_score_sec)]%<BR>"
		score_tracker.score_text += "<BR>"

		score_tracker.score_text += "<B><U>ENGINEERING DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "<B>Station Structural Integrity:</B> [round(score_tracker.score_structural_damage)]%<BR>"
		score_tracker.score_text += "<B>Station Areas Powered:</B> [round(score_tracker.score_power_outages)]%<BR>"
		score_tracker.score_text += "<B>Total Department Score:</B> [round(score_tracker.final_score_eng)]%<BR>"
		score_tracker.score_text += "<BR>"

		score_tracker.score_text += "<B><U>RESEARCH DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "Scores for this department are not done yet.<br>"
		score_tracker.score_text += "<BR>"

		score_tracker.score_text += "<B><U>CIVILIAN DEPARTMENT</U></B><BR>"
		score_tracker.score_text += "<B>Overall Station Cleanliness:</B> [round(score_tracker.score_cleanliness)]%<BR>"
		score_tracker.score_text += "<B>Profit Made from Initial Budget:</B> [round(score_tracker.score_expenses)]%<BR>"
		score_tracker.score_text += "<B>Total Department Score:</B> [round(score_tracker.final_score_civ)]%<BR>"
		score_tracker.score_text += "<BR>"
	 /* until this is actually done or being worked on im just going to comment it out
		score_tracker.score_text += "<B>Most Experienced:</B> [score_tracker.most_xp]<BR>"
		*/
		score_tracker.score_text += "<HR>"

	src.Browse(score_tracker.score_text, "window=roundscore;size=500x700;title=Round Statistics")

/mob/proc/showtickets()
	if(!data_core.tickets.len && !data_core.fines.len) return

	if (!score_tracker.tickets_text)
		logTheThing("debug", null, null, "Zamujasa/SHOWTICKETS: [world.timeofday] generating showtickets text")

		score_tracker.tickets_text = {"<B>Tickets</B><BR><HR>"}

		if(data_core.tickets.len)
			var/list/people_with_tickets = list()
			for (var/datum/ticket/T in data_core.tickets)
				if(!(T.target in people_with_tickets))
					people_with_tickets += T.target

			for(var/N in people_with_tickets)
				score_tracker.tickets_text += "<b>[N]</b><br><br>"
				for(var/datum/ticket/T in data_core.tickets)
					if(T.target == N)
						score_tracker.tickets_text += "[T.text]<br>"
			score_tracker.tickets_text += "<br>"
		else
			score_tracker.tickets_text += "No tickets were issued!<br><br>"

		score_tracker.tickets_text += {"<B>Fines</B><BR><HR>"}

		if(data_core.fines.len)
			var/list/people_with_fines = list()
			for (var/datum/fine/F in data_core.fines)
				if(!(F.target in people_with_fines))
					people_with_fines += F.target

			for(var/N in people_with_fines)
				score_tracker.tickets_text += "<b>[N]</b><br><br>"
				for(var/datum/fine/F in data_core.fines)
					if(F.target == N)
						score_tracker.tickets_text += "[F.target]: [F.amount] credits<br>Reason: [F.reason]<br>[F.approver ? "[F.issuer != F.approver ? "Requested by: [F.issuer] - [F.issuer_job]<br>Approved by: [F.approver] - [F.approver_job]" : "Issued by: [F.approver] - [F.approver_job]"]" : "Not Approved"]<br>Paid: [F.paid_amount] credits<br><br>"
		else
			score_tracker.tickets_text += "No fines were issued!"
		logTheThing("debug", null, null, "Zamujasa/SHOWTICKETS: [world.timeofday] done")

	src.Browse(score_tracker.tickets_text, "window=tickets;size=500x650")
	return
