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

var bool bRecentlyTookDamage;

var array<ShipLight> LightsArray;
var array<ShipWeapon> ShipWeaponArray;

var array<ShipPart> ShipPartsArray;

var Seat theSeat;

var Vector defaultSpawnPoint;

var bool bDestroyed;

var int Health;
var int OldHealth;

var int DecisionInt;

var float Energy;

var float MaxEnergy;

var float ShipMovementSpeed;
var float TurnMagnitude;

var AudioComponent ThrustersAC;

var ParticleSystemComponent ExplosionComponent;
var ParticleSystem ExplosionParticleSystem;

var Ship EnemyShip;
var bool bBattleMode;

var int TimerTime;

event Tick( float DeltaTime ){
	local Ship S;

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

	if(!bBattleMode){
		foreach AllActors( class 'Ship', S ){
			if(S!=self && GetDistance(S.Location) < 10000){
				bBattleMode=true;
				EnemyShip = S;
				EnemyShip.EnemyShip = self;
				EnemyShip.bBattleMode = true;
				TimerTime=20;
				EnemyShip.TimerTime=20;
				StartCountdown();
				EnemyShip.StartCountdown();
			}
		}
	}else if(EnemyShip != none){
		if(EnemyShip.Health <= 0)
			EnemyShip=none;
		else
			SetRotation(RInterpTo(Rotation, Rotator(EnemyShip.Location - Location), DeltaTime, 90000, true));
	}else
		bBattleMode=false;

}

function SpawnAllShipParts(){

}

simulated event PostBeginPlay(){
	Super.PostBeginPlay();
	//WHOAH
	SpawnAllShipParts();
	SMesh.SetActorCollision(false, false, false);
}

function ShipPart SpawnShipPart(class<ShipPart> ShipPartClass, float locXOffset, float locYOffset, float locZOffset, optional float rotYawOffset, optional float rotPitchOffset, optional float rotRollOffset){
	local Vector tempLoc;
	local Rotator tempRot;
	local ShipPart tempShipPart;

	tempLoc = Location;
	tempRot = Rotation;
	if(rotYawOffset > 0 || rotYawOffset < 0)
		tempRot.Yaw += rotYawOffset;
	if(rotPitchOffset > 0 || rotPitchOffset < 0)
		tempRot.Pitch += rotPitchOffset;
	if(rotRollOffset > 0 || rotRollOffset < 0)
		tempRot.Roll += rotRollOffset;

	tempLoc.X += locXOffset;
	tempLoc.Y += locYOffset;
	tempLoc.Z += locZOffset;
	
	tempShipPart = Spawn(ShipPartClass, , , tempLoc, tempRot);
	ShipPartsArray.AddItem(tempShipPart);
	tempShipPart.ShipOwner = self;
	if(tempShipPart.bIsWeapon){
		ShipWeaponArray.AddItem(ShipWeapon(tempShipPart));
		PawnOwner.ClientMessage("Found a Ship Weapon!!");
	}

	tempShipPart.BaseToOwner();

	return tempShipPart;
}

function SpawnShipLight(class<ShipLight> ShipPartClass, float locXOffset, float locYOffset, float locZOffset, optional float rotYawOffset, optional float rotPitchOffset, optional float rotRollOffset){
	local Vector tempLoc;
	local Rotator tempRot;
	local ShipLight tempShipPart;

	tempLoc = Location;
	tempRot = Rotation;
	if(rotYawOffset > 0 || rotYawOffset < 0)
		tempRot.Yaw += rotYawOffset;
	if(rotPitchOffset > 0 || rotPitchOffset < 0)
		tempRot.Pitch += rotPitchOffset;
	if(rotRollOffset > 0 || rotRollOffset < 0)
		tempRot.Roll += rotRollOffset;

	tempLoc.X += locXOffset;
	tempLoc.Y += locYOffset;
	tempLoc.Z += locZOffset;
	
	tempShipPart = Spawn(ShipPartClass, , , tempLoc, tempRot, , true);
	tempShipPart.ShipOwner = self;
	LightsArray.AddItem(tempShipPart);

	tempShipPart.BaseToOwner();
}

