class Hallway extends ShipPart;

var Wall TopWallActor, BottomWallActor,
		RightWallActor, LeftWallActor;

var Hallway TopFloorActor, BottomFloorActor, RightFloorActor, LeftFloorActor;

var Rotator ShipRotation, ClosedSectionTopRotation, ClosedSectionBottomRotation
	, TopWallRotation, BottomWallRotation, RightWallRotation, LeftWallRotation;


struct ShipPartSettings{
	var float XOffset;
	var float YOffset;
	var float ZOffset;
	var Rotator Rotation;
};

var ShipPartSettings TopWall;
var ShipPartSettings BottomWall;
var ShipPartSettings RightWall;
var ShipPartSettings LeftWall;
var ShipPartSettings TopFloor;
var ShipPartSettings BottomFloor;
var ShipPartSettings RightFloor;
var ShipPartSettings LeftFloor;

var Vector middleOfFloor;



event PostBeginPlay(){
	
	Super.PostBeginPlay();

	InitializeOffsets();

	middleOfFloor.X = Location.X - 145.392944;
	middleOfFloor.Y = Location.Y + 134.860718;
	middleOfFloor.Z = Location.Z + 51.000183;

	ShipRotation.Pitch = 0;
	ShipRotation.Yaw = 0;
	ShipRotation.Roll = 0;

	ClosedSectionBottomRotation = ShipRotation;
	ClosedSectionTopRotation = ShipRotation;
	ClosedSectionTopRotation.Yaw = 32767;

	TopWallRotation = ShipRotation;
	BottomWallRotation = ShipRotation;
	RightWallRotation = ShipRotation;
	LeftWallRotation = ShipRotation;

	//CreatePilotingControls();

	//SetCollisionType(COLLIDE_NoCollision);
	SetCollisionType(COLLIDE_CustomDefault);
	SMesh.SetRBChannel(RBCC_Untitled1);

	SpawnATestCrewMate();

	CreateTopWall();
	CreateBottomWall();
	CreateRightWall();
	CreateLeftWall();
}

function InitializeOffsets(){
	local Vector X, Y, Z;
	GetAxes(Rotation, X, Y, Z);
	
	TopWall.XOffset = -31.999989;
	TopWall.YOffset = 31.999990;
	TopWall.ZOffset = 0;
	TopWall.Rotation = Rotator(-X);
	
	BottomWall.XOffset = -255.999985;
	BottomWall.YOffset = 255.999985;
	BottomWall.ZOffset = 0;
	BottomWall.Rotation = Rotator(X);
	
	RightWall.XOffset = -31.999990;
	RightWall.YOffset = 255.999969;
	RightWall.ZOffset = 0;
	RightWall.Rotation = Rotator(Y);
	
	LeftWall.XOffset = -255.999985;
	LeftWall.YOffset = 31.999969;
	LeftWall.ZOffset = 0;
	LeftWall.Rotation = Rotator(-Y);

	TopFloor.XOffset = 287.999878;
	TopFloor.YOffset = 0;
	TopFloor.ZOffset = 0;

	BottomFloor.XOffset = -288.000122;
	BottomFloor.YOffset = 0;
	BottomFloor.ZOffset = 0;

	RightFloor.XOffset = 0;
	RightFloor.YOffset = 287.999969;
	RightFloor.ZOffset = 0;

	LeftFloor.XOffset = 0;
	LeftFloor.YOffset = -288.000031;
	LeftFloor.ZOffset = 0;
}

function Vector AdjustWallLocation(name wallSide, Vector theLocation){
	local Vector X, Y, Z;
	GetAxes(Rotation, X, Y, Z);

	switch (wallSide) {
		case 'top':
			theLocation += (X * TopWall.XOffset);
			theLocation += (Y * TopWall.YOffset);
			theLocation += (Z * TopWall.ZOffset);
		break;
  
		case 'bottom':
			theLocation += (X * BottomWall.XOffset);
			theLocation += (Y * BottomWall.YOffset);
			theLocation += (Z * BottomWall.ZOffset);
		break;
  
		case 'right':
			theLocation += (X * RightWall.XOffset);
			theLocation += (Y * RightWall.YOffset);
			theLocation += (Z * RightWall.ZOffset);
		break;

		case 'left':
			theLocation += (X * LeftWall.XOffset);
			theLocation += (Y * LeftWall.YOffset);
			theLocation += (Z * LeftWall.ZOffset);
		break;
		
		default:
	}

	return theLocation;
}

function Vector AdjustFloorLocation(name floorSide, Vector theLocation){
	local Vector X, Y, Z;
	GetAxes(Rotation, X, Y, Z);

	switch (floorSide) {
		case 'top':
			theLocation += (X * TopFloor.XOffset);
			theLocation += (Y * TopFloor.YOffset);
			theLocation += (Z * TopFloor.ZOffset);
		break;
  
		case 'bottom':
			theLocation += (X * BottomFloor.XOffset);
			theLocation += (Y * BottomFloor.YOffset);
			theLocation += (Z * BottomFloor.ZOffset);
		break;
  
		case 'right':
			theLocation += (X * RightFloor.XOffset);
			theLocation += (Y * RightFloor.YOffset);
			theLocation += (Z * RightFloor.ZOffset);
		break;

		case 'left':
			theLocation += (X * LeftFloor.XOffset);
			theLocation += (Y * LeftFloor.YOffset);
			theLocation += (Z * LeftFloor.ZOffset);
		break;
		
		default:
	}

	return theLocation;
}

