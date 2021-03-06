return [==[// ------------------------------------------------------------------------------------ //
// Mann vs Machine
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.Siren"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_NONE"

	"wave"			"mvm/ambient_mp3/mvm_siren.mp3"
}

"DTF2_MVM.MoneyPickup"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_90dB"

	"wave"			"mvm/mvm_money_pickup.wav"
}

"DTF2_MVM.MoneyVanish"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_90dB"

	"wave"			")mvm/mvm_money_vanish.wav"
}

"DTF2_MVM.PlayerUpgraded"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.25"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_NORM"

	"wave"			")mvm/mvm_bought_upgrade.wav"
}

"DTF2_MVM.PlayerBoughtIn"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.5"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_90dB"

	"wave"			"mvm/mvm_bought_in.wav"
}

"DTF2_MVM.PlayerUsedPowerup"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.13"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_90dB"

	"wave"			")mvm/mvm_used_powerup.wav"
}

"DTF2_MVM.PlayerDied"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.600"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_NONE"

	"wave"			"*#mvm/mvm_player_died.wav"
}

"DTF2_MVM.PlayerDiedScout"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainCrticialDeath01.mp3"
		"wave"		"vo/scout_PainCrticialDeath02.mp3"
		"wave"		"vo/scout_PainCrticialDeath03.mp3"
	}
}

"DTF2_MVM.PlayerDiedSniper"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/sniper_PainCrticialDeath01.mp3"
		"wave"		"vo/sniper_PainCrticialDeath02.mp3"
		"wave"		"vo/sniper_PainCrticialDeath03.mp3"
		"wave"		"vo/sniper_PainCrticialDeath04.mp3"
	}
}

"DTF2_MVM.PlayerDiedSoldier"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/soldier_PainCrticialDeath01.mp3"
		"wave"		"vo/soldier_PainCrticialDeath02.mp3"
		"wave"		"vo/soldier_PainCrticialDeath03.mp3"
		"wave"		"vo/soldier_PainCrticialDeath04.mp3"
	}
}

"DTF2_MVM.PlayerDiedDemoman"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/demoman_PainCrticialDeath01.mp3"
		"wave"		"vo/demoman_PainCrticialDeath02.mp3"
		"wave"		"vo/demoman_PainCrticialDeath03.mp3"
		"wave"		"vo/demoman_PainCrticialDeath04.mp3"
		"wave"		"vo/demoman_PainCrticialDeath05.mp3"
	}
}

"DTF2_MVM.PlayerDiedMedic"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/medic_PainCrticialDeath01.mp3"
		"wave"		"vo/medic_PainCrticialDeath02.mp3"
		"wave"		"vo/medic_PainCrticialDeath03.mp3"
		"wave"		"vo/medic_PainCrticialDeath04.mp3"
	}
}

"DTF2_MVM.PlayerDiedHeavy"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/heavy_PainCrticialDeath01.mp3"
		"wave"		"vo/heavy_PainCrticialDeath02.mp3"
		"wave"		"vo/heavy_PainCrticialDeath03.mp3"
	}
}

"DTF2_MVM.PlayerDiedPyro"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/pyro_PainCrticialDeath01.mp3"
		"wave"		"vo/pyro_PainCrticialDeath02.mp3"
		"wave"		"vo/pyro_PainCrticialDeath03.mp3"
	}
}

"DTF2_MVM.PlayerDiedSpy"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/Spy_PainCrticialDeath01.mp3"
		"wave"		"vo/Spy_PainCrticialDeath02.mp3"
		"wave"		"vo/Spy_PainCrticialDeath03.mp3"
	}
}

"DTF2_MVM.PlayerDiedEngineer"
{
	"channel"		"CHAN_VOICE"
	"volume"		"1.000"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_120dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainCrticialDeath01.mp3"
		"wave"		"vo/engineer_PainCrticialDeath02.mp3"
		"wave"		"vo/engineer_PainCrticialDeath03.mp3"
		"wave"		"vo/engineer_PainCrticialDeath04.mp3"
		"wave"		"vo/engineer_PainCrticialDeath05.mp3"
		"wave"		"vo/engineer_PainCrticialDeath06.mp3"
	}
}

"DTF2_MVM.Mothership"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.0"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_85dB"

	"wave"			"misc/null.wav"
}

// Baseball bat replacement
"DTF2_Weapon_BaseballBat.HitFlesh"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"	"1.0"
	"rndwave"
	{
		"wave"		"weapons/cbar_hitbod1.wav"
		"wave"		"weapons/cbar_hitbod2.wav"
		"wave"		"weapons/cbar_hitbod3.wav"
	}
}

"DTF2_Weapon_Bat.HitFlesh"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"	"1.0"
	"rndwave"
	{
		"wave"		"weapons/cbar_hitbod1.wav"
		"wave"		"weapons/cbar_hitbod2.wav"
		"wave"		"weapons/cbar_hitbod3.wav"
	}
}


