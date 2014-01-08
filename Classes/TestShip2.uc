class TestShip2 extends Ship;

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
	//bHidden = true
}
