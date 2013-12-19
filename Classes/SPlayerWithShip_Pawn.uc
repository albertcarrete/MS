class SPlayerWithShip_Pawn extends SPlayer_Pawn;

simulated function PostBeginPlay(){
	local Vector tempLoc;

	Super.PostBeginPlay();

	CreateCockpit();
	tempLoc = ShipActor.Location + ShipActor.defaultSpawnPoint;
	SetLocation(tempLoc);
	SetRotation(ShipActor.Rotation);
	ToggleDriveShip();
	SetTimer(0.01, false, 'PressWorldView');

}

DefaultProperties
{
}
