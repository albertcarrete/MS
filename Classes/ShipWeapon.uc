class ShipWeapon extends ShipPart;

/** How much ship energy it costs to fire this weapon*/
var float EnergyCost;

function StartFire(){
	if(ShipOwner.bWeaponsOn){
		SpawnProjectile();
		PlaySound(SoundCue'ProjectSSounds.LaserSounds.pew1_Cue', false, false, false);
	}
}

function SpawnProjectile(){
	local S_Projectile P;
	local vector newLoc, X, Y, Z;

	if(ShipOwner != none){
		GetAxes(ShipOwner.Rotation, X, Y, Z);

		newLoc = Location;
		newLoc += 800 * X;
		P = Spawn(class'S_ShipCannonProj',self,,newLoc);
		P.WeaponOwner = self;
		P.Init(X);

	}
}

DefaultProperties
{
	DrawScale = 6

	EnergyCost  = 50
	bIsWeapon = true

	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'CommandSeats.Mesh.Cannon_Mesh'
	End Object
}
