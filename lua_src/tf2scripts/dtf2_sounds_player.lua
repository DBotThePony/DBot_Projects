return [==[// Channels
//	CHAN_AUTO		= 0,
//	CHAN_WEAPON		= 1,
//	CHAN_VOICE		= 2,
//	CHAN_ITEM		= 3,
//	CHAN_BODY		= 4,
//	CHAN_STREAM		= 5,		// allocate stream channel from the static or dynamic area
//	CHAN_STATIC		= 6,		// allocate channel from the static area 
// these can be set with "channel" "2" or "channel" "chan_voice"

//-----------------------------------------------------------------------------
// common attenuation values
//-----------------------------------------------------------------------------

// DON'T USE THESE - USE SNDLVL_ INSTEAD!!!
//	ATTN_NONE		0.0f	
//	ATTN_NORM		0.8f
//	ATTN_IDLE		2.0f
//	ATTN_STATIC		1.25f 
//	ATTN_RICOCHET	1.5f
//	ATTN_GUNFIRE	0.27f

//	SNDLVL_NONE		= 0,
//	SNDLVL_25dB		= 25,
//	SNDLVL_30dB		= 30,
//	SNDLVL_35dB		= 35,
//	SNDLVL_40dB		= 40,
//	SNDLVL_45dB		= 45,
//	SNDLVL_50dB		= 50,	// 3.9
//	SNDLVL_55dB		= 55,	// 3.0
//	SNDLVL_IDLE		= 60,	// 2.0
//	SNDLVL_TALKING	= 60,	// 2.0
//	SNDLVL_60dB		= 60,	// 2.0
//	SNDLVL_65dB		= 65,	// 1.5
//	SNDLVL_STATIC	= 66,	// 1.25
//	SNDLVL_70dB		= 70,	// 1.0
//	SNDLVL_NORM		= 75,
//	SNDLVL_75dB		= 75,	// 0.8
//	SNDLVL_80dB		= 80,	// 0.7
//	SNDLVL_85dB		= 85,	// 0.6
//	SNDLVL_90dB		= 90,	// 0.5
//	SNDLVL_95dB		= 95,
//	SNDLVL_100dB	= 100,	// 0.4
//	SNDLVL_105dB	= 105,
//	SNDLVL_120dB	= 120,
//	SNDLVL_130dB	= 130,
//	SNDLVL_GUNFIRE	= 140,	// 0.27
//	SNDLVL_140dB	= 140,	// 0.2
//	SNDLVL_150dB	= 150,	// 0.2


"DTF2_Scout.DodgeCanOpen"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"1"
	"soundlevel"	"SNDLVL_84dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/pl_scout_dodge_can_open.wav"
}

"DTF2_Scout.DodgeCanDrinkFast"
{
	"channel"		"CHAN_WEAPON"
	"volume"		".25"
	"soundlevel"	"SNDLVL_84dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/pl_scout_dodge_can_drink_fast.wav"
}

"DTF2_Scout.DodgeCanDrink"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"1"
	"soundlevel"	"SNDLVL_84dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/pl_scout_dodge_can_drink.wav"
}

"DTF2_Scout.DodgeCanCrush"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"1"
	"soundlevel"	"SNDLVL_84dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/pl_scout_dodge_can_crush.wav"
}

"DTF2_Scout.DodgeCanPitch"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"1"
	"soundlevel"	"SNDLVL_84dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/pl_scout_dodge_can_pitch.wav"
}


"DTF2_Scout.DodgeTired"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1"
	"soundlevel"	"SNDLVL_74dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/pl_scout_dodge_tired.wav"
}

"DTF2_Player.Spawn"
{
	"channel"		"CHAN_BODY"
	"volume"		"VOL_NORM"
	"soundlevel"	"SNDLVL_NONE"
	"pitch"			"PITCH_NORM"
	"wave"			"misc/null.wav"
}

"DTF2_Player.UseDeny"
{
	"channel"		"CHAN_BODY"
	"volume"		"1"
	"soundlevel"	"SNDLVL_NORM"

	"wave"	"common/wpn_denyselect.wav"
}

"DTF2_Player.WeaponSelected"
{
	"channel"	"CHAN_BODY"
	"volume"	"VOL_NORM"
	"soundlevel"  "SNDLVL_NONE"
	"pitch"	"PITCH_NORM"

	"wave"	"common/wpn_select.wav"
}

"DTF2_Player.DenyWeaponSelection"
{
	"channel"		"CHAN_BODY"
	"volume"		"1"
	"soundlevel"	"SNDLVL_NORM"

	"wave"	"common/wpn_denyselect.wav"
}

"DTF2_Player.WeaponSelectionOpen"
{
	"channel"	"CHAN_BODY"
	"volume"	"0.32"
	"soundlevel"  "SNDLVL_NONE"
	"pitch"	"PITCH_NORM"

	"wave"	"common/null.wav"
}

"DTF2_Player.WeaponSelectionClose"
{
	"channel"	"CHAN_BODY"
	"volume"	"VOL_NORM"
	"soundlevel"  "SNDLVL_NONE"
	"pitch"	"PITCH_NORM"

	"wave"	"common/null.wav"
}

"DTF2_Player.WeaponSelectionMoveSlot"
{
	"channel"	"CHAN_BODY"
	"volume"	"0.5"
	"soundlevel"  "SNDLVL_NONE"
	"pitch"	"PITCH_NORM"

	"wave"	"common/wpn_moveselect.wav"
}

"DTF2_Player.FallGib"
{
	"channel"	"CHAN_STATIC"
	"volume"	"VOL_NORM"
	"pitch"		"92,96"
	"soundlevel"	"SNDLVL_NORM"
	"wave"		"player/pl_fleshbreak.wav"
}

"DTF2_Player.FallDamage"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.75"
	"pitch"		"92,96"
	"soundlevel"	"SNDLVL_NORM"
	"wave"		"player/pl_fallpain.wav"
}

"DTF2_Player.PlasmaDamage"
{
	"channel"	"CHAN_BODY"
	"volume"	"0.5"
	"soundlevel"  "SNDLVL_75dB"

	"wave"		"player/general/flesh_burn.wav"
}

"DTF2_Player.SonicDamage"
{
	"channel"	"CHAN_BODY"
	"volume"	"0.7"
	"soundlevel"  "SNDLVL_75dB"
	"wave"	"player/pain.wav"
}

"DTF2_Player.DrownStart"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"  "SNDLVL_75dB"
	"pitch"		"90,110"

	"wave"	"player/pl_drown1.wav"
}

"DTF2_Player.DrownContinue"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"  "SNDLVL_75dB"
	"pitch"		"95,105"

	"rndwave"
	{
		"wave"	"player/pl_drown1.wav"
		"wave"	"player/pl_drown2.wav"
		"wave"	"player/pl_drown3.wav"
	}
}

