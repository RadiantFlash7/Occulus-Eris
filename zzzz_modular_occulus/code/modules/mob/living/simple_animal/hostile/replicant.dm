/mob/living/simple_animal/hostile
	var/idle_vision_range = 9 //If a mob is just idling around, it's vision range is limited to this. Defaults to 9 to keep in line with original simple mob aggro radius
	var/ranged_cooldown_cap = 3 //What ranged attacks, after being used are set to, to go back on cooldown, defaults to 3 life() ticks
	var/retreat_distance = null //If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.


/mob/living/simple_animal/hostile/nanite/proc/GiveTarget(var/new_target)//Step 4, give us our selected target
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
	return

/mob/living/simple_animal/hostile/nanite/proc/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/nanite/proc/LoseAggro()
	stop_automated_movement = 0
	vision_range = idle_vision_range

/mob/living/simple_animal/hostile/nanite/proc/Die()
	LoseAggro()
	mouse_opacity = 1
	..()
	walk(src, 0)

/mob/living/simple_animal/hostile/nanite/
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
	faction = "mining"
	environment_smash = 2
	minbodytemp = 0
	heat_damage_per_tick = 20
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	a_intent = I_HURT
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	var/atom/target // :  Removed type specification so spiders can target doors.


/mob/living/simple_animal/hostile/nanite/replicant
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
	ranged = TRUE
	ranged_cooldown = 5
	ranged_cooldown_cap = 5
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	speed = 3
	maxHealth = 240
	health = 240
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "lashes out at"
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	retreat_distance = 4
	minimum_distance = 4
	var/sounddelay = 0
	var/emp_range = 5
	var/distress_level = 0

/mob/living/simple_animal/hostile/nanite/replicant/New()
	..()
	set_light(2, 2, "#007fff")

/mob/living/simple_animal/hostile/nanite/replicant/OpenFire(var/the_target)
	var/mob/living/simple_animal/hostile/nanite/replicanttendril/A = new /mob/living/simple_animal/hostile/nanite/replicanttendril(src.loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction
	soundloop()

/mob/living/simple_animal/hostile/nanite/replicant/proc/soundloop()
	if( sounddelay == 0)
		playsound(src.loc, 'zzzz_modular_occulus/sound/voice/replicanthum.ogg', 100, 1, 8, 8)
		sounddelay = 60
		return
	else
		sounddelay = (sounddelay -1)
		return

/////////////////Defensive EMP burst starts here///////////////////////
/mob/living/simple_animal/hostile/nanite/replicant/bullet_act()
	.=..()
	defensive_burst()

/mob/living/simple_animal/hostile/nanite/replicant/attackby()
	.=..()
	defensive_burst()
/mob/living/simple_animal/hostile/nanite/replicant/proc/defensive_burst()

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

		playsound(src.loc, 'zzzz_modular_occulus/sound/voice/roboticactivation.ogg', 100, 1, 8, 8)
		visible_message(SPAN_DANGER("[src] emits a electromagnetic pulse, frying nearby electronics!"))
		empulse(get_turf(src), emp_range, emp_range, TRUE)
/////////////////Defensive EMP burst ENDS here///////////////////////

/mob/living/simple_animal/hostile/nanite/replicant/Die()
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

/mob/living/simple_animal/hostile/nanite/replicanttendril
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
	speed = 2
	maxHealth = 35
	health = 35
	melee_damage_lower = 3
	melee_damage_upper = 7
	attacktext = "slices"
	throw_message = "falls right through the strange body of the"
	environment_smash = 0

/mob/living/simple_animal/hostile/nanite/replicanttendril/New()
	..()
	spawn(180)
		qdel(src)

/mob/living/simple_animal/hostile/nanite/replicanttendril/Die()
	visible_message(SPAN_NOTICE("[src] melts away into a pile of ash!"))
	qdel(src)
	new /obj/effect/decal/cleanable/ash