simulated function StartCountdown(){
	worldinfo.game.broadcast(self, TimerTime);

	if(TimerTime != 0){
		TimerTime--;
		SetTimer(1, false, 'StartCountdown');
	}else
		CountdownEnded();
}

simulated function CountdownEnded(){

	SetTimer(5, false, 'ResetCountDown');
	
	FireAllWeapons();

	//MakeDecision(DecisionInt);
}

simulated function ResetCountDown(){
	local Ship S;

	foreach AllActors( class 'Ship', S ){
		if(S!=self && GetDistance(S.Location) < 10000 && S.Health > 0){
			bBattleMode=true;
			EnemyShip = S;
			EnemyShip.EnemyShip = self;
			EnemyShip.bBattleMode = true;
			TimerTime=20;
			EnemyShip.TimerTime=20;
			StartCountdown();
			EnemyShip.StartCountdown();
		}
	}
}

simulated function MakeDecision(int Decision){
	//DesicionArray[Decision].Activate();
}

function float GetDistance(Vector OtherLocation){
	local float Distance;

	Distance = VSize(Location - OtherLocation);
	//ClientMessage(Distance);
   return Distance;
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

function EndRecentlyTookDamage(){
	bRecentlyTookDamage=false;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(bDestroyed)
		return;
	

	if(Health > 0){
		PlaySound(SoundCue'ProjectSSounds.BeepSounds.DeepBeep1_Cue', false, false);
		OldHealth = Health;
		Health-=DamageAmount;
		bRecentlyTookDamage = true;
		SetTimer(0.3, false, 'EndRecentlyTookDamage');

		if(OldHealth > 300 && Health < 300)
			Critical();
	}
	if(Health < 0)
		Health = 0;

	if(Health <= 0)
		DestroyShip();

}

simulated function Critical(){
	local int i;
	local color c;
	
	c.A=1;
	c.R=255;
	c.G=0;
	c.B=0;

	for(i = 0; i < LightsArray.Length; i++){
		LightsArray[i].LightActor.theLight.SetLightProperties(1,c);
		LightsArray[i].LightActor.theLight.UpdateColorAndBrightness();
	}
}

simulated function DestroyShip(){
	local int i;
	local S_Pawn P;

	bDestroyed = true;
	
	foreach WorldInfo.AllPawns(class'S_Pawn', P){
		if(P.ShipActor == self){
			if(P.SelectionCircleActor != none){
				P.SelectionCircleActor.Destroy();
			}
			P.Destroy();
		}
	}

	for(i=0; i < ShipPartsArray.Length; i++)
		ShipPartsArray[i].Destroy();
	for(i=0; i < LightsArray.Length; i++)
		LightsArray[i].Destroy();

	ExplosionComponent = new () class'ParticleSystemComponent';
	ExplosionComponent.SetScale(20);
	ExplosionComponent.SetTemplate(ExplosionParticleSystem);
	AttachComponent(ExplosionComponent);
	ExplosionComponent.SetActive(true);

	PlaySound(SoundCue'ProjectSSounds.Explosion.ShipExplosion1_cue', false, false, false);

	SetTimer(10, false, 'RealDestroy');
	
	WorldInfo.ForceGarbageCollection();
}

function RealDestroy(){
	self.Destroy();
	WorldInfo.ForceGarbageCollection();
}

DefaultProperties
{
	bCollideActors =false
	bBlockActors=false

	TimerTime = 20

	ExplosionParticleSystem = ParticleSystem'PXParticleSystems.Effects.P_FX_ShipExplosion'
	
	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'Human1.Mesh.CustomCylinderCollision'
	End Object

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
	OldHealth = 1000
	Energy = 1000
	MaxEnergy = 1000
	//Physics = PHYS_Falling

	defaultSpawnPoint = (X=-190, Y=-245, Z=52)

	bRecentlyTookDamage=false

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

	bBattleMode=false
}
