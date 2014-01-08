class SWeaponAttachment extends UTAttachment_LinkGun;

simulated function AttachTo(UTPawn OwnerPawn)
{
	Super.AttachTo(OwnerPawn);
	Mesh.SetLightEnvironment(None);
}

DefaultProperties
{
	DrawScale = 1.1

	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		LightEnvironment = none
		SkeletalMesh=SkeletalMesh'TestRifle.Mesh.TestRifle_mesh'
		Translation=(Z=1)
		Rotation=(Roll=-400)
		Scale=1
	End Object
}