"DTF2_Player.AmbientUnderWater"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.22"
	"soundlevel"  "SNDLVL_75dB"

	"wave"	"ambient/water/underwater.wav"
}

"DTF2_Player.PickupWeapon"
{
	"channel"	"CHAN_BODY"
	"volume"	"0.8"
	"soundlevel"  "SNDLVL_75dB"
	"pitch"	"95,105"
	"wave"	"items/ammo_pickup.wav"
}


"DTF2_Geiger.BeepLow"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NONE"
	"pitch"			"PITCH_NORM"

	"rndwave"
	{
		"wave"	"player/geiger1.wav"
		"wave"	"player/geiger2.wav"
	}
}

"DTF2_Player.OnFire"
{
	"channel"	"CHAN_BODY"
	"volume"	"0.8"
	"soundlevel"  	"SNDLVL_75dB"	
	"pitch"		"PITCH_NORM"

	"rndwave"
	{
		"wave"	"ambient/fire/fire_small_loop1.wav"
		"wave"	"ambient/fire/fire_small_loop2.wav"
	}
}

"DTF2_Player.ReceiveSouls"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"	
	"pitch"		"PITCH_NORM"

	"rndwave"
	{
		"wave"	"player/souls_receive1.wav"
		"wave"	"player/souls_receive2.wav"
		"wave"	"player/souls_receive3.wav"
	}
}

"DTF2_Player.ResistanceLight"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"soundlevel"  	"SNDLVL_75dB"	
	"pitch"			"90, 110"

	"rndwave"
	{
		"wave"		")player/resistance_light1.wav"
		"wave"		")player/resistance_light2.wav"
		"wave"		")player/resistance_light3.wav"
		"wave"		")player/resistance_light4.wav"
	}
}

"DTF2_Player.ResistanceMedium"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"soundlevel"  	"SNDLVL_75dB"	
	"pitch"			"90, 110"

	"rndwave"
	{
		"wave"		")player/resistance_medium1.wav"
		"wave"		")player/resistance_medium2.wav"
		"wave"		")player/resistance_medium3.wav"
		"wave"		")player/resistance_medium4.wav"
	}
}

"DTF2_Player.ResistanceHeavy"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"soundlevel"  	"SNDLVL_75dB"	
	"pitch"			"90, 110"

	"rndwave"
	{
		"wave"		")player/resistance_heavy1.wav"
		"wave"		")player/resistance_heavy2.wav"
		"wave"		")player/resistance_heavy3.wav"
		"wave"		")player/resistance_heavy4.wav"
	}
}

//=========================================================================


"DTF2_TFPlayer.Decapitated"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  "SNDLVL_85dB"
	"pitch"	"PITCH_NORM"
	"wave"	")player/flow.wav"
}

"DTF2_TFPlayer.StunImpact"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  "SNDLVL_85dB"
	"pitch"	"PITCH_NORM"
	"wave"	"player/pl_impact_stun.wav"
}

"DTF2_TFPlayer.StunImpactRange"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  "SNDLVL_105dB"
	"pitch"	"PITCH_NORM"
	"wave"	"player/pl_impact_stun_range.wav"
}

"DTF2_TFPlayer.AirBlastImpact"
{
	"soundlevel"		"SNDLVL_75dB"
	"volume"		"1"
	"pitch"			"PITCH_NORM"
	"rndwave"
	{
		"wave"		"player/pl_impact_airblast1.wav"
		"wave"		"player/pl_impact_airblast2.wav"
		"wave"		"player/pl_impact_airblast3.wav"
		"wave"		"player/pl_impact_airblast4.wav"
	}
}

"DTF2_TFPlayer.FlareImpact"
{
	"soundlevel"		"SNDLVL_75dB"
	"volume"		"0.7"
	"pitch"			"PITCH_NORM"
	"rndwave"
	{
		"wave"		"player/pl_impact_flare1.wav"
		"wave"		"player/pl_impact_flare2.wav"
		"wave"		"player/pl_impact_flare3.wav"
	}
}

"DTF2_TFPlayer.Drown"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"pitch"		"95,105"

	"rndwave"
	{
		"wave"	"player/drown1.wav"	
		"wave"	"player/drown2.wav"
		"wave"	"player/drown3.wav"	
	}
}

"DTF2_TFPlayer.Pain"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"pitch"		"92,96"
	"wave"		"player/pain.wav"
}

"DTF2_TFPlayer.FlameOut"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"pitch"		"PITCh_NORM"
	"wave"		")player/flame_out.wav"
}


"DTF2_TFPlayer.AttackerPain"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_95dB"
	"pitch"		"92,96"
	"wave"		"player/death.wav"
}

"DTF2_TFPlayer.FirePain"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_95dB"
	"pitch"		"92,96"
	"wave"		"player/fire.wav"
}

"DTF2_TFPlayer.CritPain"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"pitch"		"95,105"
	
	"rndwave"
	{
		"wave"		"player/crit_received1.wav"
		"wave"		"player/crit_received2.wav"
		"wave"		"player/crit_received3.wav"

	}
}

"DTF2_TFPlayer.CritDeath"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_95dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/death.wav"
}

"DTF2_TFPlayer.MedicChargedDeath"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_95dB"
	"pitch"		"PITCH_NORM"
	"wave"		"player/medic_charged_death.wav"
}

"DTF2_Player.Death"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"pitch"		"92,96"
	"wave"		"player/pain.wav"
}

"DTF2_Player.MeleeDeath"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"pitch"		"92,96"
	"wave"		"player/death.wav"

}

"DTF2_Player.ExplosionDeath"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"pitch"		"92,96"
	"wave"		"player/pain.wav"
}

"DTF2_TFPlayer.GrenadeTimer"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"

	"wave"		"weapons/timer.wav"
}

"DTF2_Player.Spy_Disguise"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_65dB"
	"wave"		"player/spy_disguise.wav"
}

"DTF2_Player.Spy_Shield_Break"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/spy_shield_break.wav"
}

"DTF2_Player.Spy_Cloak"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_85dB"
	"wave"		"player/spy_cloak.wav"
}

"DTF2_Player.Spy_UnCloakReduced"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.5"
	"soundlevel"  	"SNDLVL_40dB"
	"wave"		"player/spy_uncloak.wav"
}

"DTF2_Player.Spy_UnCloak"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_85dB"
	"wave"		"player/spy_uncloak.wav"
}

"DTF2_Player.Spy_UnCloakFeignDeath"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.7"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/spy_uncloak_feigndeath.wav"
}

"DTF2_Player.ScoutShove"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"	
	"rndwave"
	{
		"wave"		"player/shove1.wav"
		"wave"		"player/shove2.wav"
		"wave"		"player/shove3.wav"
		"wave"		"player/shove4.wav"
		"wave"		"player/shove5.wav"
		"wave"		"player/shove6.wav"	
		"wave"		"player/shove7.wav"
		"wave"		"player/shove8.wav"
		"wave"		"player/shove9.wav"
		"wave"		"player/shove10.wav"
	}
}