// ------------------------------------------------------------------------------------ //
// Tank
// ------------------------------------------------------------------------------------ //

"DTF2_MVM.TankStart"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.6"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"			"*#mvm/mvm_tank_start.wav"
}
"DTF2_MVM.TankEnd"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"			"*#mvm/mvm_tank_end.wav"
}
"DTF2_MVM.TankPing"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_150dB"
	"wave"			")mvm/mvm_tank_horn.wav"
}

"DTF2_MVM.TankEngineLoop"
{
	"channel"	"CHAN_STATIC"
	"volume"	"0.89"
	"pitch"		"100"
	"soundlevel"  "SNDLVL_85dB"
	"wave"		"^mvm/mvm_tank_loop.wav"
}

"DTF2_MVM.TankSmash"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_150dB"
	"wave"			")mvm/mvm_tank_smash.wav"
}

"DTF2_MVM.TankDeploy"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_140dB"
	"wave"			"mvm/mvm_tank_deploy.wav"
}

"DTF2_MVM.TankExplodes"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.85"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"			")mvm/mvm_tank_explode.wav"
}

// ------------------------------------------------------------------------------------ //
// Bomb
// ------------------------------------------------------------------------------------ //

"DTF2_MVM.BombWarning"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_104dB"
	"wave"			")mvm\mvm_bomb_warning.wav"
}

"DTF2_MVM.BombExplodes"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_NONE"
	"wave"			"mvm/mvm_bomb_explode.wav"
}

"DTF2_MVM.Warning"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.500"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_NONE"

	"wave"			"#*mvm/mvm_warning.wav"
}

"DTF2_MVM.BombResetExplode"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_NONE"

	"wave"			"weapons/bombinomicon_explode1.wav"
}

// ------------------------------------------------------------------------------------ //
// For bomb deploy animations based on robot size
// ------------------------------------------------------------------------------------ //

"DTF2_MVM.DeployBombGiant"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_90dB"
	"wave"			"mvm/mvm_deploy_giant.wav"
}

"DTF2_MVM.DeployBombSmall"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_90dB"
	"wave"			"mvm/mvm_deploy_small.wav"
}

// ------------------------------------------------------------------------------------ //
// Sentry Buster
// ------------------------------------------------------------------------------------ //

"DTF2_MVM.SentryBusterExplode"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_130dB"
	"wave"			")mvm/sentrybuster/mvm_sentrybuster_explode.wav"
}

"DTF2_MVM.SentryBusterSpin"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_130dB"
	"wave"			")mvm/sentrybuster/mvm_sentrybuster_spin.wav"
}

"DTF2_MVM.SentryBusterLoop"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.0"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_100dB"
	"wave"			"mvm/sentrybuster/mvm_sentrybuster_loop.wav"
}

"DTF2_MVM.SentryBusterIntro"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.0"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_140dB"
	"wave"			")mvm/sentrybuster/mvm_sentrybuster_intro.wav"
}

"DTF2_MVM.SentryBusterStep"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.0"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_95dB"
	"rndwave"
	{
		"wave"		"^mvm/sentrybuster/mvm_sentrybuster_step_01.wav"
		"wave"		"^mvm/sentrybuster/mvm_sentrybuster_step_02.wav"
		"wave"		"^mvm/sentrybuster/mvm_sentrybuster_step_03.wav"
		"wave"		"^mvm/sentrybuster/mvm_sentrybuster_step_04.wav"
	}
}


// ------------------------------------------------------------------------------------ //
// Giant Heavy
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.GiantHeavyEntrance"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_90dB"
	"wave"			")mvm/giant_heavy/giant_heavy_entrance.wav"
}

"DTF2_MVM.GiantHeavyExplodes"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_125dB"
	"rndwave"
	{
//		"wave"	")mvm/giant_common/giant_common_explodes_01.wav"
//		"wave"	")mvm/giant_common/giant_common_explodes_02.wav"
		"wave"			"mvm/sentrybuster/mvm_sentrybuster_explode.wav"
	}	
}

"DTF2_MVM.GiantHeavyGunWindDown"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"0.9"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_120dB"
	"wave"			")mvm/giant_heavy/giant_heavy_gunwinddown.wav"
}

"DTF2_MVM.GiantHeavyGunWindUp"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"0.9"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_120dB"
	"wave"			")mvm/giant_heavy/giant_heavy_gunwindup.wav"
}

"DTF2_MVM.GiantHeavyGunFire"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.0"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_120dB"
	"wave"			")mvm/giant_heavy/giant_heavy_gunfire.wav"
}

"DTF2_MVM.GiantHeavyGunSpin"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_120dB"
	"wave"			")mvm/giant_heavy/giant_heavy_gunspin.wav"
}

"DTF2_MVM.GiantHeavyLoop"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_83dB"
	"wave"			")mvm/giant_heavy/giant_heavy_loop.wav"
}

