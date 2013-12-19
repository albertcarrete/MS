class S_Engine extends Actor placeable;

var int Health;
var int LastHealth;
var bool bDestroyed;

var AudioComponent EngineWorkingAC;

var SkeletalMeshComponent Mesh;

var AnimNodeBlend PowerCheckVar;

var SoundCue PowerOffCue;

event PostBeginPlay()
{
	PowerCheckVar = AnimNodeBlend(Mesh.FindAnimNode('PowerCheck'));

	if(!bDestroyed)
		EngineWorkingAC.Play();
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	Health -= DamageAmount;
	if(Health < 0)
		Health = 0;

	PowerOnOrOff(CheckDestroyed());

	EventInstigator.Pawn.ClientMessage("Took Damage, Health: " @ Health);
}

function PowerOnOrOff(bool bOff)
{
	if(!bOff && LastHealth <= 0)
	{
		TriggerGlobalEventClass(class'SeqEvent_RestorePower',self, 0);
		PowerCheckVar.SetBlendTarget(0, 1);
	}
	else if(bOff && LastHealth > 0)
	{
		TriggerGlobalEventClass(class'SeqEvent_PowerOff',self, 0);
		PowerCheckVar.SetBlendTarget(1, 1);

		EngineWorkingAC.Stop();
		//PlaySound(PowerOffCue, false);
	}

	LastHealth = Health;
}

function bool CheckDestroyed()
{
	if(Health <= 0)
		bDestroyed = true;
	else
		bDestroyed = false;

	return bDestroyed;
}

DefaultProperties
{
	Health=100
	LastHealth=100

	DrawScale=2

	//PowerOffCue=SoundCue'SpaceSounds.Engine.EnginePowerOff_Cue'

	Begin Object Class=AudioComponent Name=EngineWorkingAudioComponent
		SoundCue=SoundCue'ProjectSSounds.enginesounds.EngineWorking_Cue'
	End Object
	Components.Add(EngineWorkingAudioComponent)
	EngineWorkingAC = EngineWorkingAudioComponent

	Begin Object Class=StaticMeshComponent Name=EngineMeshComponent
		StaticMesh=StaticMesh'Engine_1.Mesh.Engine_1_Mesh'
		CollideActors=true
		BlockActors=true
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		HiddenGame=true
	End Object
	CollisionComponent = EngineMeshComponent
	CollisionType = COLLIDE_BlockAll
	Components.Add(EngineMeshComponent)

	SupportedEvents.Add(class'SeqEvent_RestorePower')
	SupportedEvents.Add(class'SeqEvent_PowerOff')
	
	Begin Object Class=SkeletalMeshComponent Name=EngineSKMeshComponent
		SkeletalMesh=SkeletalMesh'Engine_1.Mesh.Engine_1_SK'
		AnimTreeTemplate=AnimTree'Engine_1.AnimTree.Engine_AnimTree'
		AnimSets(0)=AnimSet'Engine_1.AnimSet.Engine_1_SK_AnimSet'
		//PhysicsAsset=PhysicsAsset'Human1.Physics.Human1_Mesh_Physics'
		HiddenEditor=true
	End Object
	Mesh = EngineSKMeshComponent
	Components.Add(EngineSKMeshComponent)
}
