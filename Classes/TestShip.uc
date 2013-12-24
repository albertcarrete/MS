class TestShip extends Ship;

simulated event PostBeginPlay(){
	Super.PostBeginPlay();
	//WHOAH
	SpawnAllShipParts();
	SMesh.SetActorCollision(false, false, false);
}

function ShipPart SpawnShipPart(class<ShipPart> ShipPartClass, float locXOffset, float locYOffset, float locZOffset, optional float rotYawOffset, optional float rotPitchOffset, optional float rotRollOffset){
	local Vector tempLoc;
	local Rotator tempRot;
	local ShipPart tempShipPart;

	tempLoc = Location;
	tempRot = Rotation;
	if(rotYawOffset > 0 || rotYawOffset < 0)
		tempRot.Yaw += rotYawOffset;
	if(rotPitchOffset > 0 || rotPitchOffset < 0)
		tempRot.Pitch += rotPitchOffset;
	if(rotRollOffset > 0 || rotRollOffset < 0)
		tempRot.Roll += rotRollOffset;

	tempLoc.X += locXOffset;
	tempLoc.Y += locYOffset;
	tempLoc.Z += locZOffset;
	
	tempShipPart = Spawn(ShipPartClass, , , tempLoc, tempRot);
	ShipPartsArray.AddItem(tempShipPart);
	tempShipPart.ShipOwner = self;
	if(tempShipPart.bIsWeapon){
		ShipWeaponArray.AddItem(ShipWeapon(tempShipPart));
		PawnOwner.ClientMessage("Found a Ship Weapon!!");
	}

	tempShipPart.BaseToOwner();

	return tempShipPart;
}

function SpawnShipLight(class<ShipLight> ShipPartClass, float locXOffset, float locYOffset, float locZOffset, optional float rotYawOffset, optional float rotPitchOffset, optional float rotRollOffset){
	local Vector tempLoc;
	local Rotator tempRot;
	local ShipLight tempShipPart;

	tempLoc = Location;
	tempRot = Rotation;
	if(rotYawOffset > 0 || rotYawOffset < 0)
		tempRot.Yaw += rotYawOffset;
	if(rotPitchOffset > 0 || rotPitchOffset < 0)
		tempRot.Pitch += rotPitchOffset;
	if(rotRollOffset > 0 || rotRollOffset < 0)
		tempRot.Roll += rotRollOffset;

	tempLoc.X += locXOffset;
	tempLoc.Y += locYOffset;
	tempLoc.Z += locZOffset;
	
	tempShipPart = Spawn(ShipPartClass, , , tempLoc, tempRot, , true);
	tempShipPart.ShipOwner = self;
	LightsArray.AddItem(tempShipPart);

	tempShipPart.BaseToOwner();
}

