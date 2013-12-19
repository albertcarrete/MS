class RoboBunny extends S_Pawn;


simulated function PostBeginPlay(){
	Super.PostBeginPlay();
	Mesh.AttachComponentToSocket(MyLight, 'Light_Socket');

	HandleWeaponAnims();
}

function AddDefaultInventory()
{

}

defaultproperties
{

	DrawScale = 1

   IsoCamAngle=15000//6420 //35.264 degrees
   CamOffsetDistance=6000.0

	CamOffset=(X=15,Y=30,Z=-30)

	GroundSpeed=60
	AirSpeed = 60
	SprintSpeedMultiplier=4

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0020.000000
		CollisionHeight=+0050.000000
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'Human1.Mesh.Bunny_SKMesh'
		AnimTreeTemplate=AnimTree'Human1.AnimTree.Bunny_AnimTree'
		AnimSets(0)=AnimSet'Human1.AnimSet.Bunny_SKMesh_Anims'
		PhysicsAsset=PhysicsAsset'Human1.Physics.Bunny_SKMesh_Physics'
	End Object

		// Create the light function in script
	Begin Object Class=LightFunction Name=MyLightFunction
		SourceMaterial=Material'PXFlashLight.FlashLight_Pattern1_mat'
		Scale = (X=512, Y=512, Z=512)
	End Object


}