"DTF2_TFPlayer.SaveMe"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_86dBM"

	"rndwave"
	{
		"wave"		"vo/medic1.mp3"
		"wave"		"vo/medic2.mp3"
	}
}

"DTF2_TFPlayer.InvulnerableOn"
{
	"channel"	"CHAN_STATIC"
	"volume"	".5"
	"soundlevel"  	"SNDLVL_86dB"
	"wave"		"player/invulnerable_on.wav"
}

"DTF2_TFPlayer.QuickFixInvulnerableOn"
{
	"channel"	"CHAN_STATIC"
	"volume"	".5"
	"soundlevel"  	"SNDLVL_86dB"
	"wave"		"player/quickfix_invulnerable_on.wav"
}

"DTF2_TFPlayer.InvulnerableOff"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_86dB"
	"wave"		"player/invulnerable_off.wav"
}

"DTF2_TFPlayer.MegaHealOn"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_74dB"
	"volume"	"1"
	"wave"		")weapons/weapon_crit_charged_on.wav"
}

"DTF2_TFPlayer.MegaHealOff"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_74dB"
	"volume"	"1"
	"wave"		")weapons/weapon_crit_charged_off.wav"
}

"DTF2_TFPlayer.CritHit"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"player/crit_hit.wav"
		"wave"		"player/crit_hit2.wav"
		"wave"		"player/crit_hit3.wav"
		"wave"		"player/crit_hit4.wav"
		"wave"		"player/crit_hit5.wav"
	}
}

"DTF2_TFPlayer.CritHitMini"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"player/crit_hit_mini.wav"
		"wave"		"player/crit_hit_mini2.wav"
		"wave"		"player/crit_hit_mini3.wav"
		"wave"		"player/crit_hit_mini4.wav"
		"wave"		"player/crit_hit_mini5.wav"
	}
}

"DTF2_TFPlayer.DoubleDonk"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_85dB"
	"wave"		")player\doubledonk.wav"
}

"DTF2_TFPlayer.FreezeCam"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"misc/freeze_cam.wav"
}

"DTF2_TFPlayer.ReCharged"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/recharged.wav"
}

"DTF2_TFPlayer.Dissolve"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/dissolve.wav"
}

//-----------------------------------------------------------------------------
//Taunts and Selection Menu
//-----------------------------------------------------------------------------
"DTF2_Taunt.EngineerGunSlinger"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		")player/taunt_eng_gunslinger.wav"
}

"DTF2_Taunt.EngineerSwoosh"
{
	"channel"	"CHAN_WEAPON"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		")player/taunt_eng_swoosh.wav"
}

"DTF2_Taunt.EngineerSmash"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"
	"rndwave"
	{
		"wave"		")player/taunt_eng_smash1.wav"
		"wave"		")player/taunt_eng_smash2.wav"
		"wave"		")player/taunt_eng_smash3.wav"
	}
}

"DTF2_Taunt.EngineerStrum"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		")player/taunt_eng_strum.wav"
}

"DTF2_Taunt.Engineer01HandClap"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_hand_clap.wav"
}

"DTF2_Taunt.Engineer01HandClap2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_hand_clap2.wav"
}

"DTF2_Taunt.Engineer01FootStomp"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Engineer01FootStompLight"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_foot_stomp_light.wav"
}

"DTF2_Taunt.Engineer02PistolTwirl"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_pistol_twirl.wav"
}

"DTF2_Taunt.Engineer_Western_Shoot1"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1,0"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		")player/taunt_western_shoot1.wav"
}

"DTF2_Taunt.Engineer_Western_Shoot2"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		")player/taunt_western_shoot2.wav"
}

"DTF2_Selection.EngineerWrenchShoulder"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_shotgun_shoulder.wav"
}

"DTF2_Selection.EngineerFootStomp"
{
	"channel"	"CHAN_STATIC"
	"volume"	".5"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_foot_stomp.wav"
}

"DTF2_Selection.EngineerClothesRustle"
{
	"channel"	"CHAN_STATIC"
	"volume"	".5"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_clothes_rustle.wav"
}

"DTF2_Taunt.Demo01FootStompLight"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_foot_stomp_light.wav"
}

"DTF2_Taunt.Demo01FootSpin"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_foot_spin.wav"
}

"DTF2_Taunt.Demo01HandClap"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_hand_clap.wav"
}

"DTF2_Taunt.Demo01HandClap2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_hand_clap2.wav"
}

"DTF2_Taunt.Demo02EquipmentJingle"
{
	"channel"	"CHAN_STATIC"
	"volume"	".45"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_equipment_jingle.wav"
}

"DTF2_Taunt.Demo02EquipmentJingle2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".45"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_equipment_jingle2.wav"
}

"DTF2_Taunt.Demo02EquipmentJingle3"
{
	"channel"	"CHAN_STATIC"
	"volume"	".45"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_equipment_jingle3.wav"
}

"DTF2_Taunt.Demo02EquipmentJingle4"
{
	"channel"	"CHAN_STATIC"
	"volume"	".45"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_equipment_jingle4.wav"
}

"DTF2_Taunt.Demo03BottleCatch"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_hand_clap.wav"
}

"DTF2_Taunt.Demo03BottleSlosh"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_bottle_slosh.wav"
}

"DTF2_Taunt.Demo03BottleAh"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_bottle_ah.wav"
}

"DTF2_Selection.DemoEquipment1"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_equipment_gun2.wav"
}

"DTF2_Selection.DemoEquipment2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_equipment_gun1.wav"
}

"DTF2_Selection.DemoClipSpin"
{
	"channel"	"CHAN_BODY"
	"volume"	".5"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_clip_spin.wav"
}

"DTF2_Selection.DemoClipSpinLong"
{
	"channel"	"CHAN_BODY"
	"volume"	".5"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_clip_spin_long.wav"
}

"DTF2_Taunt.DemoShakeIt"
{
	"channel"	"CHAN_BODY"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_NORM"
	"wave"		"player/taunt_shake_it.wav"
}

"DTF2_Taunt.Demo_Burp"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_85dB"
	"wave"		")player/taunt_burp.wav"
}

"DTF2_Taunt.MedicGloveStretch"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	"player/taunt_rubberglove_stretch.wav"
}

"DTF2_Taunt.MedicHardClap1"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	")player/taunt_hard_clap1.wav"
}

"DTF2_Taunt.MedicHardClap2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	")player/taunt_hard_clap2.wav"
}

"DTF2_Taunt.MedicHardClap3"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	")player/taunt_hard_clap3.wav"
}

"DTF2_Taunt.MedicHardClap4"
{
	"channel"	"CHAN_STATIC"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	")player/taunt_hard_clap1.wav"
}

"DTF2_Taunt.MedicHardClap5"
{
	"channel"	"CHAN_STATIC"
	"volume"	".15"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	")player/taunt_hard_clap2.wav"
}

