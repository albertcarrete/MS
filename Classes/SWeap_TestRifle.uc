class SWeap_TestRifle extends SWeapon;

DefaultProperties
{
	bOneHanded = false

	WeaponProjectiles(0)=SProj_Infantry

	HoldAnim = H_HoldingRifle1
	AimAnim = H_AimRifle1

	AttachmentClass=class'SWeaponAttachment'

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
		AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
		Animations=MeshSequenceA
		Scale=0.9
		FOV=60.0
	End Object

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'TestRifle.Mesh.TestRifle_mesh'
	End Object
}