"DTF2_MVM.GiantHeavyStep"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_95dB"
	"rndwave"
	{
		"wave"		"^mvm/giant_common/giant_common_step_01.wav"
		"wave"		"^mvm/giant_common/giant_common_step_02.wav"
		"wave"		"^mvm/giant_common/giant_common_step_03.wav"
		"wave"		"^mvm/giant_common/giant_common_step_04.wav"
		"wave"		"^mvm/giant_common/giant_common_step_05.wav"
		"wave"		"^mvm/giant_common/giant_common_step_06.wav"
		"wave"		"^mvm/giant_common/giant_common_step_07.wav"
		"wave"		"^mvm/giant_common/giant_common_step_08.wav"
	}
}

// ------------------------------------------------------------------------------------ //
// Giant Common - explosion common to all non-Heavy giants
// ------------------------------------------------------------------------------------ //

"DTF2_MVM.GiantCommonExplodes"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_125dB"
	"rndwave"
	{
//		"wave"	")mvm/giant_common/giant_common_explodes_01.wav"
//		"wave"	")mvm/giant_common/giant_common_explodes_02.wav"
		"wave"			"mvm/sentrybuster/mvm_sentrybuster_explode.wav"

	}	
}

// ------------------------------------------------------------------------------------ //
// Giant Soldier
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.GiantSoldierLoop"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.0"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_82dB"
	"wave"			"mvm/giant_soldier/giant_soldier_loop.wav"
}

"DTF2_MVM.GiantSoldierStep"
{
	"channel"		"CHAN_STATIC"
	"volume"		".65"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_95dB"
	"rndwave"
	{
		"wave"		"^mvm/giant_common/giant_common_step_01.wav"
		"wave"		"^mvm/giant_common/giant_common_step_02.wav"
		"wave"		"^mvm/giant_common/giant_common_step_03.wav"
		"wave"		"^mvm/giant_common/giant_common_step_04.wav"
		"wave"		"^mvm/giant_common/giant_common_step_05.wav"
		"wave"		"^mvm/giant_common/giant_common_step_06.wav"
		"wave"		"^mvm/giant_common/giant_common_step_07.wav"
		"wave"		"^mvm/giant_common/giant_common_step_08.wav"
	}
}

"DTF2_MVM.GiantSoldierRocketShoot"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"0.65, 0.75"
	"pitch"			"95, 105"
	"soundlevel"  	"SNDLVL_90dB"
	"wave"			"mvm/giant_soldier/giant_soldier_rocket_shoot.wav"
}

"DTF2_MVM.GiantSoldierRocketShootCrit"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"0.75"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_85dB"
	"wave"			"mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav"
}

"DTF2_MVM.GiantSoldierRocketExplode"
{
	"channel"		"CHAN_WEAPON"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_90dB"
	"wave"			"mvm/giant_soldier/giant_soldier_rocket_explode.wav"
}

// ------------------------------------------------------------------------------------ //
// Giant Demoman
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.GiantDemomanLoop"
{
	"channel"		"CHAN_STATIC" 
	"volume"		"0.6"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_82dB"
	"wave"			"mvm/giant_demoman/giant_demoman_loop.wav"
}

"DTF2_MVM.GiantDemomanStep"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_95dB"
	"rndwave"
	{
		"wave"		"^mvm/giant_common/giant_common_step_01.wav"
		"wave"		"^mvm/giant_common/giant_common_step_02.wav"
		"wave"		"^mvm/giant_common/giant_common_step_03.wav"
		"wave"		"^mvm/giant_common/giant_common_step_04.wav"
		"wave"		"^mvm/giant_common/giant_common_step_05.wav"
		"wave"		"^mvm/giant_common/giant_common_step_06.wav"
		"wave"		"^mvm/giant_common/giant_common_step_07.wav"
		"wave"		"^mvm/giant_common/giant_common_step_08.wav"
	}
}

"DTF2_MVM.GiantDemoman_Grenadeshoot"
{
	"channel"	"CHAN_WEAPON"
	"soundlevel"	"SNDLVL_100dB"
	"volume"	"1.0"
	"wave"		"^mvm/giant_demoman/giant_demoman_grenade_shoot.wav"
}

// ------------------------------------------------------------------------------------ //
// Giant Scout
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.GiantScoutLoop"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.3"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_85dB"
	"wave"			"mvm/giant_scout/giant_scout_loop.wav"
}

"DTF2_MVM.GiantScoutStep"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.6"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_87dB"
	"rndwave"
	{
		"wave"		"^mvm/giant_common/giant_common_step_01.wav"
		"wave"		"^mvm/giant_common/giant_common_step_02.wav"
		"wave"		"^mvm/giant_common/giant_common_step_03.wav"
		"wave"		"^mvm/giant_common/giant_common_step_04.wav"
		"wave"		"^mvm/giant_common/giant_common_step_05.wav"
		"wave"		"^mvm/giant_common/giant_common_step_06.wav"
		"wave"		"^mvm/giant_common/giant_common_step_07.wav"
		"wave"		"^mvm/giant_common/giant_common_step_08.wav"
	}
}