"DTF2_Taunt.MedicHardClap6"
{
	"channel"	"CHAN_STATIC"
	"volume"	".05"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	")player/taunt_hard_clap3.wav"
}

"DTF2_Taunt.MedicGloveSnap"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	"player/taunt_rubberglove_snap.wav"
}

"DTF2_Taunt.MedicViolin"
{
	"channel"	"CHAN_STATIC"
	"volume"	".35"
	"soundlevel"  	"SNDLVL_75dB"

	"rndwave"
	{	
		"wave"	"player/taunt_v01.wav"
		"wave"	"player/taunt_v02.wav"
		"wave"	"player/taunt_v03.wav"
		"wave"	"player/taunt_v04.wav"
		"wave"	"player/taunt_v05.wav"
		"wave"	"player/taunt_v06.wav"
		"wave"	"player/taunt_v07.wav"
	}
}
"DTF2_Taunt.MedicViolinUber"
{
	"channel"	"CHAN_STATIC"
	"volume"	".35"
	"soundlevel"  	"SNDLVL_75dB"

	"rndwave"
	{	
		"wave"	"player/uberTaunt_v01.wav"
		"wave"	"player/uberTaunt_v02.wav"
		"wave"	"player/uberTaunt_v03.wav"
		"wave"	"player/uberTaunt_v04.wav"
		"wave"	"player/uberTaunt_v05.wav"
		"wave"	"player/uberTaunt_v06.wav"
		"wave"	"player/uberTaunt_v07.wav"
	}
}

"DTF2_Taunt.MedicHeroic"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  "SNDLVL_95dB"

	"wave"		")player/taunt_medic_heroic.wav"
}

"DTF2_Taunt.GuitarRiff"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  "SNDLVL_95dB"

	"wave"		")player\brutal_legend_taunt.wav"
}

"DTF2_Taunt.WormsHHG"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"

	"rndwave"
	{	
		"wave"	"player/taunt_wormsHHG.wav"
	}
}

"DTF2_Selection.MedicHeelClick"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"

	"wave"	"player/taunt_heel_click.wav"
}

"DTF2_Selection.MedicFootStomp"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"

	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Selection.MedicFootSlide"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"

	"wave"	"player/taunt_foot_spin.wav"
}

"DTF2_Taunt.Scout01Run"
{
	"channel"	"CHAN_STATIC"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Scout01HandSmack"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"

		"wave"	"player/taunt_hand_clap.wav"
}

"DTF2_Taunt.Scout02Run"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Scout03Run"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Selection.ScoutShotgunShoulder"
{
	"channel"	"CHAN_BODY"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_shotgun_shoulder.wav"
}

"DTF2_Selection.ScoutShotgunTwirl"
{
	"channel"	"CHAN_BODY"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"		"player/taunt_shotgun_twirl.wav"
}

"DTF2_Taunt.Sniper02HealClick"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Sniper02FootStomp"
{
	"channel"	"CHAN_STATIC"
	"volume"	".50"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Sniper02FootSlide"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_spin.wav"
}

"DTF2_Taunt.Sniper03MacheteUnsheath"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_machete_draw.wav"
}

"DTF2_Taunt.Sniper03MacheteCatch"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_machete_catch.wav"
}

"DTF2_Selection.SniperHatTip"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_clothes_swipe.wav"
}

"DTF2_Taunt.Spy01TieFix"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_tie_fix.wav"
}

"DTF2_Taunt.Spy03FootStomp"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Spy03KnifeCatch"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_grenade_catch.wav"
}

"DTF2_Taunt.Spy04CigFlick"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_cig_flick.wav"
}

"DTF2_Taunt.SpyCigCaseClose"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_cig_case_close.wav"
}

"DTF2_Selection.SpyClothesRustle1"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_clothes_swipe.wav"
}

"DTF2_Selection.SpyClothesRustle2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_clothes_swipe2.wav"
}

"DTF2_Taunt.SoldierClothesRustle"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NORM"
	"wave"	"player/taunt_clothes_swipe2.wav"
}

"DTF2_Selection.SpyPuff"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_puff.wav"
}

"DTF2_Selection.SpyPuffAh"
{
	"channel"	"CHAN_BODY"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_puff_ah.wav"
}

"DTF2_Taunt.Soldier01HeelClick"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Soldier01ClothesSwipe"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_swipe.wav"
}

"DTF2_Taunt.Soldier01ClothesRustle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Taunt.Soldier01HelmetJostle"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_jingle3.wav"
}

"DTF2_Taunt.SoldierKnuckleCrack"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.25"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"player/taunt_knuckle_crack.wav"
}

"DTF2_Taunt.TauntChestThumpYell"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"vo/soldier_DirectHitTaunt02.mp3"
}

"DTF2_Taunt.SoldierChestThump"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.25"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"player/taunt_chest_thump.wav"
}

"DTF2_Taunt.SoldierChestThumpAlt"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.25"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"player/taunt_chest_thump_alt.wav"
}

"DTF2_Taunt.SoldierChestThumpLow"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.1"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"player/taunt_chest_thump.wav"
}


"DTF2_Taunt.SoldierGrenadePull"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"player/taunt_equipment_jingle3.wav"
}

"DTF2_Taunt.SoldierShotgunFire"
{
	"channel"	"CHAN_ITEM"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"weapons/shotgun_shoot.wav"
}

"DTF2_Taunt.SoldierShotgunCockBack"
{
	"channel"	"CHAN_WEAPON"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"weapons/shotgun_cock_back.wav"
}

"DTF2_Taunt.SoldierShotgunCockForward"
{
	"channel"	"CHAN_WEAPON"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"weapons/shotgun_cock_forward.wav"
}

"DTF2_Taunt.SoldierSaluteSwish"
{
	"channel"	"CHAN_BODY"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NORM"		
	"wave"	"player/taunt_clothes_swipe2.wav"
}

"DTF2_Taunt.SoldierTaps"
{
            "channel"          "CHAN_STATIC"
            "volume"           "1.0"
            "soundlevel"      "SNDLVL_NORM"
             "wave"              ")misc/taps_02.wav"
}

"DTF2_Taunt.Soldier02GrenadeCatch"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_grenade_catch.wav"
}

"DTF2_Taunt.Soldier02ClothesRustle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Taunt.Soldier02ShovelCatch"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_hand_clap.wav"
}

"DTF2_Taunt.Soldier03FootStomp"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Soldier03HelmetHit"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_helmet_hit.wav"
}

"DTF2_Taunt.Soldier03ClothesSwipe"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_swipe.wav"
}

"DTF2_Taunt.Soldier03ClothesRustle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Taunt.Soldier03HelmetJostle"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_jingle3.wav"
}

"DTF2_Selection.SoldierLauncherGrab"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_grenade_catch.wav"
}

"DTF2_Selection.SoldierClothesRustle"
{
	"channel"	"CHAN_ITEM"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Selection.SoldierEquipment"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_equipment_jingle3.wav"
}

