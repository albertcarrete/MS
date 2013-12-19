class SCannon extends Actor;

var StaticMeshComponent SMesh;

event PostBeginPlay(){

	SMesh.InitRBPhys();

	SetCollisionType(COLLIDE_BlockAll);
}

DefaultProperties
{
	bNoEncroachCheck=false
	BlockRigidBody=true
	bMovable=true
	bCollideActors=true
	bStatic = false;
	bNoDelete = false;

	Begin Object Class=SkeletalMeshComponent Name=CannonSkeletalMeshComponent
		StaticMesh=SkeletalMesh'Engine_1.Mesh.Cannon_SKmesh'
		CollideActors=true
		BlockActors=true
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		RBCollideWithChannels=(Pawn=true, Default = true, GameplayPhysics = true,Untitled1 = true)
	End Object
	SMesh=CannonStaticMeshComponent
	Components.Add(HallwayStaticMeshComponent)

	CollisionType = COLLIDE_BlockAll
	CollisionComponent = CannonStaticMeshComponent
}
