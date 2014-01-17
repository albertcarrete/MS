class ActiveShipPart extends ShipPart placeable;

var int Health;
var int MaxHealth;
var int LastHealth;
var bool bDestroyed;

var AudioComponent ActiveAC;

var SkeletalMeshComponent Mesh;

var AnimNodeBlend PowerCheckVar;

var SoundCue PowerOffCue;

simulated event PostBeginPlay()
{
	PowerCheckVar = AnimNodeBlend(Mesh.FindAnimNode('PowerCheck'));

	if(!bDestroyed)
		ActiveAC.Play();
}

function AddHealth(int healthAdded, S_Pawn Instigator){
	if((Health + healthAdded) < MaxHealth)
		Health+= healthAdded;
	else
		Health = MaxHealth;

	if(Health >= (MaxHealth/2) && bDestroyed){
		SetFunctional(true);
	}

	Instigator.ClientMessage("Health = " @ Health);
}

function SetFunctional(bool bfunctional){
	if(bfunctional){
		bDestroyed = false;
		TurnOn();
	}else{
		bDestroyed=true;
	}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	//super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	Health -= DamageAmount;
	if(Health < 0)
		Health = 0;

	PowerOnOrOff(CheckDestroyed());

	EventInstigator.Pawn.ClientMessage("Took Damage, Health: " @ Health);
}

function Interact(S_Pawn Instigator){

}

function PowerOnOrOff(bool bOff)
{
	if(!bOff && LastHealth <= 0)
	{
		TurnOn();
	}
	else if(bOff && LastHealth > 0)
	{
		TurnOff();
	}

	LastHealth = Health;
}

function TurnOn(){
	PowerCheckVar.SetBlendTarget(0, 1);
	if(!ActiveAC.IsPlaying())
		ActiveAC.Play();
}

function TurnOff(){
	PowerCheckVar.SetBlendTarget(1, 1);
	ActiveAC.Stop();
}

function bool CheckDestroyed()
{
	if(Health <= 0)
		bDestroyed = true;

	return bDestroyed;
}

DefaultProperties
{
	MaxHealth=1000
	Health=1000
	LastHealth=1000

	//PowerOffCue=SoundCue'SpaceSounds.Engine.EnginePowerOff_Cue'
	Begin Object Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'CommandSeats.Mesh.PlaceHolder_Mesh'
	End Object


	Begin Object Class=AudioComponent Name=ActiveAudioComponent
		SoundCue=SoundCue'ProjectSSounds.enginesounds.EngineWorking_Cue'
	End Object
	Components.Add(ActiveAudioComponent)
	ActiveAC = ActiveAudioComponent
}