"DTF2_Selection.SoldierLauncherSetStart"
{
	"channel"	"CHAN_STATIC"
	"volume"	".55"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_equipment_gun2.wav"
}

"DTF2_Selection.SoldierLauncherHitGround"
{
	"channel"	"CHAN_BODY"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_launcher_hit.wav"
}

"DTF2_Selection.SoldierLauncherSetStop"
{
	"channel"	"CHAN_STATIC"
	"volume"	".55"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_equipment_gun1.wav"
}

"DTF2_Taunt.HeavyUpperCut"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_heavy_upper_cut.wav"
}

"DTF2_Taunt.HeavyBell"
{
	"channel"	"CHAN_ITEM"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_bell.wav"
}

"DTF2_Taunt.Heavy01HoldGun"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_grenade_catch.wav"
}

"DTF2_Taunt.Heavy01HoldGunLight"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_hand_clap2.wav"
}

"DTF2_Taunt.Heavy01ClothesRustle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Taunt.Heavy01EquipmentGun"
{
	"channel"	"CHAN_ITEM"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_gun1.wav"
}

"DTF2_Taunt.Heavy01EquipmentGun2"
{
	"channel"	"CHAN_ITEM"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_gun2.wav"
}

"DTF2_Taunt.Heavy01EquipmentRustleHeavy"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_jingle2.wav"
}

"DTF2_Taunt.Heavy02ShotgunSpin"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_shotgun_spin.wav"
}


"DTF2_Taunt.Heavy02ShotgunGrab"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_hand_clap.wav"
}

"DTF2_Taunt.Heavy02EquipmentJingle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_jingle3.wav"
}

"DTF2_Taunt.Heavy03ClothesRustle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Taunt.Heavy03ClothesSwipe"
{
	"channel"	"CHAN_ITEM"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_clothes_swipe.wav"
}

"DTF2_Taunt.Heavy03EquipmentJingle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_jingle3.wav"
}

"DTF2_Taunt.Heavy03EquipmentJingleShort"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_equipment_jingle3short.wav"
}

"DTF2_Selection.HeavyFootStomp"
{
	"channel"	"CHAN_ITEM"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Selection.HeavyEquipment1"
{
	"channel"	"CHAN_BODY"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_equipment_gun2.wav"
}

"DTF2_Selection.HeavyEquipment2"
{
	"channel"	"CHAN_BODY"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_equipment_gun1.wav"
}

"DTF2_Selection.HeavyClothesRustle"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Taunt.Pyro01FootStomp"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_foot_stomp.wav"
}

"DTF2_Taunt.Pyro01Equipment1"
{
	"channel"	"CHAN_STATIC"
	"volume"	".20"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_equipment_gun2.wav"
}

"DTF2_Taunt.Pyro01Equipment2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".35"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"		"player/taunt_equipment_gun1.wav"
}

"DTF2_Taunt.Pyro02Fire"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_fire.wav"
}

"DTF2_Taunt.Pyro03RockStar"
{
	"channel"	"CHAN_VOICE"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_rockstar.wav"
}

"DTF2_Taunt.Pyro03RockStarEnd"
{
	"channel"	"CHAN_VOICE"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_rockstar_end.wav"
}

"DTF2_Selection.PyroClothesRustle"
{
	"channel"	"CHAN_BODY"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_clothes_rustle.wav"
}

"DTF2_Selection.PyroEquipment1"
{
	"channel"	"CHAN_ITEM"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_equipment_jingle3.wav"
}

"DTF2_Selection.PyroEquipment2"
{
	"channel"	"CHAN_ITEM"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_equipment_jingle2.wav"
}


"DTF2_Selection.PyroFootStomp"
{
	"channel"	"CHAN_ITEM"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"	"player/taunt_foot_stomp.wav"
}
"DTF2_Taunt.PyroBalloonicorn"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_pyro_balloonicorn.wav"

}
"DTF2_Taunt.PyroHellicorn"
{
	"channel"	"CHAN_STATIC"
	"volume"	".75"
	"soundlevel"  	"SNDLVL_75dB"		
	"wave"	"player/taunt_pyro_hellicorn.wav"
}



"DTF2_Taunt.SpringRiderSit"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_85dB"		
	"wave"	")player/taunt_springrider_sit.wav"
}

"DTF2_Taunt.Taunt.SpringRiderSqueak1"
{
	"channel"	"CHAN_STATIC"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_85dB"		
	"wave"	")player/taunt_springrider_squeak1.wav"
}

"DTF2_Taunt.Taunt.SpringRiderSqueak2"
{
	"channel"	"CHAN_STATIC"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_85dB"		
	"wave"	")player/taunt_springrider_squeak2.wav"
}

"DTF2_Taunt.Taunt.SpringRiderSqueak3"
{
	"channel"	"CHAN_STATIC"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_85dB"		
	"wave"	")player/taunt_springrider_squeak3.wav"
}

"DTF2_Taunt.Taunt.SpringRiderSqueak4"
{
	"channel"	"CHAN_STATIC"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_85dB"		
	"wave"	")player/taunt_springrider_squeak4.wav"
}

"DTF2_Taunt.Taunt.SpringRiderSqueak5"
{
	"channel"	"CHAN_STATIC"
	"volume"	".25"
	"soundlevel"  	"SNDLVL_85dB"		
	"wave"	")player/taunt_springrider_squeak5.wav"
}

"DTF2_Taunt.Taunt.SpringRiderGetUp"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"  	"SNDLVL_85dB"		
	"wave"	")player/taunt_springrider_getup.wav"
}

//-----------------------------------------------------------------------------
//End Taunts
//-----------------------------------------------------------------------------

"DTF2_Medic.AutoCallerAnnounce"
{
	"channel"	"CHAN_VOICE"
	"volume"	"1.0"
	"soundlevel"	"SNDLVL_86dBM"
	"wave"		")ui/medic_alert.wav"
}

"DTF2_Halloween.CrazyLaugh"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"items/halloween/crazy01.wav"
		"wave"		"items/halloween/crazy02.wav"
		"wave"		"items/halloween/crazy03.wav"
	}
}
"DTF2_Halloween.BlackCat"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"items/halloween/cat01.wav"
		"wave"		"items/halloween/cat02.wav"
		"wave"		"items/halloween/cat03.wav"
	}
}
"DTF2_Halloween.Gremlin"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"items/halloween/gremlin01.wav"
		"wave"		"items/halloween/gremlin02.wav"
		"wave"		"items/halloween/gremlin03.wav"
	}
}
"DTF2_Halloween.Werewolf"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"items/halloween/werewolf01.wav"
		"wave"		"items/halloween/werewolf02.wav"
		"wave"		"items/halloween/werewolf03.wav"
	}
}
"DTF2_Halloween.Banshee"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_95dB"
	"rndwave"
	{
		"wave"		"items/halloween/banshee01.wav"
		"wave"		"items/halloween/banshee02.wav"
		"wave"		"items/halloween/banshee03.wav"
	}
}
"DTF2_Halloween.SFX"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"items/halloween/spooky01.wav"
		"wave"		"items/halloween/spooky02.wav"
		"wave"		"items/halloween/spooky03.wav"
	}
}
"DTF2_Halloween.Stabby"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_90dB"
	"wave"		"items/halloween/stabby.wav"
}
"DTF2_Halloween.Witch"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"items/halloween/witch01.wav"
		"wave"		"items/halloween/witch02.wav"
		"wave"		"items/halloween/witch03.wav"
	}
}

