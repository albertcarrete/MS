class TestShip2 extends Ship;

event Tick(float DeltaTime){
	local Vector tempLoc;

	Super.Tick(DeltaTime);

	tempLoc = Location;
	tempLoc.Y += 100 * DeltaTime;
	//SetLocation(tempLoc);
}

simulated function TurnPitch(float DeltaTime){
	local S_Pawn P;
	local Rotator tempRot1, tempRot2;
	local Vector X, Y, Z, ShipX, ShipY, ShipZ;

	tempRot1 = Rotation;

	tempRot1.Pitch += 1000 * DeltaTime;
	SetRotation(tempRot1);
/*
	foreach WorldInfo.AllPawns(class'S_Pawn', P){
		if(P.ShipActor != none && P.ShipActor == self){
			tempRot2 = P.Controller.Rotation;

			tempRot1 = Rotation;
			GetAxes(Rotation, ShipX, ShipY, ShipZ);
			
			GetAxes(tempRot2, X, Y, Z);
			
			

			


			P.Controller.SetRotation(Rotator(X + 1000*ShipX));
		}
	}*/
}

function SpawnAllShipParts(){

	SpawnShipPart(class'FrameBeam', 0,0,0);
	SpawnShipPart(class'FrameBeam', 0,0,0,,16384);
	SpawnShipPart(class'FrameBeam', 0,0,0,,32768);
	SpawnShipPart(class'FrameBeam', 0,0,0,,-16384);

	SpawnShipPart(class'CurvedWall', 0,0,0);
	SpawnShipPart(class'CurvedWall', 0,0,0,,16384);
	SpawnShipPart(class'CurvedWall', 0,0,0,,32768);
	SpawnShipPart(class'CurvedWall', 0,0,0,,-16384);

	SpawnShipPart(class'FloorPiece', 300,483,-168);

	//SpawnShipPart(class'ShipWeapon', -188,-936,136, 16384, , -16384);
	//SpawnShipPart(class'ShipWeapon', -188, 400,136, 16384, , -16384);


	theSeat = Seat(SpawnShipPart(class'Seat', 0, 0, -150));



	SpawnShipLight(class'ShipLight', 0, 0, 0);


}

DefaultProperties
{
	defaultSpawnPoint = (X=0,Y=0,Z=0)
	//bHidden = true
}
