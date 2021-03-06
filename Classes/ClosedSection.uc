class ClosedSection extends Actor;

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=RoomHallwayStaticMeshComponent
		StaticMesh=StaticMesh'Corridor.Mesh.Corridor_Wall1'
		CollideActors=true
		BlockActors=true
		BlockNonZeroExtent=true
		BlockZeroExtent=true
	End Object
	Components.Add(RoomHallwayStaticMeshComponent)

/*	Begin Object Class=StaticMeshComponent Name=Room
		StaticMesh=StaticMesh'Rooms.Mesh.Room_Placeholder_01'
		CollideActors=true
		BlockActors=true
		BlockNonZeroExtent=true
		BlockZeroExtent=true
	End Object*/

	CollisionType = COLLIDE_BlockAll
}
