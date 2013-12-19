class S_Pawn extends UTPawn;

var Vector GravityDirection;

var Rotator savedRot;//A saved Rotation... used to keep facing in a direction when editing character

/** The maximum velocity...*/
var float velocityLimit;

var float CamHeight; //how high cam is relative to pawn pelvis
var float CamDistance;
var float CamYOffset;

var StaticMeshComponent CustomCollision;

var SVehicle VehicleActor;

var AnimNodeBlend DriveBlend;

var SpotLightComponent MyLight;

/**Same as location.... */
var Vector theLocation;

/** distance to offset the camera from the player*/
var float CamOffsetDistance;

/** pitch angle of the camera*/
var int IsoCamAngle;

/** if true, then in WorldView(topDown)*/
var bool bWorldView;

var bool bFixedCam;

var bool bIsBot;

var bool bSprinting;
var bool bPressingJump;
var bool bDrivingShip;

var bool bAllowNextMelee;
var bool bPlayingMelee;

var bool bExperiencingGravity;
var bool bOldExperiencingGravity;

var bool bGravityOn;

/** bool is used to disable pawn turning for editing your character*/
var bool bEditingCharacter;

/** bool is changed by SetJetPackActive(); This way, Tick won't call SetJetPackActive twice for the same result, and also cause sound glitches
	by making the jetpack sound go off over and over.*/
var bool bJetPackOn;

var bool bAllowFootStepSound;//So that we don't get two footstep sounds super quick, due to blending animations, both wanting to trigger the sound

var repnotify float theAcceleration;

var bool bAiming;

var bool bAllowJump;

var ShipPart BuildingActor;
var Ship ShipActor;

var bool    bPressingForwards;
var bool    bPressingBackwards;

var bool    bPressingShipTurnRight;
var bool    bPressingShipTurnLeft;

var bool    bJetPackActive;

var bool    bFlashLightEnabled;

var bool    bPressingRollRight, bPressingRollLeft;

/** S: Whether Player is currently strafing Left or Right*/
var bool bStrafingRight, bStrafingLeft;

/** S: By how much the pawns groundspeed is multiplied by when sprinting (Default 5.5)
 *  */
var float SprintSpeedMultiplier;

var SoundCue footstepsound;

// Slot nodes used for playing torso and arm animations that have been customised to support mirroring.
var SAnimNodeSlotMirror FullAnimSlot, RightArmAnimSlot, LeftArmAnimSlot, ArmsAnimSlot, TorsoAnimSlot, HeadAnimSlot, TheCurrentAnimNodeSlot;

//REPLICATED ANIMATION PROPERTIES TO CLIENTS

struct RepAnim
{
	var SAnimNodeSlotMirror RAnimSlots;
	var name RAnimName;
	var float RRateOrDuration;
	var bool bRDuration;
	var bool bRMirror;
	var float RBlendInTime;
	var float RBlendOutTime;
	var bool bRLooping;
	var bool bROverride;
	var float RStartTime;
	var float REndTime;
	var bool bRToggleAnim;
	var S_Pawn RAnimPawn;
};

struct StopRepAnim
{
	var SAnimNodeSlotMirror RStopAnimSlots;
	var float RBlendOutTime;
	var bool RStopToggleAnim;
	var S_Pawn RStopAnimPawn;
};

var bool LeftArmSlotsPlaying, RightArmSlotsPlaying, TorsoSlotsPlaying, HeadSlotsPlaying, ArmsSlotsPlaying;

var repnotify RepAnim CustomAnimReplication;
var repnotify StopRepAnim StopCustomAnimReplication;


replication{
	// replicated properties
	if (bNetDirty)
		theAcceleration;
}

simulated function PostBeginPlay(){

	Super.PostBeginPlay();

	SetPhysics(PHYS_Falling);

	HandleWeaponAnims();

	//Mesh.AttachComponentToSocket(CustomCollision, 'Waist1_Socket');
	//CustomCollision.SetHidden(true);

}

simulated function SetCustomCollisionRBChannels(bool bRagdollMode)
{
	if(bRagdollMode)
	{
		CustomCollision.SetRBChannel(RBCC_Pawn);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
	}
	else
	{
		CustomCollision.SetRBChannel(RBCC_Untitled3);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Default,FALSE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
		CustomCollision.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
	}
}

function AddDefaultInventory()
{

}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh){
		LeftArmAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('LeftArmSlot'));
		RightArmAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('RightArmSlot'));
		TorsoAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('TorsoSlot'));
		ArmsAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('ArmsSlot'));
		HeadAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('HeadSlot'));

		FullAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('FullSlot'));

		DriveBlend = AnimNodeBlend(Mesh.FindAnimNode('DriveBlend'));
	}
}

