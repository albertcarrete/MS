class Wall extends ShipPart;

var Actor FloorActor;

simulated event PostBeginPlay(){
	
	Super.PostBeginPlay();

	SetCollisionType(COLLIDE_BlockAll);
	SMesh.SetRBChannel(RBCC_Untitled1);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=WallStaticMeshComponent
		StaticMesh=StaticMesh'Placeholders.Meshes.CorridorA_Long'
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		RBCollideWithChannels=(Pawn=true, Default = true, GameplayPhysics = true,Untitled1 = false)
		RBChannel = RBCC_Untitled1
	End Object
	Components.Add(WallStaticMeshComponent)

/*	Begin Object Class=StaticMeshComponent Name=Room
		StaticMesh=StaticMesh'Rooms.Mesh.Room_Placeholder_01'
		CollideActors=true
		BlockActors=true
		BlockNonZeroExtent=true
		BlockZeroExtent=true
	End Object*/

	CollisionType = COLLIDE_BlockAll
	CollisionComponent = WallStaticMeshComponent
}