function SpawnAllShipParts(){

	SpawnShipPart(class'Cockpit', 0,0,0);
	SpawnShipPart(class'Corridor', -576, 8,0);

	SpawnShipPart(class'Corridor', -1728, -720,0);
	SpawnShipPart(class'Corridor', -1728, 720,0);
	SpawnShipPart(class'Corridor', -1152, 720,0);
	SpawnShipPart(class'Corridor', -1152, -720,0);

	SpawnShipPart(class'Cmd_Wall', 0, 8, 0 , -32768);
	SpawnShipPart(class'Cmd_Wall', -576, -576, 0);
	SpawnShipPart(class'Cmd_Wall', -576, 8, 0);
	SpawnShipPart(class'Cmd_Entrance', -576, 8, 0);
	SpawnShipPart(class'Cmd_Entrance', -608, 8, 0);
	
	SpawnShipPart(class'Cmd_Head', 0, 0, 0);
	SpawnShipPart(class'Cmd_Scoop', 0, 0, 0);
	SpawnShipPart(class'Cmd_Belly', 0, 0, 0);

	SpawnShipPart(class'Cmd_Flank', -4, -576, -16);
	SpawnShipPart(class'Cmd_Flank_R', -4, 16, -16);
	
	SpawnShipPart(class'THR_Front', -576, -960, 520);
	SpawnShipPart(class'THR_Front_R', -575, 383, 520);

	SpawnShipPart(class'Base_Hull', -576, -1296, 0);
	SpawnShipPart(class'Base_Hull', -1152, -1296, 0);
	
	SpawnShipPart(class'Base_Hull', -1152,720, 0, 32768);
	SpawnShipPart(class'Base_Hull', -1728, 720, 0, 32768);

	SpawnShipPart(class'GravityGenerator', -1450, -980, 4);
	SpawnShipPart(class'PowerCore', -1465, 450, 0);


	SpawnShipPart(class'Floor', -575, -720, 0);
	SpawnShipPart(class'Floor', -575, -144, 0);

	SpawnShipPart(class'Floor', -575, -432, 0);
	SpawnShipPart(class'Floor', -863, -432, 0);
	SpawnShipPart(class'Floor', -1151, -432, 0);

	SpawnShipPart(class'Floor', -1151, -720, 0);
	SpawnShipPart(class'Floor', -1151, -144, 0);

	SpawnShipPart(class'Floor', -1439, -432, 0);

	SpawnShipPart(class'Wall_A', -608, -1264, 0, -49152);
	SpawnShipPart(class'Wall_A', -608, -976, 0, -49152);
	SpawnShipPart(class'Wall_A', -608, 176, 0, -49152);
	SpawnShipPart(class'Wall_A', -608, 464, 0, -49152);

	SpawnShipPart(class'Wall_A', -1184, -976, 0, -49152);//
	SpawnShipPart(class'Wall_A', -1184, -1264, 0, -49152);//
	SpawnShipPart(class'Wall_A', -1184, 176, 0, -49152);//
	SpawnShipPart(class'Wall_A', -1184, 464, 0, -49152);//

	SpawnShipPart(class'Wall_A', -1696, -1040, 0, -16384);
	SpawnShipPart(class'Wall_A', -1696, -752, 0, -16384);
	SpawnShipPart(class'Wall_A', -1696, 400, 0, -16384);
	SpawnShipPart(class'Wall_A', -1696, 688, 0, -16384);

	SpawnShipPart(class'Wall_A', -1120, -1040, 0, -16384);//
	SpawnShipPart(class'Wall_A', -1120, -752, 0, -16384);//
	SpawnShipPart(class'Wall_A', -1120, 400, 0, -16384);
	SpawnShipPart(class'Wall_A', -1120, 688, 0, -16384);

	SpawnShipPart(class'Wall_A', -831, -463, 0, -16384);
	SpawnShipPart(class'Wall_A', -831, 112, 0, -16384);
	SpawnShipPart(class'Wall_A', -1408, -463, 0, -16384);
	SpawnShipPart(class'Wall_A', -1408, 112, 0, -16384);

	SpawnShipPart(class'Wall_A', -1760, -1264, 0, -49152);

	SpawnShipPart(class'Wall_A', -1120, -400, 0, 0);
	SpawnShipPart(class'Wall_A', -895, -175, 0, 32768);

	SpawnShipPart(class'Wall_A', -1695, -400, 0, 0);
	SpawnShipPart(class'Wall_A', -1472, -175, 0, 32768);

	SpawnShipPart(class'Wall_A', -1184, -687, 0, 16384);
	SpawnShipPart(class'Wall_A', -1184, -112, 0, 16384);

	SpawnShipPart(class'Wall_A', -895, -752, 0, 32768);
	SpawnShipPart(class'Wall_A', -1472, -752, 0, 32768);

	SpawnShipPart(class'Wall_A', -1696, 176, 0, 0);
	SpawnShipPart(class'Wall_A', -1120, 176, 0, 0);

	SpawnShipPart(class'Wall_A', -1120, -1264, 0, 0);
	SpawnShipPart(class'Wall_A', -832, -1264, 0, 0);

	SpawnShipPart(class'Wall_A', -1408, -1264, 0, 0);
	SpawnShipPart(class'Wall_A', -1695, -1264, 0, 0);

	SpawnShipPart(class'Wall_A', -608, 688, 0, 32768);
	SpawnShipPart(class'Wall_A', -895, 688, 0, 32768);

	SpawnShipPart(class'Wall_A', -1184, 688, 0, 32768);
	SpawnShipPart(class'Wall_A', -1472, 688, 0, 32768);

	SpawnShipPart(class'BetweenWall_A', -896, -1264, 0, 0);
	SpawnShipPart(class'BetweenWall_A', -1472, -1264, 0, 0);
	SpawnShipPart(class'BetweenWall_A', -832, 688, 0, 32768);
	SpawnShipPart(class'BetweenWall_A', -1408, 688, 0, 32768);

	SpawnShipPart(class'BetweenWall_A', -1120, -976, 0, -16384);
	SpawnShipPart(class'BetweenWall_A', -1696, -976, 0, -16384);
	SpawnShipPart(class'BetweenWall_A', -1184, -1040, 0, 16384);
	SpawnShipPart(class'BetweenWall_A', -1184, -752, 0, 16384);
	SpawnShipPart(class'BetweenWall_A', -608, -1040, 0, 16384);

	SpawnShipPart(class'BetweenWall_A', -1120, 463, 0, -16384);
	SpawnShipPart(class'BetweenWall_A', -1696, 463, 0, -16384);
	SpawnShipPart(class'BetweenWall_A', -1184, 400, 0, 16384);
	SpawnShipPart(class'BetweenWall_A', -1184, 112, 0, 16384);
	SpawnShipPart(class'BetweenWall_A', -608, 400, 0, 16384);

	SpawnShipPart(class'CornerIn_A', -832, -752, 0, 32768);
	SpawnShipPart(class'CornerIn_A', -1408, -752, 0, 32768);
	SpawnShipPart(class'CornerIn_A', -832, -176, 0, 32768);
	SpawnShipPart(class'CornerIn_A', -1408, -176, 0, 32768);

	SpawnShipPart(class'CornerIn_A', -832, 175, 0, -16384);
	SpawnShipPart(class'CornerIn_A', -1408, 175, 0, -16384);

	SpawnShipPart(class'CornerIn_A', -832, -400, 0, -16384);
	SpawnShipPart(class'CornerIn_A', -1408, -400, 0, -16384);

	SpawnShipPart(class'CornerIn_A', -1184, -400, 0, 0);

	SpawnShipPart(class'CornerIn_A', -1184, -176, 0, -49152);


	SpawnShipPart(class'CornerOut_A', -1152, -752, 0, 0);
	SpawnShipPart(class'CornerOut_A', -1728, -752, 0, 0);
	SpawnShipPart(class'CornerOut_A', -1120, -1296, 0, 16384);
	SpawnShipPart(class'CornerOut_A', -1696, -1296, 0, 16384);
	SpawnShipPart(class'CornerOut_A', -1152, -1264, 0, 32768);
	SpawnShipPart(class'CornerOut_A', -576, -1264, 0, 32768);
	SpawnShipPart(class'CornerOut_A', -1120, 144, 0, 16384);
	SpawnShipPart(class'CornerOut_A', -1152, 688, 0, 0);
	SpawnShipPart(class'CornerOut_A', -608, 720, 0, 49152);
	SpawnShipPart(class'CornerOut_A', -1184, 720, 0, 49152);
	SpawnShipPart(class'CornerOut_A', -1728, 688, 0, 0);
	SpawnShipPart(class'CornerOut_A', -1696, 144, 0, 16384);


	SpawnShipPart(class'ShipWeapon', -188,-936,136, 16384, , -16384);
	SpawnShipPart(class'ShipWeapon', -188, 400,136, 16384, , -16384);


	theSeat = Seat(SpawnShipPart(class'Seat', 172, -284, 0, -16384));



	SpawnShipLight(class'ShipLight', 200, -300, 125);
	SpawnShipLight(class'ShipLight', -230, -300, 125);
	SpawnShipLight(class'ShipLight', -715, -300, 125);
	SpawnShipLight(class'ShipLight', -1290, -300, 125);
	SpawnShipLight(class'ShipLight', -1862, -300, 125);
	SpawnShipLight(class'ShipLight', -848, -998, 125);
	SpawnShipLight(class'ShipLight', -1440, -998, 125);
	SpawnShipLight(class'ShipLight', -1440, 425, 125);
	SpawnShipLight(class'ShipLight', -848, 425, 125);

}

DefaultProperties
{
	
	//bHidden = true
}