"DTF2_Player.YouAreIt"
{
	"channel"		"CHAN_STATIC"
	"volume"		"VOL_NORM"
	"soundlevel"	"SNDLVL_NONE"
	"pitch"			"PITCH_NORM"
	"wave"			"ui/halloween_boss_chosen_it.wav"
}

"DTF2_Player.TaggedOtherIT"
{
	"channel"		"CHAN_STATIC"
	"volume"		"VOL_NORM"
	"soundlevel"	"SNDLVL_NONE"
	"pitch"			"PITCH_NORM"
	"wave"			"ui/halloween_boss_tagged_other_it.wav"
}

"DTF2_Player.IsNowIT"
{
	"channel"		"CHAN_STATIC"
	"volume"		"VOL_NORM"
	"soundlevel"	"SNDLVL_95dB"
	"pitch"			"PITCH_NORM"
	"wave"			"ui/halloween_boss_player_becomes_it.wav"
}

"DTF2_Samurai.Exaltation"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"pitch"		"90, 110"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		")items\samurai\TF_samurai_noisemaker_setA_01.wav"
		"wave"		")items\samurai\TF_samurai_noisemaker_setA_02.wav"
		"wave"		")items\samurai\TF_samurai_noisemaker_setA_03.wav"
	}
}

"DTF2_Samurai.Koto"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		")items\samurai\TF_samurai_noisemaker_setB_01.wav"
		"wave"		")items\samurai\TF_samurai_noisemaker_setB_02.wav"
		"wave"		")items\samurai\TF_samurai_noisemaker_setB_03.wav"
	}
}

"DTF2_Samurai.Conch"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_140dB"
	"wave"			")items\samurai\TF_conch.wav"
}

"DTF2_Fundraiser.Bell"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		")items\japan_fundraiser\TF_zen_bell_01.wav"
		"wave"		")items\japan_fundraiser\TF_zen_bell_02.wav"
		"wave"		")items\japan_fundraiser\TF_zen_bell_03.wav"
		"wave"		")items\japan_fundraiser\TF_zen_bell_04.wav"
		"wave"		")items\japan_fundraiser\TF_zen_bell_05.wav"
	}
}

"DTF2_Fundraiser.Tingsha"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_95dB"
	"rndwave"
	{
		"wave"		")items\japan_fundraiser\TF_zen_tingsha_01.wav"
		"wave"		")items\japan_fundraiser\TF_zen_tingsha_01.wav"
		"wave"		")items\japan_fundraiser\TF_zen_tingsha_01.wav"
		"wave"		")items\japan_fundraiser\TF_zen_tingsha_01.wav"
		"wave"		")items\japan_fundraiser\TF_zen_tingsha_01.wav"
		"wave"		")items\japan_fundraiser\TF_zen_tingsha_01.wav"
	}
}

"DTF2_Fundraiser.PrayerBowl"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_130dB"
	"rndwave"
	{
		"wave"		")items\japan_fundraiser\TF_zen_prayer_bowl_01.wav"
		"wave"		")items\japan_fundraiser\TF_zen_prayer_bowl_02.wav"
		"wave"		")items\japan_fundraiser\TF_zen_prayer_bowl_03.wav"
	}
}

"DTF2_Summer.Fireworks"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_100dB"
	"rndwave"
	{
		"wave"		")items/summer/summer_fireworks1.wav"
		"wave"		")items/summer/summer_fireworks2.wav"
		"wave"		")items/summer/summer_fireworks3.wav"
		"wave"		")items/summer/summer_fireworks4.wav"
	}
}

"DTF2_TFPlayer.HighFive"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_100dB"
	"wave"			")misc\high_five.wav"
}

"DTF2_soccer.vuvezela"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		")items\football_manager\vuvezela_01.wav"
		"wave"		")items\football_manager\vuvezela_02.wav"
		"wave"		")items\football_manager\vuvezela_03.wav"
		"wave"		")items\football_manager\vuvezela_04.wav"
		"wave"		")items\football_manager\vuvezela_05.wav"
		"wave"		")items\football_manager\vuvezela_06.wav"
		"wave"		")items\football_manager\vuvezela_07.wav"
		"wave"		")items\football_manager\vuvezela_08.wav"
		"wave"		")items\football_manager\vuvezela_09.wav"
		"wave"		")items\football_manager\vuvezela_10.wav"
		"wave"		")items\football_manager\vuvezela_11.wav"
		"wave"		")items\football_manager\vuvezela_12.wav"
		"wave"		")items\football_manager\vuvezela_13.wav"
		"wave"		")items\football_manager\vuvezela_14.wav"
		"wave"		")items\football_manager\vuvezela_15.wav"
		"wave"		")items\football_manager\vuvezela_16.wav"
		"wave"		")items\football_manager\vuvezela_17.wav"
	}
}

"DTF2_halloween.wolf_01"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"wave"		")misc\wolf_howl_01.wav"
}

"DTF2_halloween.wolf_02"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"wave"		")misc\wolf_howl_02.wav"
}

"DTF2_halloween.wolf_03"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"wave"		")misc\wolf_howl_03.wav"
}

"DTF2_xmas.jingle"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_01.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_02.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_03.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_04.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_05.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_06.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_07.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_08.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_09.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_10.wav"
	}
}

"DTF2_xmas.jingle_higher"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"pitch"	"115"
	"rndwave"
	{
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_11.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_12.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_13.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_14.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_15.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_16.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_17.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_18.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_19.wav"
		"wave"		")player\sleigh_bells\tf_xmas_sleigh_bells_20.wav"
	}
}

"DTF2_pyro.guitar_shred_01"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"wave"		"items\pyro_guitar_solo_no_verb.wav"
}

"DTF2_pyro.guitar_shred_02"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"wave"		")items\pyro_guitar_solo_with_verb.wav"
}

"DTF2_xmas.jingle_noisemaker"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"pitch"		"100,105"
	"rndwave"
	{
		"wave"		"misc\jingle_bells\jingle_bells_nm_01.wav"
		"wave"		"misc\jingle_bells\jingle_bells_nm_02.wav"
		"wave"		"misc\jingle_bells\jingle_bells_nm_03.wav"
		"wave"		"misc\jingle_bells\jingle_bells_nm_04.wav"
		"wave"		"misc\jingle_bells\jingle_bells_nm_05.wav"
	}
}

