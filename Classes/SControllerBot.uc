class SControllerBot extends SController;

var S_Pawn Target;
/** Used so AI doesn't hold forward in space, but instead presses it in intervals*/
var bool bAllowPressForward;
var int MovementIntensity;//Multiplier to movement to controll ai movement

var float DistanceFromTarget;
/** The distance this AI will try to keep from its target when walking*/
var float DistanceToKeepFromTarget;

/** if true, then this AI has vision of its target*/
var bool bCanSeeTarget;

/** the distance that this AI can see*/
var float SightDistance;

/** used so we can have a delay between blade attacks or else AI is too fast*/
var bool bAllowMelee;

/** to know whether this AI is shooting so we don't make him keep going towards the player*/
var bool bIsShooting;

/** Distance the AI should keep from it's target when shooting*/
var float DistanceToStopForShooting;

event PostBeginPlay(){
	SPlayer_Pawn(Pawn).bIsBot = true;
}



event PlayerTick( float DeltaTime ){
	local float randDelay;

	local Vector TargetAim;

	if(Pawn.Health <= 0)
		return;

	Super.PlayerTick(DeltaTime);
	
	if(SPlayer_Pawn(Pawn).bPlayingMelee)
		return;

	DetectSurroundings();

	if(Target != none){

		//SetRotation(RInterpTo(Rotator(Target.Location - Location), Rotation, DeltaTime, 40000));

		DistanceFromTarget = GetDistance(Target.Location);

		MovementIntensity = 1;//Let the pawn walk at regular pace(times 1)

		if(!S_Pawn(Pawn).bExperiencingGravity){

			if(DistanceFromTarget > 300 || (bIsEnemy != SController(Target.Controller).bIsEnemy && S_Pawn(Pawn).Weapon == none)){

				if(S_Pawn(Pawn).VelocityLimit < 500)
					S_Pawn(Pawn).VelocityLimit += 50 * DeltaTime;
				else
					S_Pawn(Pawn).VelocityLimit = 500;

				GoToTarget(DeltaTime);
				
			}else if(DistanceFromTarget > 150){
				
				if(S_Pawn(Pawn).VelocityLimit < 200)
						S_Pawn(Pawn).VelocityLimit += 50 * DeltaTime;
					else
						S_Pawn(Pawn).VelocityLimit = 200;

					GoToTarget(DeltaTime);
			}else{

				GoAwayFromTarget(DeltaTime);

				if(S_Pawn(Pawn).VelocityLimit > 0)
					S_Pawn(Pawn).VelocityLimit -= 150 * DeltaTime;
				else
					S_Pawn(Pawn).VelocityLimit = 0;
			}
		}else{
			if(bIsEnemy != SController(Target.Controller).bIsEnemy){
				S_Pawn(Pawn).SetSprint(true);

				if(bIsShooting && DistanceFromTarget < DistanceToStopForShooting){
					MovementIntensity = 0;
				}
			}else{
			
				if(DistanceFromTarget < DistanceToKeepFromTarget){
						MovementIntensity = 0;//Stop pawn from walking(times 0)
						S_Pawn(Pawn).SetSprint(false);
				}else if(DistanceFromTarget < DistanceToKeepFromTarget * 2)
					S_Pawn(Pawn).SetSprint(false);
				else
					S_Pawn(Pawn).SetSprint(true);

				if(Target.bSprinting && Target.CheckMoving())//If target is sprinting and moving(so not just holding sprint) then sprint too.
					S_Pawn(Pawn).SetSprint(True);
			}
		}
		
		//Focus = none;
		//SetFocalPoint(Target.Location);
		
		SPlayer_Pawn(Target).Mesh.GetSocketWorldLocationAndRotation('ChestPiece_Socket', TargetAim);

		SetRotation(RInterpTo(Rotation, Rotator(Target.Location - Location), DeltaTime, 90000));
		//SetRotation(Rotator(Target.Location - Location));
		
		//Pawn.SetDesiredRotation(Rotation);

		if(bIsEnemy != SController(Target.Controller).bIsEnemy){
			if(Target.Health > 0){
				if(Pawn.Weapon != none){
					bIsShooting = true;
					S_Pawn(Pawn).StartAim();
					Pawn.StartFire(0);
				}else if(DistanceFromTarget < 150 && bAllowMelee){//Use melee
					bAllowMelee = false;
					randDelay = Rand(2) + 1;
					randDelay /= 10;
					SetTimer(randDelay, false, 'FireWeapon');
					//Pawn.StartFire(0);
				}
			}
			else{
				S_Pawn(Pawn).StopAim();
				if(bAllowMelee)
					Pawn.StopFire(0);
				bIsShooting = false;
			}
		}else{
			if(bAllowMelee)
				Pawn.StopFire(0);
			S_Pawn(Pawn).StopAim();
			bIsShooting = false;
		}

		if(Target.Health <= 0)
			Target = none;

	}else{
		if(bAllowMelee)
			Pawn.StopFire(0);
		S_Pawn(Pawn).StopAim();
		bIsShooting = false;
		S_Pawn(Pawn).SetSprint(false);
		MovementIntensity = 0;
	}
}

function FireWeapon(){
	Pawn.StartFire(0);
	bAllowMelee = true;
}

