class SWeap_LinkGun extends SWeapon;

DefaultProperties
{
	AttachmentClass=class'UTAttachment_Linkgun'

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
		AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
		Animations=MeshSequenceA
		Scale=0.9
		FOV=60.0
	End Object

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
	End Object
}
