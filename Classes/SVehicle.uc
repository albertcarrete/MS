class SVehicle extends Ship;

var StaticMeshComponent collisionMesh;
var SkeletalMeshComponent vehicleMesh;
event PostBeginPlay(){
	super.PostBeginPlay();
	collisionMesh.SetHidden(true);


}


DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=VehicleSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'ShipA.Meshes.ShipA_LAZR_MTurret_SKEL'
		//AnimTreeTemplate=AnimTree'Human1.AnimTree.Human1_AnimTree'
		AnimSets(0)=AnimSet'ShipA.AnimSets.ShipA_LAZR_MTurret_SKEL_Anims'
		//AnimSets(1)=AnimSet'Human1.AnimSet.Humanoid_AnimSet'
		//PhysicsAsset=PhysicsAsset'MaleBase.Physics.MaleBase_Physics'
	End Object
	Components.Add(VehicleSkeletalMeshComponent)
	vehicleMesh = VehicleSkeletalMeshComponent

	Begin Object Class=StaticMeshComponent Name=CollisionStaticMeshComponent
		StaticMesh = StaticMesh'ShipA.Meshes.ShipA_LAZR_MTurret_COL1'
		CollideActors = true
		BlockActors = true
		bHidden = true

	End Object
	Components.Add(CollisionStaticMeshComponent)
	collisionMesh = CollisionStaticMeshComponent
	CollisionComponent = CollisionStaticMeshComponent

	Components.Remove(ShipPartStaticMeshComponent)

	//What is uses as its collision

	bCollideActors = true
	bBlockActors = true
	bCollideWorld = true
	CollisionType = COLLIDE_BlockAll
}