// ------------------------------------------------------------------------------------ //
// Giant Pyro
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.GiantPyroLoop"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_83dB"
	"wave"			"mvm/giant_pyro/giant_pyro_loop.wav"
}

"DTF2_MVM.GiantPyroStep"
{
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_95dB"
	"rndwave"
	{
		"wave"		"^mvm/giant_common/giant_common_step_01.wav"
		"wave"		"^mvm/giant_common/giant_common_step_02.wav"
		"wave"		"^mvm/giant_common/giant_common_step_03.wav"
		"wave"		"^mvm/giant_common/giant_common_step_04.wav"
		"wave"		"^mvm/giant_common/giant_common_step_05.wav"
		"wave"		"^mvm/giant_common/giant_common_step_06.wav"
		"wave"		"^mvm/giant_common/giant_common_step_07.wav"
		"wave"		"^mvm/giant_common/giant_common_step_08.wav"
	}
}

"DTF2_MVM.GiantPyro_FlameStart"
{
	"channel"	"CHAN_WEAPON"
	"soundlevel"	"SNDLVL_100dB"
	"volume"	"1.0"
	"wave"		"^mvm/giant_pyro/giant_pyro_flamethrower_start.wav"
}

"DTF2_MVM.GiantPyro_FlameLoop"	
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_100dB"
	"volume"	"1.0"
	"wave"		"^mvm/giant_pyro/giant_pyro_flamethrower_loop.wav"
}


// ------------------------------------------------------------------------------------ //
// regular bots
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.BotStep"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.35"
	"pitch"			"95,100"
	"soundlevel"  	"SNDLVL_87dB"
	"rndwave"
	{
		"wave"		"mvm/player/footsteps/robostep_01.wav"
		"wave"		"mvm/player/footsteps/robostep_02.wav"
		"wave"		"mvm/player/footsteps/robostep_03.wav"
		"wave"		"mvm/player/footsteps/robostep_04.wav"
		"wave"		"mvm/player/footsteps/robostep_05.wav"
		"wave"		"mvm/player/footsteps/robostep_06.wav"
		"wave"		"mvm/player/footsteps/robostep_07.wav"
		"wave"		"mvm/player/footsteps/robostep_08.wav"
		"wave"		"mvm/player/footsteps/robostep_09.wav"
		"wave"		"mvm/player/footsteps/robostep_10.wav"
		"wave"		"mvm/player/footsteps/robostep_11.wav"
		"wave"		"mvm/player/footsteps/robostep_12.wav"
		"wave"		"mvm/player/footsteps/robostep_13.wav"
		"wave"		"mvm/player/footsteps/robostep_14.wav"
		"wave"		"mvm/player/footsteps/robostep_15.wav"
		"wave"		"mvm/player/footsteps/robostep_16.wav"
		"wave"		"mvm/player/footsteps/robostep_17.wav"
		"wave"		"mvm/player/footsteps/robostep_18.wav"
	}
}
// ------------------------------------------------------------------------------------ //
// Fall damage for robots
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.FallDamageBots"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_60dB"
	"rndwave"		
	{
		"wave"		"mvm/mvm_fallpain01.wav"
		"wave"		"mvm/mvm_fallpain02.wav"
	}
}

// ------------------------------------------------------------------------------------ //
// Melee impact replacements Use instead of flesh impact sounds
// ------------------------------------------------------------------------------------ //
"DTF2_MVM_Weapon_Default.HitFlesh"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"	"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
//	"wave"		")weapons/bat_baseball_hit_flesh.wav"

}

"DTF2_MVM_Weapon_FireAxe.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Shovel.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_3rd_degree.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_BaseballBat.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"wave"			"mvm/melee_impacts/bat_baseball_hit_robo01.wav"
}

"DTF2_MVM_Weapon_Knife.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_NORM"
	"rndwave"		
	{
		"wave"		"mvm/melee_impacts/blade_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/blade_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/blade_hit_robo03.wav"
		"wave"		"mvm/melee_impacts/blade_hit_robo04.wav"
	}
}

"DTF2_MVM_Weapon_PickAxe.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"pitch"			"100"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/blade_slice_robo01.wav"
		"wave"		"mvm/melee_impacts/blade_slice_robo02.wav"
		"wave"		"mvm/melee_impacts/blade_slice_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Sword.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"pitch"			"100"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/blade_slice_robo01.wav"
		"wave"		"mvm/melee_impacts/blade_slice_robo02.wav"
		"wave"		"mvm/melee_impacts/blade_slice_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Katana.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"pitch"			"100"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/blade_slice_robo01.wav"
		"wave"		"mvm/melee_impacts/blade_slice_robo02.wav"
		"wave"		"mvm/melee_impacts/blade_slice_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Bottle.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/bottle_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/bottle_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/bottle_hit_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Bottle.IntactHitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/bottle_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/bottle_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/bottle_hit_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Bottle.BrokenHitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/bottle_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/bottle_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/bottle_hit_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Crowbar.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Machete.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Fist.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_BoneSaw.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Club.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Flag.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Medikit.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Pipe.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Wrench.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_Weapon_Bat.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo01.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo02.wav"
		"wave"		"mvm/melee_impacts/cbar_hitbod_robo03.wav"
	}
}

