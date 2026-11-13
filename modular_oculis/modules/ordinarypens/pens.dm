
/obj/item/pen/red/explosive
	var/tator_lookie = "This pen will cause a small but very powerful explosion when the head is rotated. Fuse time is 1 second per 10 degrees of rotation."

/obj/item/pen/red/explosive/examine(mob/user)
	. = ..()

/obj/item/pen/red/explosive/Initialize(mapload)
	. = ..()
	RegisterSignal(parent, COMSIG_PEN_ROTATED, PROC_REF(handle_rotation))

/obj/item/pen/red/explosive/handle_rotation(degrees_rotated, mob/user)
	if(user.mind)
		var/datum/mind/mymind = user.mind
		if((ROLE_TRAITOR in mymind.special_roles) || mymind.has_faction(ROLE_SYNDICATE))
			to_chat(user, span_warning("...thus arming the internal mechanism."))
	addtimer(CALLBACK(src, PROC_REF(detonate)), degrees_rotated * 0.1 SECONDS)

/obj/item/pen/red/explosive/proc/detonate()
	explosion(src, 1, 2, 2, 0) //no flames because this is TACTICAL by which i mean it's very concentrated and meant to maximize damage to target and minimize collateral damage
	qdel(src)

/obj/item/pen/red/explosive/empen
	tator_lookie = "This pen will cause a powerful EM pulse in a radius of 5 tiles when the head is rotated. Fuse is 1 second per 10 degrees of rotation."

/obj/item/pen/red/explosive/empen/detonate()
	empulse(get_turf(src), 5, 5)

/obj/item/pen/red/explosive/smoke

	tator_lookie = "This pen will release a cloud of choking smoke when the head is rotated. Fuse is 1 second per 10 degrees of rotation."

/obj/item/pen/red/explosive/smoke/detonate()
	do_smoke(5, src, loc, smoke_type = /datum/effect_system/fluid_spread/smoke/bad)

/obj/item/pen/blue/taser
	var/charged = TRUE

/obj/item/pen/blue/taser/examine(mob/user)
	. = ..()
	if((ROLE_TRAITOR in user.special_roles) || user.has_faction(ROLE_SYNDICATE))
		. += span_info("This pen contains a high-voltage capacitor and miniaturized zero-point power plant. Stabbing a target with it will deliver a powerful non-damaging shock. It will have to recharge afterwards.")
		if(charged)
			. += span_info("The internal capacitor is charged.")
		else
			. += span_info("The internal capacitor is recharging.")
	return .

/obj/item/pen/blue/taser/attack(mob/living/M, mob/user, params)
	. = ..()
	if(charged)
		M.electrocute_act(110, src, flags = SHOCK_NOGLOVES | SHOCK_ILLUSION) // it does stamina damage
		charged = FALSE
		addtimer(CALLBACK(src, PROC_REF(recharge)), 60 SECONDS)

/obj/item/pen/blue/taser/proc/recharge()
	charged = TRUE

/obj/item/pen/fountain/cigsynth
	var/charged = TRUE
	heat = 1500
	special_desc_requirement = EXAMINE_CHECK_SYNDICATE
	special_desc = "This syndicate-modified health analyzer can emit delayed bursts of radiation to those it scans."
	var/tator_lookie = "This pen is equipped with an inbuilt lung-damage free healing cigarette synthesizer and lighter, for the classiest of operatives. Click the pen to access this."

/obj/item/pen/fountain/cigsynth/deluxe
	heat = 2000
	force = 31 //mightier than the sword.
	throwforce = 60
	throw_speed = 5
	embedding = list(embed_chance = 100, remove_pain_mult = 60)
	icon_state = "pen-fountain-g"
	desc = "This piece of gold-soaked stationery sits before you. It pierces This is no normal pen. <b>You are unworthy of it.</b>"
	sharpness = SHARP_EDGED | SHARP_POINTY
	wound_bonus = 30
	resistance_flags = FIRE_PROOF | UNACIDABLE | LAVA_PROOF
	item_flags = NO_BLOOD_ON_ITEM | NO_MAT_REDEMPTION
	tool_behaviour = TOOL_MINING
	toolspeed = 0.8
	colour = COLOR_SYNDIE_RED
	tator_lookie = "This pen, the S-2 Fountain Gold, is one of Syndicate high-command's extremely expensive premium in-house models. It can write in zero-gravity, has an integrated high-temperature lighter, synthesizes lung-damage free healing cigarettes, has a nigh-monomolecular edge, is weighted so as to be usable as a throwing weapon, is chemically, thermally, and physically resistant, has an inbuilt chameleon circuit to disguise it as a normal pen on cursory inspection, can be used as a pickaxe, and writes damn good besides. Alt-Click to disguise it."
	var/disguised = FALSE
