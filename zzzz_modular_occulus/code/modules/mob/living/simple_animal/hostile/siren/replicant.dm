/mob/living/simple_animal/hostile
	var/idle_vision_range = 9 //If a mob is just idling around, it's vision range is limited to this. Defaults to 9 to keep in line with original simple mob aggro radius
	var/ranged_cooldown_cap = 3 //What ranged attacks, after being used are set to, to go back on cooldown, defaults to 3 life() ticks
	var/retreat_distance = null //If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.
	var/search_objects = 0 //If we want to consider objects when searching around, set this to 1. If you want to search for objects while also ignoring mobs until hurt, set it to 2. To completely ignore mobs, even when attacked, set it to 3

/mob/living/simple_animal/hostile/siren/proc/GiveTarget(var/new_target) //Step 4, give us our selected target
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
		log_debug("target assigned to replicant")
	return

/mob/living/simple_animal/hostile/siren/MoveToTarget()		//Custom pathing! attemptto maintain distance if ranged,
	stop_automated_movement = 1
	if(!target_mob || SA_attackable(target_mob))
		stance = HOSTILE_STANCE_IDLE
	if(target_mob in ListTargets(10))
		var/target_distance = get_dist(src,target_mob)
		if(ranged)//We ranged? Shoot at em
			log_debug("ranged!")
			if(target_distance >= 1)//But make sure they're a tile away at least, and our range attack is off cooldown
				OpenFire()
				log_debug("openfired")
		if(isturf(loc) && target_mob.Adjacent(src))	//If they're next to us, attack
			AttackingTarget()
			log_debug("attacking target")
		if(retreat_distance != null && target_distance <= retreat_distance) //If we have a retreat distance, check if we need to run from our target
			walk_away(src,target_mob,retreat_distance,move_to_delay)
			log_debug("Retreated from target")
		else
			Goto(target_mob,move_to_delay,minimum_distance)//Otherwise, get to our minimum distance so we chase them
			log_debug("closing to minimum distance")
		return
	if(target_mob.loc != null && get_dist(src, target_mob.loc) <= vision_range)//We can't see our target, but he's in our vision range still
		if(FindHidden(target_mob) && environment_smash)//Check if he tried to hide in something to lose us
			var/atom/A = target_mob.loc
			Goto(A,move_to_delay,minimum_distance)
			if(A.Adjacent(src))
				A.attack_generic(src)
			log_debug("attack hidden")
			return
		else
			LostTarget()
			log_debug("targetlost2")
	LostTarget()
	log_debug("Target lost 3")

/mob/living/simple_animal/hostile/siren/proc/FindHidden(var/atom/hidden_target)	//THERE IS NO ESCAPE
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		return 1
	else
		return 0

/mob/living/simple_animal/hostile/siren/proc/Goto(var/target, var/delay, var/minimum_distance)
	walk_to(src, target, minimum_distance, delay)


/mob/living/simple_animal/hostile/siren/proc/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/siren/proc/LoseAggro()
	stop_automated_movement = 0
	vision_range = idle_vision_range

/mob/living/simple_animal/hostile/siren/death()
	LoseAggro()
	mouse_opacity = 1
	..()
	walk(src, 0)

/mob/living/simple_animal/hostile/siren			//Some things go bump in the dark
	vision_range = 2
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "siren"
	environment_smash = 15
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	a_intent = I_HURT
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	var/atom/target // :  Removed type specification so spiders can target doors.


/mob/living/simple_animal/hostile/siren/replicant
	name = "replicant"
	desc = "A truly alien creature, it is a mesh of organic and synthetic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'zzzz_modular_occulus/icons/mob/replicant.dmi'
	icon_state = "Replicant"
	icon_living = "Replicant"
	icon_aggro = "Replicant_alert"
	icon_dead = "Replicant_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 14
	ranged = 1
	vision_range = 5
	aggro_vision_range = 11
	idle_vision_range = 9
	speed = 3
	maxHealth = 300
	health = 300
	harm_intent_damage = 25
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "lashes out at"
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	retreat_distance = 6
	minimum_distance = 5
	pass_flags = PASSTABLE
	var/sounddelay = 0
	var/emp_range = 5
	var/distress_level = 0

