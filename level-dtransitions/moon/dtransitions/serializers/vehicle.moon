
class DTransitions.VehicleSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'vehicles'

	CanSerialize: (ent) => ent\IsVehicle()
	GetPriority: => 600

	Serialize: (ent) =>
		tag = super(ent)
		return if not tag

		if kv = @SerializeKeyValues(ent)
			tag\SetTag('keyvalues', kv)

		if sv = @SerializeSavetable(ent)
			tag\SetTag('savetable', sv)

		if dt = @SerializeGNetVars(ent)
			tag\SetTag('dt', dt)

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializePreSpawn(ent, tag)
		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))
		@DeserializeSavetable(ent, tag\GetTag('savetable'))

		if not tag\HasTag('map_id')
			ent\Spawn()
			ent\Activate()

		@DeserializePostSpawn(ent, tag)

		return ent