"DTF2_MVM_EvictionNotice.Impact"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo03.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo04.wav"
	}
}

"DTF2_MVM_EvictionNotice.ImpactCrit"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo03.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo04.wav"
	}
}

"DTF2_MVM_BostonBasher.Impact"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"	"1.0"
	"rndwave"
	{
		"wave"		")weapons\eviction_notice_01.wav"
		"wave"		")weapons\eviction_notice_02.wav"
		"wave"		")weapons\eviction_notice_03.wav"
		"wave"		")weapons\eviction_notice_04.wav"
	}
}

"DTF2_MVM_BostonBasher.ImpactCrit"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"	"1.0"
	"rndwave"
	{
		"wave"		")weapons\eviction_notice_01_crit.wav"
		"wave"		")weapons\eviction_notice_02_crit.wav"
		"wave"		")weapons\eviction_notice_03_crit.wav"
		"wave"		")weapons\eviction_notice_04_crit.wav"
	}
}

"DTF2_MVM_Weapon_MetalGloves.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo03.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo04.wav"
	}
}

"DTF2_MVM_Weapon_MetalGloves.CritHit"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo01.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo02.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo03.wav"
		"wave"		"mvm/melee_impacts/metal_gloves_hit_robo04.wav"
	}
}

"DTF2_MVM_Weapon_Assassin_Knife.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts\spyassassinknife_impact_robo01.wav"
		"wave"		"mvm/melee_impacts\spyassassinknife_impact_robo02.wav"
	}
}

"DTF2_MVM_Weapon_Assassin_Knife.Backstab"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts\spyassassinknife_impact_robo01.wav"
		"wave"		"mvm/melee_impacts\spyassassinknife_impact_robo02.wav"
	}
}

"DTF2_MVM_Weapon_Arrow.ImpactFlesh"
{
	"channel"	"CHAN_STATIC"
	"volume"	"1.0"
	"pitch"		"PITCH_NORM"

	"rndwave"
	{
		"wave"	"mvm\melee_impacts\arrow_impact_robo01.wav"
		"wave"	"mvm\melee_impacts\arrow_impact_robo02.wav"
		"wave"	"mvm\melee_impacts\arrow_impact_robo03.wav"
	}
}

"DTF2_MVM_FryingPan.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"mvm/melee_impacts/pan_impact_robo01.wav"
		"wave"		"mvm/melee_impacts/pan_impact_robo02.wav"
		"wave"		"mvm/melee_impacts/pan_impact_robo03.wav"
	}
}

"DTF2_MVM_Weapon_mittens.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"0.8"
	"wave"		")weapons\mittens_punch.wav"
}

"DTF2_MVM_Weapon_BoxingGloves.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"weapons/boxing_gloves_hit1.wav"
		"wave"		"weapons/boxing_gloves_hit2.wav"
		"wave"		"weapons/boxing_gloves_hit3.wav"
		"wave"		"weapons/boxing_gloves_hit4.wav"
	}
}

"DTF2_MVM_Weapon_HolyMackerel.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"weapons/holy_mackerel1.wav"
		"wave"		"weapons/holy_mackerel2.wav"
		"wave"		"weapons/holy_mackerel3.wav"
	}
}

"DTF2_MVM_BallBuster.HitFlesh"
{
	"channel"		"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"wave"		"weapons\ball_buster_hit_01.wav"
}

"DTF2_MVM_Weapon_UberSaw.HitFlesh"
{
	"channel"	"CHAN_STATIC"
	"soundlevel"	"SNDLVL_NORM"
	"volume"	"1.0"
	"rndwave"
	{
		"wave"		"weapons/ubersaw_hit1.wav"
		"wave"		"weapons/ubersaw_hit2.wav"
		"wave"		"weapons/ubersaw_hit3.wav"
		"wave"		"weapons/ubersaw_hit4.wav"
	}
}



// ------------------------------------------------------------------------------------ //
// Physics Robot Body Sounds
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.RobotImpactSoft"
{
	"soundlevel"	"SNDLVL_75dB"
	"volume"		"0.4"
	"rndwave"
	{
		"wave"	"mvm/physics/robo_impact_soft_01.wav"
		"wave"	"mvm/physics/robo_impact_soft_02.wav"
		"wave"	"mvm/physics/robo_impact_soft_03.wav"
		"wave"	"mvm/physics/robo_impact_soft_04.wav"
		"wave"	"mvm/physics/robo_impact_soft_05.wav"
		"wave"	"mvm/physics/robo_impact_soft_06.wav"
		"wave"	"mvm/physics/robo_impact_soft_07.wav"
	}
}