/mob/living/simple_animal/hostile/siren/replicant/New()
	..()
	set_light(2, 2, "#007fff")

/mob/living/simple_animal/hostile/siren/replicant/OpenFire(var/the_target)
	var/mob/living/simple_animal/hostile/siren/replicanttendril/A = new /mob/living/simple_animal/hostile/siren/replicanttendril(src.loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction
	soundloop()

/mob/living/simple_animal/hostile/siren/replicant/proc/soundloop()
	if( sounddelay == 0)
		playsound(src.loc, 'zzzz_modular_occulus/sound/voice/replicanthum.ogg', 100, 1, 8, 8)
		sounddelay = 15
		return
	else
		sounddelay = (sounddelay -1)
		return

/////////////////Defensive EMP burst starts here///////////////////////
/mob/living/simple_animal/hostile/siren/replicant/bullet_act()
	.=..()
	defensive_burst()

/mob/living/simple_animal/hostile/siren/replicant/attackby()
	.=..()
	defensive_burst()
/mob/living/simple_animal/hostile/siren/replicant/proc/defensive_burst()

	distress_level += 1

	/*
	In order to make it more likely that players will be around to witness it, lets add more distress if we can
	see a human player

	*/
	for (var/mob/living/carbon/human/H in view())
		if (H.stat != DEAD && H.client)
			distress_level += 2
			break

	if (distress_level > 0 && prob(distress_level))

		distress_level = -30 //Once a call is successfully triggered, set the chance negative
		//So it will be a while before this guy can send another call

		playsound(src.loc, 'zzzz_modular_occulus/sound/voice/roboticactivation.wav', 100, 1, 8, 8)
		visible_message(SPAN_DANGER("[src] emits a electromagnetic pulse, frying nearby electronics!"))
		empulse(get_turf(src), emp_range, emp_range, TRUE)
/////////////////Defensive EMP burst ENDS here///////////////////////

/mob/living/simple_animal/hostile/siren/replicant/death()
	new /obj/item/replicant_core(src.loc)
	..()

/obj/item/replicant_core
	name = "Replicant remains"
	desc = "All that remains of a creature, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly. Try not to think about what you're eating."
	icon = 'icons/obj/food.dmi'
	icon_state = "boiledrorocore"
	var/inert = 0

/obj/item/replicant_core/New()
	spawn(1200)
		inert = 1
		desc = "The remains of a hivelord that have become useless, having been left alone too long after being harvested."

/obj/item/replicant_core/attack(mob/living/M as mob, mob/living/user as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(inert)
			user << "<span class='notice'>[src] have become inert, its healing properties are no more.</span>"
			return
		else
			if(H.stat == DEAD)
				user << "<span class='notice'>[src] are useless on the dead.</span>"
				return
			if(H != user)
				H.visible_message("<span class='notice'>[user] forces [H] to eat [src]... they quickly regenerate all injuries!</span>")
			else
				user << "<span class='notice'>You chomp into [src], barely managing to hold it down, but feel amazingly refreshed in mere moments.</span>"
			playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			H.revive()
			qdel(src)
	..()

/mob/living/simple_animal/hostile/siren/replicanttendril
	name = "replicant tendril"
	desc = "A thin cord-like tendril made of bio-synthetic mesh, broken off from a larger creature. There are stories of these cords pulling crew into the darkness to never be seen again..."
	icon = 'zzzz_modular_occulus/icons/mob/replicant.dmi'
	icon_state = "Replicanttendril"
	icon_living = "Replicanttendril"
	icon_aggro = "Replicanttendril"
	icon_dead = "Replicanttendrildead"
	mouse_opacity = 2
	move_to_delay = 0
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 35
	health = 35
	melee_damage_lower = 7
	melee_damage_upper = 14
	attacktext = "slices"
	throw_message = "falls right through the strange body of the"
	environment_smash = 4

/mob/living/simple_animal/hostile/siren/replicanttendril/New()
	..()
	spawn(180)
		qdel(src)

/mob/living/simple_animal/hostile/siren/replicanttendril/death()
	visible_message(SPAN_NOTICE("[src] melts away into a pile of ash!"))
	new /obj/effect/decal/cleanable/ash(loc)
	qdel(src)
