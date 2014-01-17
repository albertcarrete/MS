class SKActorSpawnable extends KActorSpawnable;

var StaticMeshComponent theMesh;

simulated event PostBeginPlay(){
	SetPhysics(PHYS_falling);
	SetPhysics(PHYS_rigidbody);
}

DefaultProperties
{
    Begin Object Class=StaticMeshComponent Name=MyStaticMesh
	StaticMesh=StaticMesh'Rocks.Mesh.Rock1'
	bNotifyRigidBodyCollision=true
    HiddenGame=FALSE
    CollideActors=TRUE
    BlockActors=TRUE
    AlwaysCheckCollision=TRUE
    ScriptRigidBodyCollisionThreshold=0.001
    LightingChannels=(Dynamic=TRUE)
    //DepthPriorityGroup=SDPG_Foreground
    //LightEnvironment=MyLightEnvironment;
	End Object
	Components.Add(MyStaticMesh)
	theMesh = MyStaticMesh


	CollisionComponent = MyStaticMesh

    bCollideActors=true
	bNoEncroachCheck=true
	bBlocksTeleport=true
	bBlocksNavigation=true
	bPawnCanBaseOn=true
	bSafeBaseIfAsleep=TRUE
	bNeedsRBStateReplication=true
	bCollideWorld=true;
}