//it's a REALLY good pen.

/obj/pen/fountain/cigsynth/deluxe/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab, 24) //this doesnt do 24 eye damage this means it does 24 damage on an eyestab instead of 31 on a normal hit

/obj/item/pen/fountain/cigsynth/deluxe/AltClick(mob/user)
	. = ..()
	if(IS_NUKE_OP(user) || IS_TRAITOR(user))
		if(disguised)
			name = initial(name)
			desc = initial(desc)
			force = initial(force)
			throwforce = initial(throwforce)
			throw_speed = initial(throwspeed)
			icon_state = initial(icon_state)
			resistance_flags = initial(resistance_flags)
			tool_behavior = initial(tool_behavior)
			color = initial(color)
			disguised = FALSE
		else
			name = /obj/item/pen::name
			desc = /obj/item/pen::desc
			force = /obj/item/pen::force
			throwforce = /obj/item/pen::throwforce
			throw_speed = /obj/item/pen::throw_speed
			icon_state = /obj/item/pen::icon_state
			color = /obj/item/pen::color
			tool_behavior = null
			resistance_flags = FIRE_PROOF | UNACIDABLE | LAVA_PROOF | HIDE_RESISTANCE
			disguised = TRUE

/obj/item/pen/fountain/cigsynth/examine(mob/user)
	. = ..()
	if (IS_NUKE_OP(user) || IS_TRAITOR(user))
		. += span_info(tator_lookie)
		if(charged)
			. += span_info("The cigarette synthesizer is charged.")
		else
			. += span_info("The cigarette synthesizer is recharging.")
	return .

/obj/item/pen/fountain/cigsynth/proc/recharge()
	charged = TRUE

/obj/item/pen/fountain/cigsynth/attack_self(mob/living/carbon/user)
	if(charged && !disguised)
		var/ciggie = new /obj/item/clothing/mask/cigarette/syndicate/synthesized(src)
		user.put_in_hands(ciggie)
		charged = FALSE
		addtimer(CALLBACK(src, PROC_REF(recharge)), 30 SECONDS)

/obj/item/pen/fourcolor/biosampler
	special_desc_requirement = EXAMINE_CHECK_SYNDICATE
	special_desc = "This pen can be used to discretely sample biomarkers from targets. Change the color for mode selection functionality. Black is for DNA."

/obj/item/pen/fourcolor/biosampler/attack(mob/living/M, mob/user, params)
	. = ..()
	var/did_it_work = TRUE
	if(!iscarbon(M))
		did_it_work = FALSE
	switch(color)
		if("#000000")
			var/mob/living/carbon/ourguy = M
			var/datum/dna/ourdna = ourguy?.dna
			if(ourdna)
				to_chat(user, span_notice("Unique Enzymes: [ourdna.unique_enzymes], Unique Identity: [ourdna.unique_identity]."))
			else
				did_it_work = FALSE
	if(!did_it_work)
		to_chat(user, span_warning("Could not sample biomarkers."))


/obj/item/pen/monkecannon
	var/ammunition = 7
	charged = TRUE

/obj/item/pen/monkecannon/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(!charged || ammunition < 1)
		return
	ammunition -= 1
	var/mob/living/carbon/human/species/monkey/angry/cannonball = new(src.loc)
	ADD_TRAIT(cannonball, TRAIT_EMOTEMUTE, type)
	cannonball.death_sound = ""
	cannonball.death()
	REMOVE_TRAIT(cannonball, TRAIT_EMOTEMUTE, type)
	cannonball.death_sound = initial(cannonball.death_sound)
	cannonball.throw_at(interacting_with, 10, 7, user, TRUE)
	addtimer(CALLBACK(src, PROC_REF(recharge)), 15 SECONDS)

/obj/item/pen/monkecannon/proc/recharge()
	charged = TRUE

/obj/item/laser_pointer/spypen
	effectchance = 100
	upgradable = FALSE
	pointer_icon_state = "red_laser"
	name = /obj/item/pen::name
	desc = /obj/item/pen::desc
	icon = /obj/item/pen::icon
	icon_state = /obj/item/pen::icon_state
	special_desc_requirement = EXAMINE_CHECK_SYNDICATE
	special_desc = "This seemingly-ordinary pen is actually a laser-pointer that can be used to blind enemies or indicate specific talking points on your heist plan whiteboard. Unfortunately, due to the internals being replaced with diode equipment, the pen cannot write."
