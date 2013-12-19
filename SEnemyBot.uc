class SEnemyBot extends UDKBot;

/** PX: The AI knows that its target is present
 *  */
var bool bKnowsTargetIsPresent;

/**PX: The AI can see its target
 * */
var bool bCanSeeTarget;
/** PX: The AI has started the timer of forgetting about its unseen target
 *  */
var bool StartedForgettingAboutTarget;
/** PX: Assuming the AI doesn't know there is a target present...
 *      If true, then the AI will become Idle the next time it decides what to do.
 *      If false, the AI will instead decide to wander randomly.
 *  */
var bool bShouldIdle;
/** PX: The current target of this AI
 *  */
var Vector Target;

var() Vector TempDest;

/** PX: The location of the last noise heard
 *  */
var Vector NoiseLocation;

/** PX: How far the controller can see
 *  */
var int SightDistance;
/** PX: How far the controller can hear
 *  */
var int HearDistance;

/** PX: How far away the AI is from its target
 *  */
var float TargetDistance;

/** PX: The minimum distance the AI has to be to its target  in order to
 *  start attacking
 *  */
var int AttackDistance;

var Pawn TargetActor;

simulated event PostBeginPlay()
{
	StartBrainTimer();

	super.PostBeginPlay();
}

state Idle
{
	event BeginState(Name PreviousStateName)
	{
		DecideIdleOrWander();
		S_Pawn(Pawn).SetSprint(false);
	}
	event EndState(Name NextStateName)
	{
		SetTimer(0, false, 'DecideIdleOrWander');
	}

	Begin:

}

state RandomWander
{
	event BeginState(Name PreviousStateName)
	{
		DecideIdleOrWander();
		GetRandomWanderTarget();
		S_Pawn(Pawn).SetSprint(false);
	}
	event EndState(Name NextStateName)
	{
		SetTimer(0, false, 'DecideIdleOrWander');
		SetTimer(0, false, 'GetRandomWanderTarget');
	}

	Begin:

	if( NavigationHandle.PointReachable(Target))
	{
		FlushPersistentDebugLines();
		//Direct move
		MoveTo(Target, , Pawn.GetCollisionRadius());
	}
	else if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(Target);
		FlushPersistentDebugLines();
		//NavigationHandle.DrawPathCache(,TRUE);
        
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
		{
			//DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
			//DrawDebugSphere(TempDest,16,20,255,0,0,true);
            
			MoveTo( TempDest);
		}
	}
	else
	{
    	//If the target isn't directly reachable and no paths could be found to the target...
		MoveTo(Target, , Pawn.GetCollisionRadius()); // Just move to the target, this will result in walking into stuff though....
	}

	goto 'Begin';
}


state Searching
{
	Begin:

	if( NavigationHandle.PointReachable(Target))
	{
		FlushPersistentDebugLines();
		//Direct move
		MoveTo(Target, , Pawn.GetCollisionRadius());
	}
	else if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(Target);
		FlushPersistentDebugLines();
		//NavigationHandle.DrawPathCache(,TRUE);
        
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
		{
			//DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
			//DrawDebugSphere(TempDest,16,20,255,0,0,true);
            
			MoveTo( TempDest);
		}
	}
	else
	{
    	//If the target isn't directly reachable and no paths could be found to the target...
		MoveTo(Target, , Pawn.GetCollisionRadius()); // Just move to the target, this will result in walking into stuff though....
	}

	goto 'Begin';
}

