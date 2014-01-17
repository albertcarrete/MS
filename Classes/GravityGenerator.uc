class GravityGenerator extends DestructibleActiveShipPart;

function TurnOn(){
	Super.TurnOn();

	ShipOwner.SetGravity(true);
}

function TurnOff(){
	Super.TurnOff();
	
	ShipOwner.SetGravity(false);
	ShipOwner.bCanEnableGravity = false;
}

function SetFunctional(bool bfunctional){
	Super.SetFunctional(bfunctional);

	if(bfunctional)
		ShipOwner.bCanEnableGravity = true;
}

DefaultProperties
{
	DrawScale = 5

	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'CommandSeats.Mesh.PlaceHolder_Mesh'
	End Object
}