"DTF2_MVM.RobotImpactHard"
{
	"soundlevel"	"SNDLVL_85dB"
	"volume"		"0.5, 1.0"
	"rndwave"
	{
		"wave"	"mvm/physics/robo_impact_hard_01.wav"
		"wave"	"mvm/physics/robo_impact_hard_02.wav"
		"wave"	"mvm/physics/robo_impact_hard_03.wav"
		"wave"	"mvm/physics/robo_impact_hard_04.wav"
		"wave"	"mvm/physics/robo_impact_hard_05.wav"
		"wave"	"mvm/physics/robo_impact_hard_06.wav"
	}
}

"DTF2_MVM.RobotImpactBullet"
{
	"soundlevel"		"SNDLVL_80dB"
	"volume"			"0.90"
	"rndwave"
	{
		"wave"	"mvm/physics/robo_impact_bullet01.wav"
		"wave"	"mvm/physics/robo_impact_bullet02.wav"
		"wave"	"mvm/physics/robo_impact_bullet03.wav"
		"wave"	"mvm/physics/robo_impact_bullet04.wav"
	}
}

"DTF2_MVM.RobotScrape"
{
	"soundlevel"	"SNDLVL_70dB"
	"volume"		"0.6"
	"wave"			"mvm/physics/robo_scrape_loop.wav"
}

// Not currently used...added to suppress console warnings
"DTF2_Spy.M_MVM_Death"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/spy_PainSevere01.mp3"
		"wave"		"vo/Spy_PainSevere02.mp3"
		"wave"		"vo/Spy_PainSevere03.mp3"
		"wave"		"vo/Spy_PainSevere04.mp3"
		"wave"		"vo/Spy_PainSevere05.mp3"
	}
}

"DTF2_Spy.M_MVM_CritDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/Spy_PainCrticialDeath01.mp3"
		"wave"		"vo/Spy_PainCrticialDeath02.mp3"
		"wave"		"vo/Spy_PainCrticialDeath03.mp3"
	}
}

"DTF2_Spy.M_MVM_MeleeDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/Spy_PainCrticialDeath01.mp3"
		"wave"		"vo/Spy_PainCrticialDeath02.mp3"
		"wave"		"vo/Spy_PainCrticialDeath03.mp3"
	}
}

"DTF2_Spy.M_MVM_ExplosionDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/spy_PainSevere01.mp3"
		"wave"		"vo/Spy_PainSevere02.mp3"
		"wave"		"vo/Spy_PainSevere03.mp3"
		"wave"		"vo/Spy_PainSevere04.mp3"
		"wave"		"vo/Spy_PainSevere05.mp3"
	}
}

"DTF2_Engineer.MVM_Death"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainSevere01.mp3"
		"wave"		"vo/engineer_PainSevere02.mp3"
		"wave"		"vo/engineer_PainSevere03.mp3"
		"wave"		"vo/engineer_PainSevere04.mp3"
		"wave"		"vo/engineer_PainSevere05.mp3"
		"wave"		"vo/engineer_PainSevere06.mp3"
		"wave"		"vo/engineer_PainSevere07.mp3"
	}
}

"DTF2_Engineer.MVM_CritDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainCrticialDeath01.mp3"
		"wave"		"vo/engineer_PainCrticialDeath02.mp3"
		"wave"		"vo/engineer_PainCrticialDeath03.mp3"
		"wave"		"vo/engineer_PainCrticialDeath04.mp3"
		"wave"		"vo/engineer_PainCrticialDeath05.mp3"
		"wave"		"vo/engineer_PainCrticialDeath06.mp3"
	}
}

"DTF2_Engineer.MVM_MeleeDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainCrticialDeath01.mp3"
		"wave"		"vo/engineer_PainCrticialDeath02.mp3"
		"wave"		"vo/engineer_PainCrticialDeath03.mp3"
		"wave"		"vo/engineer_PainCrticialDeath04.mp3"
		"wave"		"vo/engineer_PainCrticialDeath05.mp3"
		"wave"		"vo/engineer_PainCrticialDeath06.mp3"
	}
}

"DTF2_Engineer.MVM_ExplosionDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainCrticialDeath01.mp3"
		"wave"		"vo/engineer_PainCrticialDeath02.mp3"
		"wave"		"vo/engineer_PainCrticialDeath03.mp3"
		"wave"		"vo/engineer_PainCrticialDeath04.mp3"
		"wave"		"vo/engineer_PainCrticialDeath05.mp3"
		"wave"		"vo/engineer_PainCrticialDeath06.mp3"
	}
}

"DTF2_Engineer.M_MVM_Death"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainSevere01.mp3"
		"wave"		"vo/engineer_PainSevere02.mp3"
		"wave"		"vo/engineer_PainSevere03.mp3"
		"wave"		"vo/engineer_PainSevere04.mp3"
		"wave"		"vo/engineer_PainSevere05.mp3"
		"wave"		"vo/engineer_PainSevere06.mp3"
		"wave"		"vo/engineer_PainSevere07.mp3"
	}
}