simulated function PlaySlotAnims(SAnimNodeSlotMirror AnimSlots, name AnimName, float	RateOrDuration, optional bool bDuration = false, optional bool bMirror, optional	float	BlendInTime, optional	float	BlendOutTime,	optional	bool	bLooping, optional bool	bOverride, optional float StartTime, optional float EndTime)
{
	local RepAnim NewRepAnim;

	if (AnimSlots.NodeName == 'LeftArmSlot')
		LeftArmSlotsPlaying = true;
	else if (AnimSlots.NodeName == 'RightArmSlot')
		RightArmSlotsPlaying = true;
	else if (AnimSlots.NodeName == 'TorsoSlot')
		TorsoSlotsPlaying = true;
	else if (AnimSlots.NodeName == 'ArmsSlot')
		ArmsSlotsPlaying = true;
	else if (AnimSlots.NodeName == 'HeadSlot')
		HeadSlotsPlaying = true;

	//CLIENT REPLICATION INFO
	NewRepAnim.RAnimSlots=AnimSlots;
	NewRepAnim.RAnimName=AnimName;
	NewRepAnim.RRateOrDuration=RateOrDuration;
	NewRepAnim.bRDuration=bDuration;
	NewRepAnim.bRMirror=bMirror;
	NewRepAnim.RBlendInTime=BlendInTime;
	NewRepAnim.RBlendOutTime=BlendOutTime;
	NewRepAnim.bRLooping=bLooping;
	NewRepAnim.bROverride=bOverride;
	NewRepAnim.RStartTime=StartTime;
	NewRepAnim.REndTime=EndTime;
	NewRepAnim.bRToggleAnim = !CustomAnimReplication.bRToggleAnim;
	NewRepAnim.RAnimPawn = self;
	CustomAnimReplication=NewRepAnim;//This is the repnotify struct, will play the animation for all the clients

	// go through all the slot nodes
	if (bDuration)
		AnimSlots.PlayCustomMirrorAnimByDuration(AnimName,RateOrDuration,bMirror,BlendInTime,BlendOutTime,bLooping,bOverride);
	else
		AnimSlots.PlayCustomMirrorAnim(AnimName,RateOrDuration,bMirror,BlendInTime,BlendOutTime,bLooping,bOverride,StartTime,EndTime);

	//if(Role < ROLE_Authority)
		//ServerPlaySlotAnims(AnimSlots, AnimName, RateOrDuration, bDuration, bMirror, BlendInTime, BlendOutTime, bLooping, bOverride, StartTime, EndTime);
}

simulated function StopPlaySlotAnims(SAnimNodeSlotMirror AnimSlots, optional float BlendOutTime = 0)
{
	local StopRepAnim NewStopRepAnim;

	if (AnimSlots.NodeName == 'LeftArmSlot')
		LeftArmSlotsPlaying = false;
	else if (AnimSlots.NodeName == 'RightArmSlot')
		RightArmSlotsPlaying = false;
	else if (AnimSlots.NodeName == 'TorsoSlot')
		TorsoSlotsPlaying = false;
	else if (AnimSlots.NodeName == 'ArmsSlot')
		ArmsSlotsPlaying = false;
	else if (AnimSlots.NodeName == 'HeadSlot')
		HeadSlotsPlaying = false;
		
	//CLIENT REPLICATION INFO
	NewStopRepAnim.RStopAnimSlots=AnimSlots;
	NewStopRepAnim.RBlendOutTime=BlendOutTime;
	NewStopRepAnim.RStopAnimPawn = self;
	NewStopRepAnim.RStopToggleAnim=!StopCustomAnimReplication.RStopToggleAnim;
	StopCustomAnimReplication=NewStopRepAnim;//This is the repnotify struct, will play the animation for all the clients

	// go through all the slot nodes
	AnimSlots.StopCustomAnim(BlendOutTime);

	//if(Role < ROLE_Authority)
		//ServerStopPlaySlotAnims(AnimSlots, BlendOutTime);
}

function PlayFootStepRight(){
	PlayFootStepSound(0);
}

function PlayFootStepLeft(){
	PlayFootStepSound(1);
}

function PlayLandingSound(){
	
	//Super.PlayLandingSound();
}

function RealPlayLandingSound(){
	
	Super.PlayLandingSound();
}

simulated function PlayFootStepSound(int FootDown){
	//if(bAllowFootStepSound){
		//bAllowFootStepSound=false;
		PlaySound(footstepsound);
		//SetTimer(0.3, false, 'AllowFootStepSound');
		//ClientMessage("FOOTSTEP SOUND!!");
	//}
}

function AllowFootStepSound(){
	bAllowFootStepSound = true;
}

simulated function SetWeapAnimType(EWeapAnimType AnimType)
{
	ClientMessage("SetWeapAnimType()");
	HandleWeaponAnims();
}

simulated function HandleWeaponAnims()
{
	if(SWeapon(Weapon) != none){
		PlaySlotAnims(ArmsAnimSlot, SWeapon(Weapon).HoldAnim, 3, true,,0.2,0.2,true);
		ClientMessage("Found SWeapon: HandleWeaponAnims()");
	}
	else
		StopPlaySlotAnims(ArmsAnimSlot, 0.2);
}

function SetBuildingMode(bool bBuildingMode){
	if(bBuildingMode)
		BuildingActor.StartGlow();
	else
		BuildingActor.StopGlow();
}

function ChangeBuildingActor(ShipPart newBuildingActor){
	if(newBuildingActor != none){
		BuildingActor.StopGlow();
		BuildingActor = newBuildingActor;
		BuildingActor.StartGlow();
	}
}

exec function CreateFriend(){
	local Pawn tempPawn;
	local SControllerBot tempBot;
	local Vector X, Y, Z;

	GetAxes(Rotation, X, Y, Z);

	tempPawn = Spawn(class'SPlayer_Pawn', , , Location + X*100);
	if(tempPawn != none){
		tempPawn.Controller = Spawn(class'SControllerBot');
		if ( tempPawn.Controller != None )
		{
			tempPawn.Controller.Possess( tempPawn, false );
			tempBot = SControllerBot(tempPawn.Controller);
			tempBot.SetTarget(self, Location);
		}
	}
}

