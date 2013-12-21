class MeleeBlade extends Armor;

var SoundCue BladeCue;

DefaultProperties
{
	BladeCue = SoundCue'ArA_Armor.Sounds.Swooshh1_Cue'

	Components.Remove(ArmorMeshComponent)

	Begin Object Class=SkeletalMeshComponent Name=ArmorSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'ArA_Armor.Meshes.Blade3_SKMesh'
	End Object
	ArmorMesh = ArmorSkeletalMeshComponent
	Components.Add(ArmorSkeletalMeshComponent)
}
