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
	status_flags = 0
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
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE
	var/sounddelay = 0

/mob/living/simple_animal/hostile/nanite/replicant/OpenFire(var/the_target)
	var/mob/living/simple_animal/hostile/nanite/replicanttendril/A = new /mob/living/simple_animal/hostile/nanite/replicanttendril(src.loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction
	return

/mob/living/simple_animal/hostile/nanite/replicant/proc/soundloop()
	if( sounddelay == 0)
		playsound(src.loc, 'sound/voice/replicanthum.ogg', 100, 1, 8, 8)
		return
	else
		sounddelay = sounddelay -1
		return
/mob/living/simple_animal/hostile/nanite/replicant/AttackingTarget()
	OpenFire()
	set_light(l_range = 4.5, l_power = 2.5, l_color = COLOR_YELLOW)
	soundloop()



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
			del(src)
	..()

/mob/living/simple_animal/hostile/nanite/replicanttendril
	name = "replicant tendril"
	desc = "A thin cord-like tendril made of bio-synthetic mesh, broken off from a larger creature. There are stories of these cords pulling crew to never be seen again..."
	icon = 'zzzz_modular_occulus/icons/mob/replicant.dmi'
	icon_state = "Replicanttendril"
	icon_living = "Replicanttendril"
	icon_aggro = "Replicanttendril"
	icon_dead = "Replicanttendril"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 0
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 60
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "slashes"
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/nanite/replicanttendril/New()
	..()
	spawn(180)
		del(src)

/mob/living/simple_animal/hostile/nanite/replicanttendril/Die()
	del(src)