"DTF2_scout.boombox"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"rndwave"
	{
		"wave"		"items\scout_boombox_02.wav"
		"wave"		"items\scout_boombox_03.wav"
		"wave"		"items\scout_boombox_04.wav"
		"wave"		"items\scout_boombox_05.wav"
	}
}

"DTF2_BlastJump.Whistle"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_85dB"
	"volume"		"0.25"
	"wave"			"misc/grenade_jump_lp_01.wav"
}

// ------------------------------------------------------------------------------------ //
// Ready Sounds
// ------------------------------------------------------------------------------------ //
"DTF2_Demoman.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/demoman_Go01.mp3"
		"wave"	"vo/demoman_Go02.mp3"
		"wave"	"vo/demoman_Go03.mp3"
	}
}

"DTF2_Engineer.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/engineer_mvm_ask_ready01.mp3"
		"wave"	"vo/engineer_mvm_ask_ready02.mp3"
		"wave"	"vo/engineer_mvm_say_ready01.mp3"
		"wave"	"vo/engineer_mvm_say_ready02.mp3"
	}
}

"DTF2_Heavy.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/heavy_mvm_ask_ready01.mp3"
		"wave"	"vo/heavy_mvm_ask_ready02.mp3"
		"wave"	"vo/heavy_mvm_ask_ready03.mp3"
		"wave"	"vo/heavy_mvm_ask_ready04.mp3"
		"wave"	"vo/heavy_mvm_say_ready01.mp3"
		"wave"	"vo/heavy_mvm_say_ready02.mp3"
		"wave"	"vo/heavy_mvm_say_ready04.mp3"
	}
}

"DTF2_Medic.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/medic_mvm_ask_ready01.mp3"
		"wave"	"vo/medic_mvm_say_ready01.mp3"
		"wave"	"vo/medic_mvm_say_ready02.mp3"
	}
}

"DTF2_Pyro.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"wave"			"vo/pyro_Go01.mp3"
}

"DTF2_Scout.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/scout_Go01.mp3"
		"wave"	"vo/scout_Go02.mp3"
		"wave"	"vo/scout_Go03.mp3"
	}
}

"DTF2_Sniper.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/sniper_Go01.mp3"
		"wave"	"vo/sniper_Go02.mp3"
		"wave"	"vo/sniper_Go03.mp3"
	}
}

"DTF2_Soldier.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/soldier_mvm_ask_ready01.mp3"
		"wave"	"vo/soldier_mvm_ask_ready02.mp3"
		"wave"	"vo/soldier_mvm_ask_ready03.mp3"
		"wave"	"vo/soldier_mvm_say_ready01.mp3"
		"wave"	"vo/soldier_mvm_say_ready02.mp3"
	}
}

"DTF2_Spy.Ready"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/spy_Go01.mp3"
		"wave"	"vo/spy_Go02.mp3"
		"wave"	"vo/spy_Go03.mp3"
	}
}

// ------------------------------------------------------------------------------------ //
// MvM Ready Sounds
// ------------------------------------------------------------------------------------ //
"DTF2_Demoman.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/demoman_Go01.mp3"
		"wave"	"vo/demoman_Go02.mp3"
		"wave"	"vo/demoman_Go03.mp3"
	}
}

"DTF2_Engineer.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/engineer_mvm_ask_ready01.mp3"
		"wave"	"vo/engineer_mvm_ask_ready02.mp3"
		"wave"	"vo/engineer_mvm_say_ready01.mp3"
		"wave"	"vo/engineer_mvm_say_ready02.mp3"
	}
}

"DTF2_Heavy.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/heavy_mvm_ask_ready01.mp3"
		"wave"	"vo/heavy_mvm_ask_ready02.mp3"
		"wave"	"vo/heavy_mvm_ask_ready03.mp3"
		"wave"	"vo/heavy_mvm_ask_ready04.mp3"
		"wave"	"vo/heavy_mvm_say_ready01.mp3"
		"wave"	"vo/heavy_mvm_say_ready02.mp3"
		"wave"	"vo/heavy_mvm_say_ready03.mp3"
		"wave"	"vo/heavy_mvm_say_ready04.mp3"
		"wave"	"vo/heavy_mvm_say_ready05.mp3"
	}
}

"DTF2_Medic.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/medic_mvm_ask_ready01.mp3"
		"wave"	"vo/medic_mvm_say_ready01.mp3"
		"wave"	"vo/medic_mvm_say_ready02.mp3"
	}
}

"DTF2_Pyro.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"wave"			"vo/pyro_Go01.mp3"
}

"DTF2_Scout.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/scout_Go01.mp3"
		"wave"	"vo/scout_Go02.mp3"
		"wave"	"vo/scout_Go03.mp3"
	}
}

"DTF2_Sniper.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/sniper_Go01.mp3"
		"wave"	"vo/sniper_Go02.mp3"
		"wave"	"vo/sniper_Go03.mp3"
	}
}

"DTF2_Soldier.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/soldier_mvm_ask_ready01.mp3"
		"wave"	"vo/soldier_mvm_ask_ready02.mp3"
		"wave"	"vo/soldier_mvm_ask_ready03.mp3"
		"wave"	"vo/soldier_mvm_say_ready01.mp3"
		"wave"	"vo/soldier_mvm_say_ready02.mp3"
	}
}

"DTF2_Spy.ReadyMvM"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/spy_Go01.mp3"
		"wave"	"vo/spy_Go02.mp3"
		"wave"	"vo/spy_Go03.mp3"
	}
}

// ------------------------------------------------------------------------------------ //
// Comp Ready Sounds
// ------------------------------------------------------------------------------------ //
"DTF2_Demoman.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/demoman_Go01.mp3"
		"wave"	"vo/demoman_Go02.mp3"
		"wave"	"vo/demoman_Go03.mp3"
	}
}

"DTF2_Engineer.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/engineer_mvm_ask_ready01.mp3"
		"wave"	"vo/engineer_mvm_ask_ready02.mp3"
		"wave"	"vo/engineer_mvm_say_ready01.mp3"
		"wave"	"vo/engineer_mvm_say_ready02.mp3"
	}
}

"DTF2_Heavy.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/heavy_mvm_ask_ready01.mp3"
		"wave"	"vo/heavy_mvm_ask_ready02.mp3"
		"wave"	"vo/heavy_mvm_ask_ready03.mp3"
		"wave"	"vo/heavy_mvm_ask_ready04.mp3"
		"wave"	"vo/heavy_mvm_say_ready01.mp3"
		"wave"	"vo/heavy_mvm_say_ready02.mp3"
		"wave"	"vo/heavy_mvm_say_ready04.mp3"
	}
}

"DTF2_Medic.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/medic_mvm_ask_ready01.mp3"
		"wave"	"vo/medic_mvm_say_ready01.mp3"
		"wave"	"vo/medic_mvm_say_ready02.mp3"
	}
}