exec function CreateHelper(){
	local Pawn tempPawn;
	local SBot tempBot;
	local Vector X, Y, Z;

	GetAxes(Rotation, X, Y, Z);

	tempPawn = Spawn(class'RoboHelper_Pawn', , , Location + X*50);
	if(tempPawn != none){
		tempBot = Spawn(class'SBot', , , tempPawn.Location, tempPawn.Rotation);
		tempBot.Target = self;
		tempBot.Possess(tempPawn, false);
	}
}

exec function CreateRock(){
	local Vector X, Y, Z;

	GetAxes(Rotation, X, Y, Z);

	Spawn(class'SPushableObject', , , Location + X*50);
}

exec function SpawnRocks(int spawnAmount)
{
	ServerSpawnRocks(spawnAmount);
}

reliable server function ServerSpawnRocks(int spawnAmount)
{
	local int i, j;
	local Actor tempRock;
	local Vector spawnLoc, randVel, tempVec;
	local Rotator spawnRot;
	local StaticMeshComponent RockMesh;

	i =0;
	while(i < spawnAmount){
		i++;
		
		spawnRot = GetRandomRotation();
		spawnLoc = GetRandomLocation(100000);
		tempRock = Spawn(class'SPushableObject', , , spawnLoc, spawnRot);
		SPushableObject(tempRock).TheKActor.SetDrawScale(Rand(100));
		RockMesh = SPushableObject(tempRock).TheKActor.theMesh;

		j = Rand(30);
		if(j < 7){
			randVel = GetRandomVelocity(40);
			//tempVec = GetRandomLocation(50, 0);
			tempVec = tempRock.Location;
			SPushableObject(tempRock).TheKActor.theMesh.AddForce(randVel, tempVec);
			randVel = GetRandomVelocity(2000);
			SPushableObject(tempRock).TheKActor.theMesh.AddForce(randVel);
		}
	}
}

function Rotator GetRandomRotation(){
	local Rotator randomRot;
	local float randYawOffset, randRollOffset, randPitchOffset;

	randYawOffset = Rand(65536);
	randRollOffset = Rand(65536);
	randPitchOffset = Rand(65536);
	
	randomRot.Yaw = randYawOffset;
	randomRot.Roll = randRollOffset;
	randomRot.Pitch = randPitchOffset;

	return randomRot;
}

function Vector GetRandomVelocity(float MaxVel){
	local Vector tempVel;
	local float randXOffset, randYOffset, randZOffset;
	local int tempRand;

	randXOffset = Rand(MaxVel);
	randYOffset = Rand(MaxVel);
	randZOffset = Rand(MaxVel);

	tempRand = Rand(2);
	if(tempRand == 0)
		randXOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randYOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randZOffset *= -1;

	tempVel.X = randXOffset;
	tempVel.Y = randYOffset;
	tempVel.Z = randZOffset;

	return tempVel;
}

simulated function Vector GetRandomLocation(int MaxXandYDistance, optional int MinXandYDistance)
{
	local Vector randomLoc;
	local float randXOffset, randYOffset, randZOffset, tempRand;

	if(MinXandYDistance > 0 || MinXandYDistance < 0){
		randomLoc.X = MinXandYDistance;
		randomLoc.Y = MinXandYDistance;
		randomLoc.Z = MinXandYDistance;
	}else{
		randomLoc.X = 0;
		randomLoc.Y = 0;
		randomLoc.Z = 0;
	}

	randXOffset += Rand(MaxXandYDistance);
	randYOffset += Rand(MaxXandYDistance);
	randZOffset += Rand(MaxXandYDistance);

	tempRand = Rand(2);
	if(tempRand == 0)
		randXOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randYOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randZOffset *= -1;

	randomLoc.X += randXOffset;
	randomLoc.Y += randYOffset;
	randomLoc.Z += randZOffset;

	return randomLoc;
}

exec function CreateCockpit(){
	local Rotator ShipRotation;
	local Vector ShipLocation;
	local Ship tempShipActor;

	//ShipLocation.X = 0;
	//ShipLocation.Y = 0;
	//ShipLocation.Z = 0;//1280.000000;
	
	ShipLocation = Location;
	ShipLocation.Z += 150;

	ShipRotation.Pitch =0;
	ShipRotation.Yaw = 0;
	ShipRotation.Roll = 0;
    
	tempShipActor = Spawn(class'TestShip', , , ShipLocation, ShipRotation);
	SetShipActor(tempShipActor);
	BuildingActor = tempShipActor;
	BuildingActor.PawnOwner = self;
	SetBuildingMode(true);
}

exec function CreateShip(){
	local Rotator ShipRotation;
	local Vector ShipLocation;

	ShipLocation.X = 0;
	ShipLocation.Y = 0;
	ShipLocation.Z = 0;//1280.000000;
	//ShipLocation.Z -= 150;

	ShipRotation.Pitch =0;
	ShipRotation.Yaw = 0;
	ShipRotation.Roll = 0;
    
	BuildingActor = Spawn(class'Hallway', , , ShipLocation, ShipRotation);
	BuildingActor.PawnOwner = self;
	SetBuildingMode(true);
}

