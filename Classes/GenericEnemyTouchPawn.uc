class GenericEnemyTouchPawn extends S_Pawn;

event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	Super.Bump(Other, OtherComp, HitNormal );

	if(Other.IsA('S_Pawn'))
	{
		if(S_Pawn(Other).Controller.bIsPlayer)
		{
			S_Pawn(Other).TakeDamage(10, self.Controller, Location, Location, none);
		}
	}
}

DefaultProperties
{

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'Human1.Mesh.Human1_2_Mesh'
		AnimTreeTemplate=AnimTree'Human1.AnimTree.Human1_AnimTree'
		AnimSets(0)=AnimSet'Human1.AnimSet.Human1_AnimSet'
		PhysicsAsset=PhysicsAsset'Human1.Physics.Human1_Mesh_Physics'
	End Object
}
