class SPushableObject extends Actor;

var SKActorSpawnable TheKActor;
var StaticMeshComponent theMesh;

event PostBeginPlay(){
	Super.PostBeginPlay();

	theMesh.SetHidden(true);
	TheKActor = Spawn(class'SKActorSpawnable',,, Location, Rotation);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=MyStaticMesh
	StaticMesh=StaticMesh'Rocks.Mesh.Rock1'
	End Object
	theMesh = MyStaticMesh
}
