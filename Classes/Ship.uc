class Ship extends ShipPart;

var bool bCanEnableLights;
var bool bCanEnableGravity;
var bool bCanEnablePower;
var bool bCanEnableWeapons;

var bool bLightsTurnedOn;
var bool bGravityGenOn;

var bool bGravityOn;
var bool bLightsOn;
var bool bPowerOn;
var bool bWeaponsOn;

var array<ShipLight> LightsArray;
var array<ShipPart> ShipWeaponArray;

var Vector defaultSpawnPoint;

event Tick( float DeltaTime ){
	Super.Tick(DeltaTime);

	if(bPowerOn){
		if(!bGravityOn && bCanEnableGravity && bGravityGenOn)
			SetGravity(true);
		if(!bLightsOn && bCanEnableLights && bLightsTurnedOn){
			SetAllLightsEnabled(true);
		}if(!bWeaponsOn && bCanEnableWeapons){
			SetAllWeaponsEnabled(true);
		}
	}else{
		if(bGravityOn)
			SetGravity(false);
		if(bLightsOn)
			SetAllLightsEnabled(false);
		if(bWeaponsOn)
			SetAllWeaponsEnabled(false);
	}
}

function SetAllWeaponsEnabled(bool bOn){
	bWeaponsOn = bOn;
}

function SetPowerOn(bool bOn){
	if(PawnOwner != none)
		PawnOwner.ClientMessage("PowerCore On = " @ bOn);
	bPowerOn = bOn;
}

function AddLight(Vector LightLoc){
	/*local RoomLight tempLight;
	tempLight = Spawn(class'RoomLight', , , LightLoc);
	LightsArray.AddItem(tempLight);*/
}

function SetAllLightsEnabled(bool bEnabled){
	local int i;
	
	for(i = 0; i < LightsArray.Length; i++){
		LightsArray[i].SetLightEnabled(bEnabled);
	}

	bLightsOn = bEnabled;
}

function FireAllWeapons(){
	local int i;

	for(i = 0; i < ShipWeaponArray.Length; i++){
		ShipWeaponArray[i].StartFire();
	}
}

function SetGravity(bool bOn){
	bGravityOn = bOn;
}

DefaultProperties
{
	//Physics = PHYS_Falling

	defaultSpawnPoint = (X=-190, Y=-245, Z=52)

	bCanEnableLights=true
	bCanEnableGravity=true
	bCanEnablePower=true
	bCanEnableWeapons=true

	bLightsTurnedOn=true
	bGravityGenOn=true

	bGravityOn=true
	bLightsOn=true
	bPowerOn=true
	bWeaponsOn=true
}
