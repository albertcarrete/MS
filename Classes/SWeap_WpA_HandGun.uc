class SWeap_WpA_HandGun extends SWeapon;

DefaultProperties
{
	bOneHanded = true

	WeaponProjectiles(0)=SProj_Infantry

	HoldAnim = H_HoldingHandGun1
	AimAnim = H_AimHandGun1

	AttachmentClass=class'WpA_HandGun_Attachment'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WpA_HandGun.Mesh.WpA_HandGun_mesh'
	End Object
}
