class Shield extends Armor;

DefaultProperties
{
	CollisionType=COLLIDE_BlockWeapons

	CollisionComponent = ArmorMeshComponent

	Begin Object Name=ArmorMeshComponent
		StaticMesh=StaticMesh'ArA_Armor.Meshes.Shield1_Mesh'
		bHidden = true
	End Object
}
