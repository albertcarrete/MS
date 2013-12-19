class RoboHelper_Pawn extends S_Pawn;


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
		SkeletalMesh=SkeletalMesh'RoboHelper1.Mesh.RoboHelper1_SKMesh'
		AnimTreeTemplate=AnimTree'RoboHelper1.AnimTree.RoboHelper1_AnimTree'
		AnimSets(0)=AnimSet'RoboHelper1.AnimSet.RoboHelper1_AnimSet'
		PhysicsAsset=PhysicsAsset'RoboHelper1.Physics.RoboHelper1_SKMesh_Physics'
	End Object

		// Create the light function in script
	Begin Object Class=LightFunction Name=MyLightFunction
		SourceMaterial=Material'PXFlashLight.FlashLight_Pattern1_mat'
		Scale = (X=512, Y=512, Z=512)
	End Object


}