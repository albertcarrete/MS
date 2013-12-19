class PowerCore extends ActiveShipPart;

function TurnOn(){
	Super.TurnOn();

	ShipOwner.SetPowerOn(true);
}

function TurnOff(){
	Super.TurnOff();
	
	ShipOwner.SetPowerOn(false);
}

DefaultProperties
{
	DrawScale = 5

	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'CommandSeats.Mesh.PlaceHolder_Mesh_Green'
	End Object
}
