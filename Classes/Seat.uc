class Seat extends ActiveShipPart;

var Pawn PawnSitting;

event Tick(float DeltaTime){
	Super.Tick(DeltaTime);

	if(PawnSitting != none && PawnSitting.Health <= 0)
		SetSitting(false);
}

function SetSitting(bool bSitting){
	if(bSitting){
		SetCollisionType(COLLIDE_BlockWeapons);
	}else{
		SetCollisionType(Collide_BlockAll);
		PawnSitting = none;
	}
}

function Interact(S_Pawn Instigator){
	local Vector SittingLoc, X, Y , Z;

	Super.Interact(Instigator);

	//SittingLoc = Location;

	GetAxes(Instigator.Rotation, X, Y, Z);

	if(PawnSitting != none && Instigator != PawnSitting)
		return;

	if(Instigator.bDrivingShip){
		Instigator.ToggleDriveShip();
		Instigator.SetLocation(Location + X* 50 + vect(0,0,1) * 53);
		Instigator.CylinderComponent.SetActorCollision(true,true,true);
		Instigator.SetCollision(true,true);

		Instigator.CurrentSeatActor = none;

		SetSitting(false);
	}
	else{
		PawnSitting = Instigator;
		//Instigator.SetBase(self);
		Instigator.CylinderComponent.SetActorCollision(false,false,false);
		//Instigator.SetCollision(false,false);
		//Instigator.SetCollisionType(COLLIDE_NoCollision);

		Instigator.SetSeatActor(self);
		
		Instigator.SetRotation(Rotation);
		Instigator.ToggleDriveShip();

		SetSitting(true);
	}
}

DefaultProperties
{
	DrawScale = 1.1

	bCanStepUpOn = false

	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'CommandSeats.Mesh.Seat1_Mesh'
	End Object

	Components.Remove(ActiveAudioComponent)
}
