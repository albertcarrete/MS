class MeleeBlade extends Armor;

var SoundCue BladeCue;

DefaultProperties
{
	BladeCue = SoundCue'ArA_Armor.Sounds.Swooshh1_Cue'

	Begin Object Name=ArmorMeshComponent
		StaticMesh=StaticMesh'ArA_Armor.Meshes.Blade2_Mesh'
		bHidden = true
	End Object
}
