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

var bool bIsEnemy;

var array<ShipLight> LightsArray;
var array<ShipWeapon> ShipWeaponArray;

var array<ShipPart> ShipPartsArray;

var Seat theSeat;

var Vector defaultSpawnPoint;

var bool bDestroyed;

var int Health;

var float Energy;

var float MaxEnergy;

var float ShipMovementSpeed;
var float TurnMagnitude;

var AudioComponent ThrustersAC;

event Tick( float DeltaTime ){
	Super.Tick(DeltaTime);

	if(bPowerOn){
		
		if((ShipMovementSpeed > 0 || ShipMovementSpeed < 0)&& !ThrustersAC.IsPlaying())
			ThrustersAC.Play();
		if(ShipMovementSpeed == 0)
			ThrustersAC.Stop();

		if(Energy < MaxEnergy){
			Energy += 50 * DeltaTime;
			if(Energy > MaxEnergy)
				Energy = MaxEnergy;
		}else if(Energy > MaxEnergy)
			Energy = MaxEnergy;
			

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

function ShipMoving(float Magnitude){
	ShipMovementSpeed = Magnitude;
}

function SetTurning(float TurningAmount){
	TurnMagnitude = TurningAmount;
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

function SetEnemy(bool bEnemy){
	bIsEnemy = bEnemy;
}

function FireAllWeapons(){
	local int i;

	for(i = 0; i < ShipWeaponArray.Length; i++){
		if(Energy > 50){
			ShipWeaponArray[i].StartFire();
			Energy -= ShipWeaponArray[i].EnergyCost;
		}
	}
}

function SetGravity(bool bOn){
	bGravityOn = bOn;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(bDestroyed)
		return;

	if(Health > 0)
		PlaySound(SoundCue'ProjectSSounds.BeepSounds.DeepBeep1_Cue', false, false);
		Health-=DamageAmount;
	if(Health < 0)
		Health = 0;

	if(Health <= 0)
		DestroyShip();

}

simulated function DestroyShip(){
	local int i;
	local S_Pawn P;

	bDestroyed = true;
	
	foreach WorldInfo.AllPawns(class'S_Pawn', P){
		if(P.ShipActor == self){
			if(P.SelectionCircleActor != none)
				P.SelectionCircleActor.Destroy();
			P.Destroy();
		}
	}

	for(i=0; i < ShipPartsArray.Length; i++)
		ShipPartsArray[i].Destroy();
	for(i=0; i < LightsArray.Length; i++)
		LightsArray[i].Destroy();

	self.Destroy();
	
	WorldInfo.ForceGarbageCollection();
}

DefaultProperties
{
	Begin Object Class=AudioComponent Name=ThrustersAudioComponent
		SoundCue=SoundCue'ProjectSSounds.ThrusterSounds.ThrusterLoop_cue'
	End Object
	Components.Add(ThrustersAudioComponent)
	ThrustersAC = ThrustersAudioComponent

	TurnMagnitude = 0;
	ShipMovementSpeed = 0

	bIsEnemy = false

	bDestroyed = false
	Health = 1000
	Energy = 1000
	MaxEnergy = 1000
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