function SpawnATestCrewMate(){
	local Pawn crewPawn;
	crewPawn = Spawn(class'S_Pawn', , , middleOfFloor);
	crewPawn.SetPhysics(PHYS_Falling);
}

function CreatePilotingControls(){
	local float PilotingControlsXOffset, PilotingControlsYOffset;
	local Vector PilotingControlsLocation;
	local Actor selfActor;
	PilotingControlsYOffset = 161.743073;
	PilotingControlsXOffset = 71.778366;
	PilotingControlsLocation = Location;
	PilotingControlsLocation.X += PilotingControlsXOffset;
	PilotingControlsLocation.Y += PilotingControlsYOffset;
	PilotingControlsActor = Spawn(class'ShipPilotingControls',,, PilotingControlsLocation, Rotation);
	selfActor = self;
	PilotingControlsActor.SetBase(selfActor);
}

function Rotator GetRot(name direction){
	local Vector X, Y, Z;
	GetAxes(Rotation, X, Y, Z);
	
	switch (direction) {
		case 'top':
			return Rotator(Y);
		break;
  
		case 'bottom':
			return Rotator(-Y);
		break;
  
		case 'right':
			return Rotator(-X);
		break;

		case 'left':
			return Rotator(X);
		break;
		
		default:
	}

	return Rotation;
}

function CreateTopFloor(){
	if(TopFloorActor != none)
		TopFloorActor.Destroy();
	TopFloorActor = Spawn(class'Hallway', , , AdjustFloorLocation('top', Location), Rotation);
	TopFloorActor.LastPiece = self;
	TopFloorActor.PawnOwner = PawnOwner;
	TopFloorActor.SetBase(self);
	PawnOwner.ChangeBuildingActor(TopFloorActor);

	if(TopWallActor != none)
		TopWallActor.Destroy();
}
function CreateBottomFloor(){
	if(BottomFloorActor != none)
		BottomFloorActor.Destroy();
	BottomFloorActor = Spawn(class'Hallway', , , AdjustFloorLocation('bottom', Location), Rotation);
	BottomFloorActor.LastPiece = self;
	BottomFloorActor.PawnOwner = PawnOwner;
	BottomFloorActor.SetBase(self);
	PawnOwner.ChangeBuildingActor(BottomFloorActor);

	if(BottomWallActor != none)
		BottomWallActor.Destroy();
}
function CreateRightFloor(){
	if(RightFloorActor != none)
		RightFloorActor.Destroy();
	RightFloorActor = Spawn(class'Hallway', , , AdjustFloorLocation('right', Location), Rotation);
	RightFloorActor.LastPiece = self;
	RightFloorActor.PawnOwner = PawnOwner;
	RightFloorActor.SetBase(self);
	PawnOwner.ChangeBuildingActor(RightFloorActor);

	if(RightWallActor != none)
		RightWallActor.Destroy();
}
function CreateLeftFloor(){
	if(LeftFloorActor != none)
		LeftFloorActor.Destroy();
	LeftFloorActor = Spawn(class'Hallway', , , AdjustFloorLocation('left', Location), Rotation);
	LeftFloorActor.LastPiece = self;
	LeftFloorActor.PawnOwner = PawnOwner;
	LeftFloorActor.SetBase(self);
	PawnOwner.ChangeBuildingActor(LeftFloorActor);

	if(LeftWallActor != none)
		LeftWallActor.Destroy();
}


function CreateTopWall(){
	if(TopWallActor != none)
		TopWallActor.Destroy();
	TopWallActor = Spawn(class'Wall', , , AdjustWallLocation('top', Location), GetRot('top'));
	TopWallActor.FloorActor = self;
	TopWallActor.PawnOwner = PawnOwner;
	TopWallActor.SetBase(self);
	TopWallActor.LastPiece = self;
}
function CreateBottomWall(){
	if(BottomWallActor != none)
		BottomWallActor.Destroy();
	BottomWallActor = Spawn(class'Wall', , , AdjustWallLocation('bottom', Location), GetRot('bottom'));
	BottomWallActor.FloorActor = self;
	BottomWallActor.PawnOwner = PawnOwner;
	BottomWallActor.SetBase(self);
	BottomWallActor.LastPiece = self;
}
function CreateRightWall(){
	if(LeftWallActor != none)
		LeftWallActor.Destroy();
	LeftWallActor = Spawn(class'Wall', , , AdjustWallLocation('right', Location), GetRot('right'));
	LeftWallActor.FloorActor = self;
	LeftWallActor.PawnOwner = PawnOwner;
	LeftWallActor.SetBase(self);
	LeftWallActor.LastPiece = self;
}
function CreateLeftWall(){
	if(RightWallActor != none)
		RightWallActor.Destroy();
	RightWallActor = Spawn(class'Wall', , , AdjustWallLocation('left', Location), GetRot('left'));
	RightWallActor.FloorActor = self;
	RightWallActor.PawnOwner = PawnOwner;
	RightWallActor.SetBase(self);
	RightWallActor.LastPiece = self;
}

DefaultProperties
{
	TopWallActor=none
	BottomWallActor=none
	RightWallActor=none
	LeftWallActor=none

	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'Placeholders.Meshes.CorridorA_18BLOCK'
	End Object
}
