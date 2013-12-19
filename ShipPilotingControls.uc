class ShipPilotingControls extends ShipPart placeable;

event PostBeginPlay(){
	Super.PostBeginPlay();

	SetCollisionType(COLLIDE_BlockAll);
	SMesh.SetRBChannel(RBCC_Untitled1);
}

DefaultProperties
{

	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'CommandSeats.Mesh.CommandSeat_1_model'
	End Object
}
