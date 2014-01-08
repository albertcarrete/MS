class SWeapon extends UTWeap_LinkGun;//UTWeapon placeable ClassGroup(Pickups,Weapon);

var bool bOneHanded;

var name HoldAnim;
var name AimAnim;

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */
simulated function Projectile ProjectileFire()
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(),,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			if(SpawnedProjectile.IsA('S_Projectile'))
				S_Projectile(SpawnedProjectile).InfantryWeaponOwner = self;
			
			SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc )) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}
/*
simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local Vector StartLoc;

	if(SkeletalMeshComponent(DroppedPickupMesh).GetSocketWorldLocationAndRotation('ProjectileStart', StartLoc)){
		return StartLoc;
	}else
		Super.GetPhysicalFireStartLoc(AimDir);
}*/

DefaultProperties
{
	bOneHanded = false

	WeaponProjectiles(0)=SProj_Infantry

	HoldAnim = H_HoldingRifle1
	AimAnim = H_AimRifle1
}
