
class DTransitions.NPCSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'npcs'

	@KEY_VALUES_IGNORANCE = [v for v in *DTransitions.PropSerializer.KEY_VALUES_IGNORANCE]
	table.insert(@KEY_VALUES_IGNORANCE, 'additionalequipment')

	CanSerialize: (ent) => ent\IsNPC()
	GetPriority: => 800

	@NPC_ACTIVITY = {
		--{'ActiveWeapon', 'Entity'}
		{'Activity', 'Short'}
		--{'AimVector', 'Vector'}
		{'ArrivalActivity', 'Short'}
		{'ArrivalSequence', 'Short'}
		{'BlockingEntity', 'Entity'}
		{'CurrentSchedule', 'Short'}
		{'CurrentWeaponProficiency', 'Byte'}
		{'Enemy', 'Entity'}
		{'Expression', 'String'}
		{'HullType', 'Byte'}
		{'MovementActivity', 'Short'}
		{'MovementSequence', 'Short'}
		{'NPCState', 'Byte'}
		{'PathDistanceToGoal', 'Short'}
		{'PathTimeToGoal', 'Int'}
		--{'ShootPos', 'Vector'}
		{'Target', 'Entity'}
	}

	Serialize: (ent) =>
		tag = super(ent)
		return if not tag

		@QuickSerializeObj(tag, ent, @@NPC_ACTIVITY)

		if kv = @SerializeKeyValues(ent)
			tag\SetTag('keyvalues', kv)

		if sv = @SerializeSavetable(ent)
			tag\SetTag('savetable', sv)

		if dt = @SerializeGNetVars(ent)
			tag\SetTag('dt', dt)

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag)

		@QuickDeserializeObj(tag, ent, @@NPC_ACTIVITY, true)
		@DeserializeGNetVars(ent, tag\GetTag('dt'), false)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))
		@DeserializePreSpawn(ent, tag)

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		@DeserializePostSpawn(ent, tag)
		@QuickDeserializeObj(tag, ent, @@NPC_ACTIVITY)
		@DeserializeGNetVars(ent, tag\GetTag('dt'), true)

		return ent