"DTF2_Engineer.M_MVM_CritDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainCrticialDeath01.mp3"
		"wave"		"vo/engineer_PainCrticialDeath02.mp3"
		"wave"		"vo/engineer_PainCrticialDeath03.mp3"
		"wave"		"vo/engineer_PainCrticialDeath04.mp3"
		"wave"		"vo/engineer_PainCrticialDeath05.mp3"
		"wave"		"vo/engineer_PainCrticialDeath06.mp3"
	}
}

"DTF2_Engineer.M_MVM_MeleeDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainCrticialDeath01.mp3"
		"wave"		"vo/engineer_PainCrticialDeath02.mp3"
		"wave"		"vo/engineer_PainCrticialDeath03.mp3"
		"wave"		"vo/engineer_PainCrticialDeath04.mp3"
		"wave"		"vo/engineer_PainCrticialDeath05.mp3"
		"wave"		"vo/engineer_PainCrticialDeath06.mp3"
	}
}

"DTF2_Engineer.M_MVM_ExplosionDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/engineer_PainCrticialDeath01.mp3"
		"wave"		"vo/engineer_PainCrticialDeath02.mp3"
		"wave"		"vo/engineer_PainCrticialDeath03.mp3"
		"wave"		"vo/engineer_PainCrticialDeath04.mp3"
		"wave"		"vo/engineer_PainCrticialDeath05.mp3"
		"wave"		"vo/engineer_PainCrticialDeath06.mp3"
	}
}

"DTF2_Civilian.MVM_Death"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainSevere01.mp3"
		"wave"		"vo/scout_PainSevere02.mp3"
		"wave"		"vo/scout_PainSevere03.mp3"
		"wave"		"vo/scout_PainSevere04.mp3"
		"wave"		"vo/scout_PainSevere05.mp3"
		"wave"		"vo/scout_PainSevere06.mp3"
	}
}

"DTF2_Civilian.MVM_CritDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainCrticialDeath01.mp3"
		"wave"		"vo/scout_PainCrticialDeath02.mp3"
		"wave"		"vo/scout_PainCrticialDeath03.mp3"
	}
}

"DTF2_Civilian.MVM_MeleeDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainCrticialDeath01.mp3"
		"wave"		"vo/scout_PainCrticialDeath02.mp3"
		"wave"		"vo/scout_PainCrticialDeath03.mp3"
	}
}

"DTF2_Civilian.MVM_ExplosionDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainCrticialDeath01.mp3"
		"wave"		"vo/scout_PainCrticialDeath02.mp3"
		"wave"		"vo/scout_PainCrticialDeath03.mp3"
	}
}

"DTF2_Civilian.M_MVM_Death"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainSevere01.mp3"
		"wave"		"vo/scout_PainSevere02.mp3"
		"wave"		"vo/scout_PainSevere03.mp3"
		"wave"		"vo/scout_PainSevere04.mp3"
		"wave"		"vo/scout_PainSevere05.mp3"
		"wave"		"vo/scout_PainSevere06.mp3"
	}
}

"DTF2_Civilian.M_MVM_CritDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainCrticialDeath01.mp3"
		"wave"		"vo/scout_PainCrticialDeath02.mp3"
		"wave"		"vo/scout_PainCrticialDeath03.mp3"
	}
}

"DTF2_Civilian.M_MVM_MeleeDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainCrticialDeath01.mp3"
		"wave"		"vo/scout_PainCrticialDeath02.mp3"
		"wave"		"vo/scout_PainCrticialDeath03.mp3"
	}
}

"DTF2_Civilian.M_MVM_ExplosionDeath"
{
	"channel"		"CHAN_VOICE"
	"volume"		"VOL_NORM"
	"pitch"			"PITCH_NORM"

	"soundlevel"	"SNDLVL_95dB"

	"rndwave"			
	{
		"wave"		"vo/scout_PainCrticialDeath01.mp3"
		"wave"		"vo/scout_PainCrticialDeath02.mp3"
		"wave"		"vo/scout_PainCrticialDeath03.mp3"
	}
}

// ------------------------------------------------------------------------------------ //
// Melee impact replacements Use instead of flesh impact sounds
// ------------------------------------------------------------------------------------ //
"DTF2_MVM_Robot.BulletImpact"
{
	"channel"		"CHAN_BODY"
	"soundlevel"	"SNDLVL_80dB"
	"pitch"			"PITCH_NORM"
	"volume"		"0.90"
	"rndwave"
	{
		"wave"		"physics/metal/metal_solid_impact_bullet1.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet2.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet3.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet4.wav"
	}

}
"DTF2_MVM_Giant.BulletImpact"
{
	"channel"		"CHAN_BODY"
	"soundlevel"	"SNDLVL_80dB"
	"pitch"			"PITCH_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"physics/metal/metal_solid_impact_bullet1.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet2.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet3.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet4.wav"
	}

}
"DTF2_MVM_Tank.BulletImpact"
{
	"channel"		"CHAN_BODY"
	"soundlevel"	"SNDLVL_80dB"
	"pitch"			"PITCH_NORM"
	"volume"		"1.0"
	"rndwave"
	{
		"wave"		"physics/metal/metal_solid_impact_bullet1.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet2.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet3.wav"
		"wave"		"physics/metal/metal_solid_impact_bullet4.wav"
	}

}