exec function SpawnTopWall(){
	Hallway(BuildingActor).CreateTopWall();
}
exec function SpawnBottomWall(){
	Hallway(BuildingActor).CreateBottomWall();
}
exec function SpawnRightWall(){
	Hallway(BuildingActor).CreateRightWall();
}
exec function SpawnLeftWall(){
	Hallway(BuildingActor).CreateLeftWall();
}

exec function SpawnTopFloor(){
	Hallway(BuildingActor).CreateTopFloor();
}
exec function SpawnBottomFloor(){
	Hallway(BuildingActor).CreateBottomFloor();
}
exec function SpawnRightFloor(){
	Hallway(BuildingActor).CreateRightFloor();
}
exec function SpawnLeftFloor(){
	Hallway(BuildingActor).CreateLeftFloor();
}

exec function StartBuildingMode(){
	SetBuildingMode(true);
}
exec function EndBuilding(){
	SetBuildingMode(false);
}

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         SetMeshVisibility(UTPC.bBehindView); 
         UTPC.bNoCrosshair = true;
      }
   }
}

function AddVel(int Axis, float Amount, float DeltaTime){
	local Vector tempVel, X, Y, Z;
	local Rotator tempRot;
	tempVel = Velocity;
	
	tempRot = Controller.Rotation;

	if(bExperiencingGravity){
		tempRot.Pitch = 0;
		GetAxes(tempRot, X, Y, Z);
	}
	else
		GetAxes(tempRot, X, Y, Z);

	if(Axis == 0)
		tempVel += Amount * X  * DeltaTime;
	else if(Axis == 1)
		tempVel += Amount * Y  * DeltaTime;
	else
		tempVel += Amount * Z  * DeltaTime;

	Velocity = tempVel;
}

function bool CheckIfInShip(){
	local Vector WaistLoc, HitLoc, HitNormal, TraceEndTop, TraceEndBot, X, Y, Z;
	local Rotator WaistRot;
	local Actor TracedActor1, TracedActor2;
	local float Orientation;
	local bool bTopHit, bBotHit;

	bTopHit = false;
	bBotHit = false;

	Mesh.GetSocketWorldLocationAndRotation('Waist1_Socket', WaistLoc, WaistRot);
	TraceEndTop = WaistLoc;
	TraceEndBot = WaistLoc;
	TraceEndTop.Z += 500;
	TraceEndBot.Z -= 500;
	//DrawDebugLine(TraceEndTop, TraceEndBot, 0, 1, 0);
	TracedActor1 = Trace(HitLoc, HitNormal, TraceEndTop, WaistLoc);
	if(TracedActor1 != none && TracedActor1.IsA('ShipPart') && ShipPart(TracedActor1).ShipOwner != none){
		bTopHit = true;
		//ClientMessage("HitTop!!!");
	}
	TracedActor2 = Trace(HitLoc, HitNormal, TraceEndBot, WaistLoc);
	if(TracedActor2 != none && TracedActor2.IsA('ShipPart') && ShipPart(TracedActor2).ShipOwner != none){
		bBotHit = true;
		//ClientMessage("HitBottom!!!");
	}
	if(bTopHit && bBotHit && ShipPart(TracedActor1).ShipOwner == ShipPart(TracedActor2).ShipOwner){//Make sure that both traces hit and that both actors that got hit belong to the same ship
		SetShipActor(ShipPart(TracedActor1).ShipOwner);
		
		//bHardAttach = true;
		//self.SetBase(TracedActor1);//Attach pawn to the ship so that when the ship moves we move with it
		//SetCollision(false);

		GetAxes(Rotation, X, Y, Z);
		Orientation = -Z dot GravityDirection;
		if(Orientation > 0){
			//ClientMessage("Oriented to Gravity!");
			if(GetDistance(HitLoc) < 60 && !bPlayingMelee && !bPressingJump)// && !OldbLanded)
				SetPhysics(PHYS_Walking);
		}
		if(Base != ShipActor){
			//ClientMessage("Found New Base!");
			SetBase(ShipActor);
		}

		return true;
	}else{
		//ClientMessage("Getting rid of old base!");
		ShipActor.Detach(self);
	}

	//ShipActor.Detach(self);


	//orientation = A dot B;
  // > 0.0  A points forwards in relation to B (up to 90� apart)
  // = 0.0  A is perpendicular to B (exactly 90� between A and B)
  // < 0.0  A points backwards in relation to B (more than 90� apart)

	return false;
}

function SetShipActor(Ship newShipActor){
	if(ShipActor != newShipActor){
		ShipActor = newShipActor;
	}
}

function float GetDistance(Vector OtherLocation){
	local float Distance;

	Distance = VSize(Location - OtherLocation);
	//ClientMessage(Distance);
   return Distance;
}

