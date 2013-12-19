class SControllerBot extends SController;

var S_Pawn Target;
/** Used so AI doesn't hold forward in space, but instead presses it in intervals*/
var bool bAllowPressForward;
var int MovementIntensity;//Multiplier to movement to controll ai movement

var float DistanceFromTarget;
/** The distance this AI will try to keep from its target when walking*/
var float DistanceToKeepFromTarget;


event PostBeginPlay(){
	SPlayer_Pawn(Pawn).bIsBot = true;
}



event PlayerTick( float DeltaTime ){
	Super.PlayerTick(DeltaTime);
	if(Target != none){

	

		//SetRotation(RInterpTo(Rotator(Target.Location - Location), Rotation, DeltaTime, 40000));
		

		DistanceFromTarget = GetDistance(Target.Location);

		MovementIntensity = 1;//Let the pawn walk at regular pace(times 1)

		if(!S_Pawn(Pawn).bExperiencingGravity){

			if(DistanceFromTarget > 200){

					if(S_Pawn(Pawn).VelocityLimit < 500)
						S_Pawn(Pawn).VelocityLimit += 50 * DeltaTime;
					else
						S_Pawn(Pawn).VelocityLimit = 500;

					GoToTarget(DeltaTime);
				
			}else{

				if(S_Pawn(Pawn).VelocityLimit > 0)
					S_Pawn(Pawn).VelocityLimit -= 100 * DeltaTime;
				else
					S_Pawn(Pawn).VelocityLimit = 0;
			}
		}else{
			if(DistanceFromTarget < DistanceToKeepFromTarget ){
					MovementIntensity = 0;//Stop pawn from walking(times 0)
					S_Pawn(Pawn).SetSprint(true);
			}else if(DistanceFromTarget < DistanceToKeepFromTarget * 2)
				S_Pawn(Pawn).SetSprint(false);
			else
				S_Pawn(Pawn).SetSprint(true);

			if(Target.bSprinting && Target.CheckMoving())//If target is sprinting and moving(so not just holding sprint) then sprint too.
				S_Pawn(Pawn).SetSprint(True);

		}
		
		//Focus = none;
		//SetFocalPoint(Target.Location);
		SetRotation(Rotator(Target.Location - Location));
		//Pawn.SetDesiredRotation(Rotation);
	}
}



state PlayerWalking{
	ignores SeePlayer, HearNoise, Bump;

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

function float GetDistance(Vector OtherLocation){
	local float Distance;

	Distance = VSize(Pawn.Location - OtherLocation);

   return Distance;
}


DefaultProperties
{
	DistanceToKeepFromTarget = 100
	MovementIntensity = 1
	bAllowPressForward = true
}
