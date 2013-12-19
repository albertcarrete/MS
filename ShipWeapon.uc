class ShipWeapon extends ShipPart;

function StartFire(){
	if(ShipOwner.bWeaponsOn)
		SpawnProjectile();
}

function SpawnProjectile(){
	local Projectile P;
	local vector newLoc, X, Y, Z;

	if(ShipOwner != none){
		GetAxes(ShipOwner.Rotation, X, Y, Z);

		newLoc = Location;
		newLoc += 800 * X;
		P = Spawn(class'S_ShipCannonProj',self,,newLoc);
		P.Init(X);

	}
}

DefaultProperties
{
	DrawScale = 6

	bIsWeapon = true

	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'CommandSeats.Mesh.Cannon_Mesh'
	End Object
}