function bool HandleMovement(float DeltaTime){//Returns true if jetpack should be one when moving
	local float movementSpeed;
	local bool bMoved, bWalking;

	bWalking = false;

	//if(/*bExperiencingGravity && */Physics != PHYS_Falling){
	if(bExperiencingGravity && Physics==PHYS_Walking){//
		//ClientMessage("We walking baby");
		bWalking = true;

		movementSpeed = 80000;
		if(bSprinting)
			movementSpeed = 160000;
		if(bExperiencingGravity)
			movementSpeed += 20;
	}
	else
		movementSpeed = 200;

	bMoved = false;

	if(!bDrivingShip && !bEditingCharacter){
		if(bPressingForwards){
			AddVel(0, movementSpeed, DeltaTime);
			bMoved = true;
		}
		if(bPressingBackwards){
			AddVel(0, -movementSpeed, DeltaTime);
			bMoved = true;
		}
		if(bStrafingLeft){
			AddVel(1, -movementSpeed, DeltaTime);
			bMoved = true;
		}
		if(bStrafingRight){
			AddVel(1, movementSpeed, DeltaTime);
			bMoved = true;
		}
		if(bPressingJump){
			AddVel(2, movementSpeed, DeltaTime);
			bMoved = true;
		}
		if(bPlayingMelee && !bAllowNextMelee)
			return true;

		if(bMoved && !bWalking && !bDrivingShip)
			return true;
	}
	
	return false;
}

function LimitVel(){
	local float magnitude;
	local Vector tempVel;
	
	magnitude = Sqrt(Square(Velocity.X) + Square(Velocity.Y) + Square(Velocity.Z));

	if(magnitude > velocityLimit){
		tempVel = Velocity/magnitude;
		Velocity = tempVel * VelocityLimit;
	}
	//ClientMessage(magnitude);
}

simulated event Tick(float DeltaTime)
{
	local Vector tempVel, tempLoc;
	local Rotator tempRot, tempRot2;
	local Vector pawnX, pawnY, pawnZ;
	local float TurnDifference;

	Super.Tick(DeltaTime);

	//GravityDirection = vect(0, 0, -1);

	if(CheckIfInShip() && ShipActor.bGravityOn && ShipActor.bPowerOn){
		//Can't use AddVel because I need Gravity Axis
		
		tempVel = Velocity;
		tempVel += GravityDirection * 1000 * DeltaTime;
		//tempVel.Z -= 10;
		Velocity = tempVel;
		bExperiencingGravity = true;
		
		ViewPitchMin = default.ViewPitchMin;
		ViewPitchMax = default.ViewPitchMax;

		//WalkableFloorZ = default.WalkableFloorZ;
	}else{
		if(Physics == PHYS_Walking)
			SetPhysics(PHYS_Falling);

		bExperiencingGravity = false;

		bOldExperiencingGravity = bExperiencingGravity;

		//SetPhysics(PHYS_Falling);

		//WalkingPhysics=PHYS_Falling;
		//LandMovementState='PlayerFalling';
		
		//WalkableFloorZ = 1;//Slide smoothly on ground when no gravity

		ViewPitchMin = -32768;
		ViewPitchMax = 32768;
	}

	SetJetpackActive(HandleMovement(DeltaTime));//Turning on jetpack effects if handle movement says that we should
										//This will also run HandleMovement for every tick :)

	CalcAcceleration();

	GetAxes(Rotation, pawnX, pawnY, pawnZ);

	if(bDrivingShip && ShipActor != none && ShipActor.bPowerOn){
		if(bJetPackOn)
			SetJetpackActive(false);
		
		tempVel.X = 0; tempVel.Y = 0; tempVel.Z = 0;
		Velocity = tempVel;
		if(bPressingForwards){
			tempVel = ShipActor.Location + (pawnX * 1500 * DeltaTime);
			ShipActor.SetLocation(tempVel);
			tempLoc = Location + (pawnX * 1500  * DeltaTime);
		}else if(bPressingBackwards){
			tempVel = ShipActor.Location - (pawnX * 1500 * DeltaTime);
			ShipActor.SetLocation(tempVel);
		}
			//ShipActor.Velocity = ShipActor.Velocity + pawnX *15;
			//SetLocation(tempLoc);
	
		if(bPressingShipTurnRight){
			tempRot = ShipActor.Rotation;
			TurnDifference = 5000;
			tempRot.Yaw += TurnDifference * DeltaTime;
			ShipActor.SetRotation(tempRot);
		}
		else if(bPressingShipTurnLeft){
			tempRot = ShipActor.Rotation;
			TurnDifference = -5000;
			tempRot.Yaw += TurnDifference * DeltaTime;
			ShipActor.SetRotation(tempRot);
		}
		//tempRot = Rotation;
		//tempRot.Yaw += TurnDifference;
		//SetRotation(tempRot);
		tempRot = ShipActor.Rotation;
		//tempRot.Yaw += 16384;
		SetRotation(tempRot);
	}

	if(!bExperiencingGravity && !bDrivingShip){
		if(bPressingRollRight){
			tempRot = Controller.Rotation;
			tempRot.Roll += 5000  * DeltaTime;
			Controller.SetRotation(tempRot);
		}
		else if(bPressingRollLeft){
			tempRot = Controller.Rotation;
			tempRot.Roll -= 5000  * DeltaTime;
			Controller.SetRotation(tempRot);
		}

		//SetRotation(Controller.Rotation);
	}else{
		
		tempRot = Controller.Rotation;
		tempRot.Roll = 0;
		Controller.SetRotation(tempRot);
		tempRot2 = Rotation;
		tempRot2.Roll = 0;
		tempRot2.Pitch = 0;
		SetRotation(tempRot2);
	}

/*
	if(bExperiencingGravity && Velocity.Z < 0){
		if(Location.Z < theLocation.Z){//then we are still falling

		}else{//We landed.... assuming ground isn't slanted?...
			bLanded = true;
		}
	}*/

	theLocation = Location;

	LimitVel();
}

