class SController extends UTPlayerController;

/** used to hold the value of the previous X value in UpdateRotation()*/
var Vector OldX;

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

			// Update acceleration.
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

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


/*
state PlayerWalking{

	event BeginState(Name PreviousStateName){
		if(S_Pawn(Pawn).bExperiencingGravity)
			Super.BeginState(PreviousStateName);
		else{
			//GoToState('PlayerFalling');
			//Pawn.Floor = none;
			//GoToState()
		}
	}event EndState(Name NextStateName){
		if(S_Pawn(Pawn).bExperiencingGravity)
			Super.EndState(NextStateName);
		else{
			
		}
	}
}*/
/*

state PlayerFlying{
	event BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		S_Pawn(Pawn).AimNode.SetActiveProfileByName('Flying');
	}
}*/

state EditCharacter{
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);
/*
	event BeginState(Name PreviousStateName){
		local Rotator facingCharacterRot;
		
		facingCharacterRot = Rotation;
		facingCharacterRot.Yaw += 32768;
		facingCharacterRot.Pitch = 0;
		facingCharacterRot.Roll = 0;
		//SetRotation(facingCharacterRot);
	}*/
}

state WorldView{
ignores SeePlayer, HearNoise, Bump;
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);
}

state PlayerDriving{
ignores SeePlayer, HearNoise, Bump;
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);
	//function PlayerMove( float DeltaTime );
	//function UpdateRotation(float DeltaTime);
}

simulated function ReadyJump()
{
	PlayerInput.Jump();
	SetTimer(1, false, 'StartAllowJump');
}

simulated function StartAllowJump()
{
	S_Pawn(Pawn).AllowJump();
}
/*
state PlayerFlying
{
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = PlayerInput.aForward*X + PlayerInput.aStrafe*Y + PlayerInput.aUp*vect(0,0,1);;
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);

		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
}*/

/*
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

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
}

function UpdateRotation( float DeltaTime )
{
   local Rotator   DeltaRot, newRotation, ViewRotation;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

   // Calculate Delta to be applied on ViewRotation
   DeltaRot.Yaw   = PlayerInput.aTurn;
   DeltaRot.Pitch   = 0;

   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);

   NewRotation = ViewRotation;
   NewRotation.Roll = Rotation.Roll;

   if ( Pawn != None )
      Pawn.FaceRotation(NewRotation, deltatime);
}
*/



function UpdateRotation( float DeltaTime )
{
   local Rotator   DeltaRot, newRotation, ViewRotation;
   local Vector X, Y, Z;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

	GetAxes(Rotation, X, Y, Z);

	if ( (PlayerInput.aTurn != 0) || (PlayerInput.aLookUp != 0) ){
            // adjust Yaw based on aTurn
            if ( PlayerInput.aTurn != 0 )
            {
                X = Normal(X + 10 * Y * Sin(0.0005*DeltaTime*PlayerInput.aTurn));
            }

            // adjust Pitch based on aLookUp
            if ( PlayerInput.aLookUp != 0 )
            {
				OldX = X;

                X = Normal(X + 10 * Z * Sin(0.0005*DeltaTime*PlayerInput.aLookUp));
                Z = Normal(X Cross Y);
				
                // Where I'm limiting max pitch
                /*if ( (S_Pawn(Pawn).bExperiencingGravity) && (Z dot vect(0,0,-1)) >  0.1 )
                {
		    		X = OldX;
                }*/
            }
    }

    if(Pawn != None){
    	if(S_Pawn(Pawn).bExperiencingGravity || S_Pawn(Pawn).bDrivingShip){
			
			ViewRotation = Rotation;
			Pawn.SetDesiredRotation(ViewRotation);

    		DeltaRot.Yaw   = PlayerInput.aTurn;
			DeltaRot.Pitch   = PlayerInput.aLookUp;

    		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
			SetRotation(RInterpTo(Rotation, ViewRotation, DeltaTime, 90000));

			//newRotation = ViewRotation;
			//newRotation.Roll = Rotation.Roll;
			Pawn.FaceRotation(Rotation, DeltaTime);
    	}else{
			ViewRotation =  OrthoRotation(X,Y,Z);
			SetRotation(ViewRotation);
			Pawn.SetRotation(ViewRotation);
			//Pawn.FaceRotation(ViewRotation, DeltaTime);
    	}
    }else{//NO PAWN?
		ViewRotation =  OrthoRotation(X,Y,Z);
		SetRotation(ViewRotation);
    }
}

/**
 * Processes the player's ViewRotation
 * adds delta rot (player input), applies any limits and post-processing
 * returns the final ViewRotation set on PlayerController
 *
 * @param	DeltaTime, time since last frame
 * @param	ViewRotation, current player ViewRotation
 * @param	DeltaRot, player input added to ViewRotation
 */
function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
	if( PlayerCamera != None )
	{
		PlayerCamera.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
	}

	if ( Pawn != None )
	{	// Give the Pawn a chance to modify DeltaRot (limit view for ex.)
		Pawn.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
	}
	else
	{
		// If Pawn doesn't exist, limit view

		// Add Delta Rotation
		out_ViewRotation	+= DeltaRot;
		out_ViewRotation	 = LimitViewRotation(out_ViewRotation, -16384, 16383 );
	}
}

defaultproperties
{
}