state Chasing
{
	event BeginState(Name PreviousStateName)
	{
		`log("Inside CHASE STATE!!!");
		S_Pawn(Pawn).SeeEnemyReaction();
	}

	event EndState(Name NextStateName)
	{
		S_Pawn(Pawn).PlayAttack(false);
		S_Pawn(Pawn).EndSeeEnemyReaction();
	}

	Begin:

	if( NavigationHandle.PointReachable(Target))
	{
		FlushPersistentDebugLines();
		//Direct move
		MoveTo(Target, , Pawn.GetCollisionRadius());
	}
	else if( FindNavMeshPath() )
	{
		NavigationHandle.SetFinalDestination(Target);
		FlushPersistentDebugLines();
		//NavigationHandle.DrawPathCache(,TRUE);
        
		// move to the first node on the path
		if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
		{
			//DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
			//DrawDebugSphere(TempDest,16,20,255,0,0,true);
            
			MoveTo( TempDest);
		}
	}
	else
	{
    	//If the target isn't directly reachable and no paths could be found to the target...
		MoveTo(Target, , Pawn.GetCollisionRadius()); // Just move to the target, this will result in walking into stuff though....
	}

	goto 'Begin';
}

event SeePlayer (Pawn Seen)
{
    if (GetDistance(Seen.Location) <= SightDistance)
    {
		SetTimer(0, false, 'DoesntKnowTargetIsPresent');

		TargetActor = Seen;
		Target = Seen.Location;

		bCanSeeTarget = true;
		bKnowsTargetIsPresent = true;
		StartedForgettingAboutTarget = false;
		SetTimer(0.5, false, 'EndSee');
	}
	else
	{
		bCanSeeTarget = false;
	}
}

event HeardPlayer (Vector NoiseLoc)
{
	if(GetDistance(NoiseLocation) <= HearDistance)
	{
		SetTimer(0, false, 'DoesntKnowTargetIsPresent');

		if(!bCanSeeTarget)
			Target = NoiseLoc;

		bKnowsTargetIsPresent = true;
		StartedForgettingAboutTarget = false;
	}
}

function bool FindNavMeshPath()
{
    // Clear cache and constraints (ignore recycling for the moment)
    NavigationHandle.PathConstraintList = none;
    NavigationHandle.PathGoalList = none;

	class'NavMeshPath_Toward'.static.TowardPoint( NavigationHandle,Target );
	class'NavMeshGoal_At'.static.AtLocation( NavigationHandle, Target,32 );

    // Find path
    return NavigationHandle.FindPath();
}

function float GetDistance(Vector OtherLocation)
{
	local float Distance;

	Distance = VSize(Pawn.Location - OtherLocation);

   return Distance;
}

function EndSee()
{
	bCanSeeTarget = false;
}

function DecideWhatToDo()
{
	//Be Idle
	if(!bKnowsTargetIsPresent)
	{
		if(bShouldIdle)
		{
			GoToState('Idle');
		}
		//Go to a random location
		else
		{
			GoToState('RandomWander');
		}
	}
	else
	{
		if(bCanSeeTarget)
		{
			GoToState('Chasing');
		}
		else
		{
			GoToState('Searching');
		}
	}
}

function DecideIdleOrWander()
{
	local int RandIdleOrNot;
	local int RTimeTillReconsider;
	RandIdleOrNot = rand(100);
	RTimeTillReconsider = rand(20);	

	if(RandIdleOrNot < 50)
	{
		bShouldIdle = true;
	}
	else
	{
		bShouldIdle = false;
	}

	SetTimer(RTimeTillReconsider, false, 'DecideIdleOrWander');
}

function ForgetAboutTarget()
{
	bKnowsTargetIsPresent = false;
	StartedForgettingAboutTarget = true;
	bCanSeeTarget = false;
	//Target = Pawn.Location;
}

function StartBrainTimer()
{
	BrainTimer();
	SetTimer(0.1, true, 'BrainTimer');
}

function BrainTimer()
{
	//Knows Something
	if(bKnowsTargetIsPresent)
	{
		if(!bCanSeeTarget)
		{
			S_Pawn(Pawn).SetSprint(false);
			//If the process of forgetting about target hasn't started yet
			if(!StartedForgettingAboutTarget)
			{
				//Forget about unseen target after a certain amount of time
				SetTimer(10, false, 'ForgetAboutTarget');
				StartedForgettingAboutTarget = true;
			}
		}
		else
		{
			TargetDistance = GetDistance(Target);

			if(TargetDistance <= 500)
			{
				//PXDefaultPlayerController(TargetActor.Controller).StartScareEffect(self);
			}

			if (TargetDistance <= AttackDistance)
			{
				S_Pawn(Pawn).PlayAttack(true);
				S_Pawn(Pawn).SetSprint(true);
			}
			else
			{
				S_Pawn(Pawn).PlayAttack(false);
				S_Pawn(Pawn).SetSprint(false);
			}
		}
	}
	//Knows Nothing
	else
	{
		
	}

	DecideWhatToDo();
}

function GetRandomWanderTarget()
{
	local int LeftRight;
	local Vector InFront, X, Y, Z, HitLoc, HitNormal;
	local int RTimeTillNewRandom;
	local Actor HitActor;

	if(!bKnowsTargetIsPresent)
	{
		//StopLatentExecution();

		//make a random number
		LeftRight = Rand(200) - Rand(50);

		GetAxes(Pawn.Rotation, X,Y,Z);

		InFront = Pawn.Location + LeftRight * Y;

		//do another trace to a random location left or right
		HitActor = Trace(HitLoc, HitNormal, InFront, Pawn.Location);
		//DrawDebugSphere( HitLoc, 30, 10, 255, 0, 0 );

		if (HitActor != None)  //if we trace something
		{
			Target = InFront;
			SetTimer(0.1, false, 'GetRandomWanderTarget');
		}
		else  //if we trace nothing
		{
			Target = InFront;
			RTimeTillNewRandom = rand(2);
			SetTimer(RTimeTillNewRandom, false, 'GetRandomWanderTarget');
		}
	}
}

DefaultProperties
{
	bIsPlayer = false

	SightDistance = 2000
	HearDistance = 15000
	AttackDistance = 200
	bShouldIdle = true
	bKnowsTargetIsPresent = false
	bCanSeeTarget = false
	StartedForgettingAboutTarget = true
}
