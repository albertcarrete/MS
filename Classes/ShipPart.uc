class ShipPart extends InterpActor;

var Ship ShipOwner;
var ShipPart LastPiece;
var ShipPart PartOwner;
var S_Pawn PawnOwner;

var bool bIsWeapon;

var Actor PilotingControlsActor;

var StaticMeshComponent SMesh;
var MaterialInstance MatDefaultInst;
var MaterialInstance MatDefaultInst1;
var MaterialInstance MatDefaultInst2;
var MaterialInstance MatDefaultInst3;

var bool bGlowing;

simulated event PostBeginPlay(){
	//InitMat();
}

function BaseToOwner(){
	if(ShipOwner != none)
		SetBase(ShipOwner);
}

simulated function InitMat()
{
	MatDefaultInst = new(none) class'MaterialInstanceConstant';
	MatDefaultInst1 = new(none) class'MaterialInstanceConstant';
	MatDefaultInst2 = new(none) class'MaterialInstanceConstant';
	MatDefaultInst3 = new(none) class'MaterialInstanceConstant';
	
	MatDefaultInst.SetParent(SMesh.GetMaterial(0).GetMaterial());
	SMesh.SetMaterial(0, MatDefaultInst);
	MatDefaultInst1.SetParent(SMesh.GetMaterial(1).GetMaterial());
	SMesh.SetMaterial(1, MatDefaultInst);
	MatDefaultInst2.SetParent(SMesh.GetMaterial(2).GetMaterial());
	SMesh.SetMaterial(2, MatDefaultInst);
	MatDefaultInst3.SetParent(SMesh.GetMaterial(3).GetMaterial());
	SMesh.SetMaterial(3, MatDefaultInst);
}

simulated function StartGlow()
{
		MatDefaultInst.SetScalarParameterValue('Glow_Amount', 0.1);
}

simulated function StopGlow()
{
		MatDefaultInst.SetScalarParameterValue('Glow_Amount', 0);
}

function StartFire();

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){

	if(DamageType == class'SDmgType_ShipDamage')
		ShipOwner.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

DefaultProperties
{
	bAlwaysRelevant=true

	bIsWeapon = false
	PartOwner = none

	bStatic = false
	bIgnoreEncroachers = true
	bCollideActors = true
	bBlockActors = true
	LastPiece = none
	bGlowing = false

	BlockRigidBody=true
	bMovable=true
	bNoDelete = false;

	Begin Object Class=StaticMeshComponent Name=ShipPartStaticMeshComponent
		StaticMesh=StaticMesh'Placeholders.Meshes.CorridorA_18BLOCK'
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		RBCollideWithChannels=(Pawn=true, Default = true, GameplayPhysics = true,Untitled1 = false)
		RBChannel = RBCC_Untitled1
	End Object
	SMesh=ShipPartStaticMeshComponent
	Components.Add(ShipPartStaticMeshComponent)


	CollisionType = COLLIDE_BlockAll
	CollisionComponent = ShipPartStaticMeshComponent
}