"DTF2_Pyro.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"wave"			"vo/pyro_Go01.mp3"
}

"DTF2_Scout.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/scout_Go01.mp3"
		"wave"	"vo/scout_Go02.mp3"
		"wave"	"vo/scout_Go03.mp3"
	}
}

"DTF2_Sniper.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/sniper_Go01.mp3"
		"wave"	"vo/sniper_Go02.mp3"
		"wave"	"vo/sniper_Go03.mp3"
	}
}

"DTF2_Soldier.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/soldier_mvm_ask_ready01.mp3"
		"wave"	"vo/soldier_mvm_ask_ready02.mp3"
		"wave"	"vo/soldier_mvm_ask_ready03.mp3"
		"wave"	"vo/soldier_mvm_say_ready01.mp3"
		"wave"	"vo/soldier_mvm_say_ready02.mp3"
	}
}

"DTF2_Spy.ReadyComp"
{
	"channel"	"CHAN_VOICE"
	"volume"	"VOL_NORM"
	"pitch"		"PITCH_NORM"
	"soundlevel"	"SNDLVL_95dB"

	"rndwave"
	{
		"wave"	"vo/spy_Go01.mp3"
		"wave"	"vo/spy_Go02.mp3"
		"wave"	"vo/spy_Go03.mp3"
	}
}

// ------------------------------------------------------------------------------------ //
// 
// ------------------------------------------------------------------------------------ //

"DTF2_pyro.music_backpack"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1"
	"soundlevel"	"SNDLVL_85dB"
	"wave"		")items/pyro_music_tube.wav"
}

"DTF2_Taunt.PyroAnnihilator"
{
	"channel"	"CHAN_STATIC"
	"volume"	".35"
	"soundlevel"  	"SNDLVL_75dB"
	"wave"	"player/sign_bass_solo.wav"
}

// ------------------------------------------------------------------------------------ //
// Halloween 2012
// ------------------------------------------------------------------------------------ //

"DTF2_Player.bomb_attach"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"
	"wave"			"misc/halloween/hwn_bomb_attach.wav"
}

"DTF2_Player.bomb_fuse"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.5"
	"pitch"			"PITCH_NORM"
	"wave"			"misc/halloween/hwn_bomb_fuse.wav"
}

"DTF2_Player.bomb_flash"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.2"
	"pitch"			"PITCH_NORM"
	"wave"			"misc/halloween/hwn_bomb_flash.wav"
}

// ------------------------------------------------------------------------------------ //
// SFX for new taunt update 2014
// ------------------------------------------------------------------------------------ //

"DTF2_Player.taunt_flipFX"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"PITCH_NORM"
	"wave"			"player/taunt_sfx_flip_01.wav"
}

"DTF2_taunt.single_bell"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"PITCH_NORM"
	"wave"			"player/taunt_sfx_bell_single.wav"
}

"DTF2_taunt.dbl_bell"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"PITCH_NORM"
	"wave"			"player/taunt_bell.wav"
}

"DTF2_taunt.hawk"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"PITCH_NORM"
	"wave"			"player/sniper_taunt_hawk.wav"
}


"DTF2_taunt.broomfly"
{
	"channel"		"CHAN_BODY"
	"volume"		".5"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			"player/taunt_broom_fly.wav"
}

"DTF2_taunt.broomflyfade"
{
	"channel"		"CHAN_BODY"
	"volume"		".5"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			"player/taunt_broom_fly_fade.wav"
}

"DTF2_taunt.disco"
{
	"channel"		"CHAN_BODY"
	"volume"		".5"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			"player/taunt_disco.wav"
}

"DTF2_Taunt.BumperCarSpawn"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_74dB"
	"volume"	".5"
	"wave"		")player/taunt_bumper_car_spawn.wav"
}

"DTF2_Taunt.BumperCarGoLoop"
{
	"channel"	"CHAN_BODY"
	"soundlevel"	"SNDLVL_74dB"
	"volume"	".5"
	"wave"		")player/taunt_bumper_car_go_loop.wav"
}

"DTF2_Taunt.BumperCarHorn"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_74dB"
	"volume"	".5"
	"wave"		")player/taunt_bumper_car_horn.wav"
}

"DTF2_Taunt.BumperCarQuit"
{
	"channel"	"CHAN_BODY"
	"soundlevel"	"SNDLVL_74dB"
	"volume"	".5"
	"wave"		")player/taunt_bumper_car_quit.wav"
}

"DTF2_Taunt.secondrate_sorcery_spell_fail"
{
	"channel"		"CHAN_STATIC"
	"volume"		".5"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			")player/taunt_sorcery_fail.wav"
}

"DTF2_Taunt.secondrate_sorcery_spell_staff_drop"
{
	"channel"		"CHAN_STATIC"
	"volume"		".5"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			")player/taunt_sorcery_staff_drop.wav"
}

"DTF2_Taunt.secondrate_sorcery_spell_fail_staff_break"
{
	"channel"		"CHAN_STATIC"
	"volume"		".5"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			")player/taunt_sorcery_staff_break.wav"
}


"DTF2_Taunt.TableFlipBubblyPotWater"
{
	"channel"		"CHAN_BODY"
	"volume"		".75"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			")player/taunt_table_flip_bubbly_pot_water.wav"
}

"DTF2_Taunt.TableFlipNotification"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			")player/taunt_table_flip_notification.wav"
}

"DTF2_Taunt.TableFlipFlippingTable"
{
	"channel"		"CHAN_BODY"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_NORM"

	"wave"			")player/taunt_table_flip_flipping_table.wav"
}

"DTF2_Taunt.DidgeridooStart"
{
	"channel"		"CHAN_BODY"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_68dB"

	"wave"			")player/taunt_didgeridoo_start.wav"
}

"DTF2_Taunt.DidgeridooStop"
{
	"channel"		"CHAN_BODY"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_68dB"

	"wave"			")player/taunt_didgeridoo_stop.wav"
}

"DTF2_Taunt.DidgeridooSitDown"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_68dB"

	"wave"			")player/taunt_didgeridoo_sit_down.wav"
}

"DTF2_Taunt.DidgeridooStandUp"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_68dB"

	"wave"			")player/taunt_didgeridoo_stand_up.wav"
}

"DTF2_Taunt.DemoStaggerSlosh1"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_74dB"

	"wave"			")player/taunt_demo_stagger_slosh1.wav"
}

"DTF2_Taunt.DemoStaggerSlosh2"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_74dB"

	"wave"			")player/taunt_demo_stagger_slosh2.wav"
}

"DTF2_Taunt.DemoStaggerSlosh3"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_74dB"

	"wave"			")player/taunt_demo_stagger_slosh3.wav"
}

"DTF2_Taunt.DemoStaggerSlosh4"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_74dB"

	"wave"			")player/taunt_demo_stagger_slosh4.wav"
}
]==]
