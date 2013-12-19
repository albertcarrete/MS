class Armor extends Actor;

var StaticMeshComponent ArmorMesh;

var MaterialInstance ArmorInst;

event PostBeginPlay(){
	
	SetCollisionType(COLLIDE_NoCollision);
}

/** changes of color of an armor piece material, MatNum decides which material
 *  Color numbers should be between 0 and 1 most of the time*/
function ChangeColor(int MatNum, float red, float green, float blue, float alpha){
	local LinearColor theColor;
	local name matName;
	local int i;

	theColor = MakeLinearColor(red, green, blue, alpha);

	if(MatNum == 0)
		matName = 'Gloss_mat';
	else if(MatNum == 1)
		matName = '1stColor_mat';
	else if(MatNum == 2)
		matName = '2ndColor_mat';
	else if(MatNum == 3)
		matName = 'Glow_mat';
	else if(MatNum == 4)
		matName = 'Blade_Mat';

	for(i = 0; i < 5; i++){
	
		ArmorInst = new(none) class'MaterialInstanceConstant';

		ArmorInst.SetParent(ArmorMesh.GetMaterial(i).GetMaterial());
	
		if(ArmorInst.Parent.Name == matName){
			ArmorMesh.SetMaterial(i, ArmorInst);
			ArmorInst.SetVectorParameterValue('Color',theColor);
		}
	}
}

DefaultProperties
{
	bShadowParented = true

	bNoDelete = false

	Begin Object Class=StaticMeshComponent Name=ArmorMeshComponent
		StaticMesh=StaticMesh'ArA_Armor.Meshes.ArA_Helmet'
		CollideActors=false
		BlockActors=false
		BlockNonZeroExtent=false
		BlockZeroExtent=false
	End Object
	ArmorMesh=ArmorMeshComponent
	Components.Add(ArmorMeshComponent)
}