function DetectSurroundings(){
	local S_Pawn P;
	
	`log("YEAHHHHHHH");
	foreach AllActors( class 'S_Pawn', P )
	{
		if(P.Health > 0 && GetDistance(P.Location) < SightDistance){
			`log("FOUND SPAWN IN AREA!!!!");
			if(SController(P.Controller).bIsEnemy != bIsEnemy)//If the pawn is not your ally
			{
				`log("FOUND SPAWN ENEMY!!!!");
				if(Target == none || SController(Target.Controller).bIsEnemy == bIsEnemy || GetDistance(Target.Location) > GetDistance(P.Location))
					SetTarget(P, P.Location);

			}else if(Target == none){
				`log("FOUND SPAWN FRIEND!!!!");
				SetTarget(P, P.Location);
			}
		}
	}
}

state NewPlayerWalking{
	
	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Rotation,X,Y,Z);
			DrawDebugLine(Location, Location + X * 500, 0, 1, 0);

			// Update acceleration.
			/*NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);*/

			NewAccel = GetTargetDirection() * 200 * MovementIntensity * DeltaTime;

			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			UpdateRotation( DeltaTime );
			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;

			SetLocation(Pawn.Location);
		}
	}

	event BeginState(Name PreviousStateName)
	{
		if(S_Pawn(Pawn).bDrivingShip)
			GoToState('PlayerDriving');

		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody && S_Pawn(Pawn).bExperiencingGravity) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		/*
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}*/
	}

Begin:

	//if(!S_Pawn(Pawn).bExperiencingGravity)
		//Paw
}

state PlayerWalking{
	//ignores SeePlayer, HearNoise, Bump;
	

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume && Pawn.bCollideWorld )
		{
			GotoState(Pawn.WaterMovementState);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration = NewAccel;

		CheckJumpOrDuck();
	}

	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Rotation,X,Y,Z);
			DrawDebugLine(Location, Location + X * 500, 0, 1, 0);

			// Update acceleration.
			/*NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);*/

			NewAccel = GetTargetDirection() * 200 * MovementIntensity * DeltaTime;

			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			UpdateRotation( DeltaTime );
			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;

			SetLocation(Pawn.Location);
		}
	}

	event BeginState(Name PreviousStateName)
	{
		if(S_Pawn(Pawn).bDrivingShip)
			GoToState('PlayerDriving');

		DoubleClickDir = DCLICK_None;
		bPressedJump = false;
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.ShouldCrouch(false);
			if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_RigidBody && S_Pawn(Pawn).bExperiencingGravity) // FIXME HACK!!!
				Pawn.SetPhysics(Pawn.WalkingPhysics);
		}
	}

	event EndState(Name NextStateName)
	{
		/*
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetRemoteViewPitch( 0 );
			if ( bDuck == 0 )
			{
				Pawn.ShouldCrouch(false);
			}
		}*/
	}

Begin:

	//if(!S_Pawn(Pawn).bExperiencingGravity)
		//Pawn.SetPhysics(PHYS_Falling);
}

function UpdateRotation( float DeltaTime )
{
	local Rotator tempRot;

	if(!S_Pawn(Pawn).bExperiencingGravity)
		Pawn.SetRotation(Rotation);
	else{
		tempRot = Rotation;
		tempRot.Pitch=0;
		tempRot.Roll=0;
		Pawn.SetRotation(tempRot);
	}
}

function GoToTarget(float DeltaTime){
	local Vector tempVel;

	tempVel = Normal(Target.Location - Pawn.Location);
	//Pawn.Acceleration = tempVel * 2000 * DeltaTime;
	Pawn.Velocity += tempVel * 200 * DeltaTime;
}

function GoAwayFromTarget(float DeltaTime){
	local Vector tempVel;

	tempVel = Normal(Target.Location - Pawn.Location);
	//Pawn.Acceleration = tempVel * 2000 * DeltaTime;
	Pawn.Velocity -= tempVel * 200 * DeltaTime;
}

function Vector GetTargetDirection(){
	local Vector tempVel;

	tempVel = Normal(Target.Location - Pawn.Location);
	return tempVel;
}

function StopPressingForwards(){
	//S_Pawn(Pawn).SetPressForwards(false);
	bAllowPressForward = false;
	SetTimer(1, false, 'AllowPressForward');
}

function AllowPressForward(){
	bAllowPressForward = true;
}

function SetTarget(S_Pawn targ, Vector tempLoc){
	Target = targ;

	Target.ClientMessage("Set Target!");
	Focus = Target;
	//SetRotation(Rotator(Target.Location - Location));
}

function SetEnemy(bool bEnemy){
	bIsEnemy = bEnemy;
}

function float GetDistance(Vector OtherLocation){
	local float Distance;

	Distance = VSize(Pawn.Location - OtherLocation);

   return Distance;
}

function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	local Rotator theAim;

	theAim = Rotation;
	if(Rand(2) > 0){
		theAim.Pitch+= Rand(1000);
	}else{
		theAim.Pitch-= Rand(1000);
	}

	if(Rand(2) > 0){
		theAim.Yaw-= Rand(1000);
	}else{
		theAim.Yaw+= Rand(1000);
	}

	return theAim;
}

DefaultProperties
{
	bIsShooting = false
	bAllowMelee = true

	bIsPlayer=false

	bIsEnemy = false

	SightDistance = 2000

	DistanceToKeepFromTarget = 100
	DistanceToStopForShooting = 500
	MovementIntensity = 1
	bAllowPressForward = true
}
