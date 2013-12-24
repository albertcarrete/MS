class SelectionCircle extends ShipPart;

var SkeletalMeshComponent CircleMesh;

var MaterialInstance CircleInst;

simulated event PostBeginPlay(){
	SetCollision(false, false, false);
}

function SetPawnOwner(S_Pawn PO){
	PawnOwner = PO;

	if(SController(PawnOwner.Controller).bIsEnemy)
		ChangeColor(1, 0, 0, 1);
	else
		ChangeColor(0, 1, 0, 1);
}

function ChangeColor(float red, float green, float blue, float alpha){
	local LinearColor theColor;

	theColor = MakeLinearColor(red, green, blue, alpha);
	
	CircleInst = new(none) class'MaterialInstanceConstant';

	CircleInst.SetParent(CircleMesh.GetMaterial(0).GetMaterial());
	
	CircleMesh.SetMaterial(0, CircleInst);
	CircleInst.SetVectorParameterValue('Color',theColor);
}

DefaultProperties
{
	DrawScale = 15
	bHardAttach = true

	Components.Remove(ShipPartStaticMeshComponent)

	Begin Object Class=SkeletalMeshComponent Name=SelectionCircleSkeletalMesh
		SkeletalMesh=SkeletalMesh'ShipA.Meshes.SelectionCircle1'
	End Object
	CollisionComponent = none

	CircleMesh = SelectionCircleSkeletalMesh
	Components.Add(SelectionCircleSkeletalMesh)

	CollisionType = COLLIDE_NoCollision
}