state WorldView{
	
	simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV ){
	   out_CamLoc = Location;
	   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
	   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

	   out_CamRot.Pitch = -1 * IsoCamAngle;   
	   out_CamRot.Yaw = 0;
	   out_CamRot.Roll = 0;

		return true;
	}

}

////////////////////////NEW CUSTOM 3rd PErson Camera STUFF

//orbit cam, follows player controller rotation
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector HitLoc,HitNorm, End, Start, vecCamHeight, X, Y, Z;

	GetAxes(Controller.Rotation, X, Y, Z);

	vecCamHeight = vect(0,0,0);
	vecCamHeight += CamHeight*Z;
	vecCamHeight += CamYOffset*Y;

	Start = Location;
	End = (Location+vecCamHeight)-(Vector(Controller.Rotation) * CamDistance);  //cam follow behind player controller
	out_CamLoc = End;

	//trace to check if cam running into wall/floor
	if(Trace(HitLoc,HitNorm,End,Start,false,vect(12,12,12))!=none)
	{
		out_CamLoc = HitLoc;// + vecCamHeight;
	}
	
	//camera will look slightly above player
   //out_CamRot=rotator((Location + vecCamHeight) - out_CamLoc);
   return true;
}
/*
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset;
   local float DesiredCameraZOffset;


   CamStart = Location;
   CurrentCamOffset = CamOffset;

   DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
   CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
   
   if ( Health <= 0 )
   {
      CurrentCamOffset = vect(0,0,0);
      CurrentCamOffset.X = GetCollisionRadius();
   }

   CamStart.Z += CameraZOffset;
   GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
   CamDirX *= CurrentCameraScale;

   if ( (Health <= 0) || bFeigningDeath )
   {
      // adjust camera position to make sure it's not clipping into world
      // @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
      FindSpot(GetCollisionExtent(),CamStart);
   }
   if (CurrentCameraScale < CameraScale)
   {
      CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
   }
   else if (CurrentCameraScale > CameraScale)
   {
      CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
   }

   if (CamDirX.Z > GetCollisionHeight())
   {
      CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
   }

   out_CamLoc = CamStart - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;

   if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
   {
      out_CamLoc = HitLocation;
   }

   return true;
}*/

simulated event Vector GetPawnViewLocation(){
	/*	if ( bUpdateEyeHeight )
		return Location + EyeHeight * vect(0,0,1) + WalkBob;
	else
		return Location + BaseEyeHeight * vect(0,0,1);*/

	return Mesh.GetBoneLocation('Bip001-Head');
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	// Add Delta Rotation
	//out_ViewRotation	+= out_DeltaRot;
	out_ViewRotation.Yaw += out_DeltaRot.Yaw;
	out_ViewRotation.Pitch += out_DeltaRot.Pitch;
	out_ViewRotation.Roll += out_DeltaRot.Roll;

	out_DeltaRot		 = rot(0,0,0);

	// Limit Player View Pitch
	if ( PlayerController(Controller) != None )
	{
		out_ViewRotation = PlayerController(Controller).LimitViewRotation( out_ViewRotation, ViewPitchMin, ViewPitchMax );
	}
}


///////////////////////////////////////////////////////////

/*
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   out_CamLoc = Location;
   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

   out_CamRot.Pitch = -1 * IsoCamAngle;   
   out_CamRot.Yaw = 0;
   out_CamRot.Roll = 0;

   return true;
}

simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0;

   return POVRot;
}   */

function bool CheckMoving()//Checks to see if you are moving or not
{
	return (Vsize(Velocity) != 0); 
}

exec function ToggleSelfGravity(){
	bGravityOn = !bGravityOn;
}

simulated function StartJump(){
	SetPhysics(PHYS_Falling);
	Velocity += GravityDirection * -300;
}

simulated function AllowJump()
{
	bAllowJump = true;
}

function SetJetpackActive(bool bActive){
	bJetPackOn=bActive;
}

function SetDriveShip(bool bDriving){
	bDrivingShip = bDriving;
	if(bDriving){
		DriveBlend.SetBlendTarget(1, 0.5);
		SController(Controller).GotoState('PlayerDriving');
	}
	else{
		DriveBlend.SetBlendTarget(0, 0.5);
		Controller.GotoState('PlayerWalking');
		SetPhysics(PHYS_Falling);
	}
}

exec function ToggleDriveShip(){
	SetDriveShip(!bDrivingShip);
}

function SetEditingCharacter(bool bEdit){
	bEditingCharacter = bEdit;
	if(bEditingCharacter){
		SController(Controller).GotoState('PlayerDriving');
		savedRot = Rotation;
	}
	else
		SController(Controller).GotoState('PlayerWalking');
}

exec function ToggleEditCharacter(){
	SetEditingCharacter(!bEditingCharacter);
}

//////// FUNCTIONS THAT HANDLE BOOLS FOR HOLDING BUTTONS!!!!////////////

exec function PressRollRight(){
	bPressingRollRight = true;
}

exec function StopPressRollRight(){
	bPressingRollRight = false;
}

exec function PressRollLeft(){
	bPressingRollLeft = true;
}

exec function StopPressRollLeft(){
	bPressingRollLeft = false;
}

