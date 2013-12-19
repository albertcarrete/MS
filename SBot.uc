class SBot extends UDKBot;

var Actor Target;

var float TargetDistance;

function PostBeginPlay(){
	super.PostBeginPlay();

	GoToState('Following');
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	Super.Possess(inPawn, bVehicleTransition);

	GoToState('Following');

	SetTimer(0.1, true, 'BrainTick');
}

function SetPressForwards(bool bForwards){
	S_Pawn(Pawn).SetPressForwards(bForwards);
}

function SetTarget(S_Pawn targ, Vector tempLoc){
	Target = targ;

	Pawn(Target).ClientMessage("Set Target!");
	Focus = Target;
	//SetRotation(Rotator(Target.Location - Location));
}

function BrainTick(){
	
	if(Target != none){
		TargetDistance = GetDistance(Target.Location);
		if(TargetDistance > 128)
			GoToState('Following');
		else{
			GoToState('Idle');
		}
	}
	else
		GoToState('Idle');
		

}

state Following{

	Begin:
	
	if(Target != none)
		MoveToward(Target, Target, 128);

	goto 'Begin';
}

function float GetDistance(Vector OtherLocation){
	local float Distance;

	Distance = VSize(Pawn.Location - OtherLocation);

   return Distance;
}

state Idle{
	Begin:
	
}

DefaultProperties
{
	TargetDistance = 0;
}