// ------------------------------------------------------------------------------------ //
// Weapon Upgrades
// ------------------------------------------------------------------------------------ //
"DTF2_Weapon_Upgrade.ExplosiveHeadshot"
{
	"channel"		"CHAN_AUTO"
	"soundlevel"	"SNDLVL_NORM"
	"volume"		"1.0"
	"wave"			")weapons\upgrade_explosive_headshot.wav"
}

"DTF2_Weapon_Upgrade.DamageBonus1"
{
	"channel"		"CHAN_AUTO"
	"volume"		"0.55"
	"soundlevel"	"SNDLVL_74dB"
	"wave"			"misc/null.wav"
}

"DTF2_Weapon_Upgrade.DamageBonus2"
{
	"channel"		"CHAN_AUTO"
	"volume"		"0.7"
	"soundlevel"	"SNDLVL_74dB"
	"wave"			"misc/null.wav"
}

"DTF2_Weapon_Upgrade.DamageBonus3"
{
	"channel"		"CHAN_AUTO"
	"volume"		"0.85"
	"soundlevel"	"SNDLVL_74dB"
	"wave"			"misc/null.wav"
}

"DTF2_Weapon_Upgrade.DamageBonus4"
{
	"channel"		"CHAN_AUTO"
	"volume"		"1.000"
	"soundlevel"	"SNDLVL_74dB"
	"wave"			"misc/null.wav"
}

"DTF2_MVM.PlayerRevived"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.0"
	"pitch"			"PITCH_NORM"
	"soundlevel"	"SNDLVL_90dB"

	"wave"			"mvm\mvm_revive.wav"
}

// ------------------------------------------------------------------------------------ //
// MVM Engineer and Teleporter
// ------------------------------------------------------------------------------------ //

"DTF2_MVM.Robot_Engineer_Spawn"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_150dB"
	"wave"			")weapons/guitar_strum.wav"
}

"DTF2_MVM.Robot_Teleporter_Deliver"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_150dB"
	"wave"			")mvm/mvm_tele_deliver.wav"
}

// Level Specific

"DTF2_grinder_loop"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.8"
	"soundlevel"  	"SNDLVL_70dB"
	"pitch"			"PITCH_NORM"
	"wave"		")ambient/grinder/grinderloop_01.wav"
}

"DTF2_grinder_human"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1"
	"soundlevel"  	"SNDLVL_105dB"
	"pitch"			"PITCH_NORM"
	"rndwave"
	{
		"wave"	")ambient_mp3/grinder/grinderhuman_01.mp3"
		"wave"	")ambient_mp3/grinder/grinderhuman_02.mp3"
	}
}

"DTF2_grinder_bot"
{
	"channel"		"CHAN_STATIC"
	"volume"		"0.5"
	"soundlevel"  	"SNDLVL_105dB"
	"pitch"			"PITCH_NORM"
	"rndwave"
	{
		"wave"	")ambient_mp3/grinder/grinderbot_01.mp3"
		"wave"	")ambient_mp3/grinder/grinderbot_02.mp3"
		"wave"	")ambient_mp3/grinder/grinderbot_03.mp3"
	}
}

// ------------------------------------------------------------------------------------ //
// MVM klaxon
// ------------------------------------------------------------------------------------ //


"DTF2_mvm.cpoint_alarm"
{
	"channel"		"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NONE"
	"pitch"		"PITCH_NORM"
	
	"wave"		"mvm\mvm_cpoint_klaxon.wav"
}


// ------------------------------------------------------------------------------------ //
// MVM robotstun
// ------------------------------------------------------------------------------------ //


"DTF2_mvm.robo_stun_lp"
{
	"channel"		"CHAN_STATIC"
	"volume"	"1.0"
	"soundlevel"  	"SNDLVL_NONE"
	"pitch"		"PITCH_NORM"

	"wave"	")mvm\mvm_robo_stun.wav"


}

// ------------------------------------------------------------------------------------ //
// MVM upgrade refund
// ------------------------------------------------------------------------------------ //
"DTF2_MVM.RespecAwarded"
{
	"channel"		"CHAN_STATIC"
	"volume"		"1.0"
	"pitch"			"100"
	"soundlevel"  	"SNDLVL_105dB"
	"wave"			")mvm/mvm_tank_horn.wav"
}
]==]
