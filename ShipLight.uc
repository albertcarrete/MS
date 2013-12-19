class ShipLight extends Actor;

var PointLightComponent Light1;
var ShipPointLightMovable LightActor;

var Ship ShipOwner;
var ShipPart LastPiece;
var ShipPart PartOwner;
var S_Pawn PawnOwner;

function BaseToOwner(){
	if(ShipOwner != none)
		SetBase(ShipOwner);
}

simulated event PostBeginPlay(){
	LightActor = Spawn(class'ShipPointLightMovable', , , Location, , , true);
	Light1 = LightActor.theLight;
	SetCollision(false, false);
	AttachComponent(Light1);
}

function SetLightEnabled(bool bEnabled){
	Light1.SetEnabled(bEnabled);
}

DefaultProperties
{
	bNoDelete = false
	
    bCollideActors = false
	bCollideWorld = false
}