exec function PressJump()
{
	bPressingJump = true;
	
	if(Physics == PHYS_Falling || Physics == PHYS_Flying)
		ActivateJetPack();
	else if(bExperiencingGravity && Physics == PHYS_Walking)
		StartJump();

	/*
	else if(bAllowJump)
	{
		StartJump();

		bAllowJump = false;
		if(Physics == PHYS_Falling)
			ActivateJetPack();
		else
			SetTimer(0.2, false, 'ActivateJetPack');
	}*/
}

event Landed(vector HitNormal, actor FloorActor){
	/*if(bExperiencingGravity){
		super.Landed(HitNormal, FloorActor);
		StopPressJump();
		AllowJump();
		if(bJetPackOn)
			SetJetPackActive(false);

		if(Velocity.Z < -300)
			RealPlayLandingSound();
	}*/

	if(bExperiencingGravity){
		ClientMessage("LANDED!");
		AllowJump();
	}
}

exec function StopPressJump(){
	bPressingJump = false;
	bJetPackActive = false;
}

function ActivateJetPack(){
	if(bPressingJump)
		bJetPackActive = true;
}

exec function PressWorldView(){
	bWorldView = !bWorldView;
	if(bWorldView){
		GotoState('WorldView');
		//SController(Controller).GotoState('WorldView');
	}
	else
		GotoState('PlayerWalking');
		//SController(Controller).GotoState('PlayerWalking');
}

function DropToGround(){
	if(bExperiencingGravity || bDrivingShip)
		Super.DropToGround();
}

exec function PressShipTurnRight(){
	SetPressShipTurnRight(true);
}

simulated function SetPressShipTurnRight(bool bTurnRight)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressShipTurnRight(bTurnRight);
	}

	bPressingShipTurnRight = bTurnRight;
}

exec function StopPressShipTurnRight(){
	SetPressShipTurnRight(false);
}

reliable server function ServerSetPressShipTurnRight(bool bTurnRight)
{
	bPressingShipTurnRight = bTurnRight;
}

exec function PressShipTurnLeft(){
	SetPressShipTurnLeft(true);
}

simulated function SetPressShipTurnLeft(bool bTurnLeft)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressShipTurnLeft(bTurnLeft);
	}

	bPressingShipTurnLeft = bTurnLeft;
}

exec function StopPressShipTurnLeft(){
	SetPressShipTurnLeft(false);
}

reliable server function ServerSetPressShipTurnLeft(bool bTurnLeft)
{
	bPressingShipTurnLeft = bTurnLeft;
}

exec function PressForwards(){
	SetPressForwards(true);
}

simulated function SetPressForwards(bool bForwards)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressForwards(bForwards);
	}

	bPressingForwards = bForwards;
}

reliable server function ServerSetPressForwards(bool bForwards)
{
	bPressingForwards = bForwards;
}

exec function StopPressForwards()
{
	SetPressForwards(false);
}

exec function PressBackwards()
{
	SetPressBackwards(true);
}

simulated function SetPressBackwards(bool bBackwards)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressBackwards(bBackwards);
	}

	bPressingBackwards = bBackwards;
}

reliable server function ServerSetPressBackwards(bool bBackwards)
{
	bPressingBackwards = bBackwards;
}

exec function StopPressBackwards()
{
	SetPressBackwards(false);
}

exec function StrafeLookLeft()
{
	SetStrafeLeft(true);
}

simulated function SetStrafeLeft(bool bStrafeLeft)
{
	if(Role < ROLE_Authority)
	{
		ServerSetStrafeLeft(bStrafeLeft);
	}
	bStrafingLeft = bStrafeLeft;
}

reliable server function ServerSetStrafeLeft(bool bStrafeLeft)
{
	bStrafingLeft = bStrafeLeft;
}

exec function StopStrafeLeft()
{
	SetStrafeLeft(false);
}

exec function StrafeLookRight()
{
	SetStrafeRight(true);
}

exec function SetCameraOffsetDistance(float OffsetDistance)
{
	CamOffsetDistance = OffsetDistance;
}

simulated function SetStrafeRight(bool bStrafeRight)
{
	if(Role < ROLE_Authority)
	{
		ServerSetStrafeRight(bStrafeRight);
	}
	bStrafingRight = bStrafeRight;
}

reliable server function ServerSetStrafeRight(bool bStrafeRight)
{
	bStrafingRight = bStrafeRight;
}

exec function StopStrafeRight()
{
	SetStrafeRight(false);
}

///////////////////////////////////////////////////////
//////////////////////////////////////////////////////

exec function ToggleFixedCam(){
	bFixedCam = !bFixedCam;
}

simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
if(bDrivingShip || bEditingCharacter){
		
	}else if(bFixedCam){
		Super.FaceRotation(NewRotation, DeltaTime);
		return;
	}else if(bPressingForwards || bAiming || bPlayingMelee){
		NewRotation = rotator((Location + Normal(Velocity))-Location);
		//NewRotation.Pitch = 0;
			
		if(bSprinting)
			SetRotation(RInterpTo(Rotation, NewRotation, DeltaTime, 40000, true));
		else if(bAiming)
			SetRotation(RInterpTo(Rotation, NewRotation, DeltaTime, 90000, true));
		else
			SetRotation(RInterpTo(Rotation, NewRotation, DeltaTime, 30000, true));
	}
}

simulated function CalcAcceleration()
{
	local int speedMax;

	if(CheckMoving())
	{
		if(bSprinting && !bPressingBackwards && !bStrafingRight && !bStrafingLeft)
		{
			speedMax = default.GroundSpeed * SprintSpeedMultiplier;
		}
		else
		{
			speedMax = default.GroundSpeed;
		}
		
		if((theAcceleration + 10) < speedMax)
		{
			theAcceleration += 10;
		}
		else
		{
			theAcceleration = speedMax;
		}
	}
	else
	{
		if((theAcceleration - 50) > 5)
		{
			theAcceleration -= 50;
		}
		else
		{
			theAcceleration = 5;
		}
	}
		
	GroundSpeed = theAcceleration;

	/*
	if(speedMax > 0)
	{
		if(WalkSpeedBlendVar != none)
			WalkSpeedBlendVar.SetBlendTarget(TheAcceleration/speedMax, 0.1);
		if(SprintSpeedBlendVar != none)
			SprintSpeedBLendVar.SetBlendTarget(TheAcceleration/speedMax, 0.1);
	}*/
}

exec function StartAim()
{
	bAiming = true;
	PlaySlotAnims(TorsoAnimSlot, SWeapon(Weapon).AimAnim, 3, true,,0.2,0.2,true);
	UTPlayerController(Controller).StartZoom(45,60);
}

exec function StopAim(){
	bAiming = false;
	StopPlaySlotAnims(TorsoAnimSlot, 0.2);
	UTPlayerController(Controller).StartZoom(SController(Controller).DefaultFOV,60);
	//PlaySlotAnims(TorsoAnimSlot, SWeapon(Weapon).HoldAnim, 3, true,,0.2,0.2,true);
}

exec function StartSprint()
{
	SetSprint(true);
}

exec function StopSprint()
{
	SetSprint(false);
}

reliable server function ServerSetSprint(bool bSprint)
{
	SetSprint(bSprint);
}

simulated function SetSprint(bool bSprint)
{
	if(Role < ROLE_Authority)
	{
		ServerSetSprint(bSprint);
	}

	bSprinting = bSprint;
}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
}


simulated function PlayAttack(bool bAttack)
{

}

simulated function SeeEnemyReaction()
{

}

simulated function EndSeeEnemyReaction()
{

}

function JumpOffPawn();//Disabling these. apparently they damages other pawns when colliding with them?
function bool EncroachingOn(Actor Other);
function EncroachedBy(Actor Other);

defaultproperties
{

	bIsBot = false

	velocityLimit = 500

	bAllowNextMelee = true
	bFixedCam = true

	//WalkableFloorZ=1	 // 0.7 ~= 45 degree angle for floor
	GravityDirection = (X=0, Y=0, Z=-1)//default gravity going down (X=0,Y=0,Z=-1)
	//bCanWalk=false
	WalkingPhysics=PHYS_Walking
	LandMovementState=PlayerWalking
	//WalkingPhysics = PHYS_Falling

	CamHeight = 40
		CamDistance = 150
		CamYOffset = 60

	//ViewPitchMin = -32768
	//ViewPitchMax = 32768

	bRollToDesired = true

	bEditingCharacter = false

	bPlayingMelee = false

	bPressingRollRight  = false
	bPressingRollLeft   = false

	bGravityOn  = true
	
	bExperiencingGravity = false
	bOldExperiencingGravity = false
	
	bAllowFootStepSound = true
	bJetPackOn = false
	bPressingJump = false
	bJetPackActive = false
	bWorldView = false
	BuildingActor = none
	bAllowJump = true
	bDrivingShip = false

	bAiming = false

	LeftArmSlotsPlaying = false
	RightArmSlotsPlaying = false
	TorsoSlotsPlaying = false
	ArmsSlotsPlaying = false
	HeadSlotsPlaying = false

	DrawScale = 1.1

   IsoCamAngle=15000//6420 //35.264 degrees
   CamOffsetDistance=8000.0

	CamOffset=(X=15,Y=30,Z=-30)

	GroundSpeed=60
	AirSpeed = 60
	SprintSpeedMultiplier=4

	bSprinting = false

	bStrafingRight = false
	bStrafingLeft = false
	bPressingForwards = false
	bPressingBackwards = false
	bPressingShipTurnRight = false
	bPressingShipTurnLeft = false
	bPushesRigidBodies=true
	bEnableFootPlacement = FALSE//*****WHOAAAAA Doesn't seem important, but if you don't have this as false, then your pawn as well as AI controlled pawns will sink into the ground.
								//Probably enable if you end up using foot placement stuff though :3
	bFlashLightEnabled = false

	footstepsound = SoundCue'Human1.Sounds.FootStep_cue'

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0015.000000
		CollisionHeight=+0050.000000

	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'RoboHelper1.Mesh.RoboHelper1_SKMesh'
		AnimTreeTemplate=AnimTree'RoboHelper1.AnimTree.RoboHelper1_AnimTree'
		AnimSets(0)=AnimSet'RoboHelper1.AnimSet.RoboHelper1_AnimSet'
		PhysicsAsset=PhysicsAsset'RoboHelper1.Physics.RoboHelper1_SKMesh_Physics'
		LightEnvironment = none

	End Object

	Begin Object Class=LightFunction Name=MyLightFunction
		SourceMaterial=Material'PXFlashLight.FlashLight_Pattern1_mat'
		Scale = (X=512, Y=512, Z=512)
	End Object

}