class S_ShipCannonProj extends S_Projectile;

function Init(vector Direction){
	local Rotator tempRot;
	local Vector X, Y , Z;
	
	if(WeaponOwner != none){
		
		//tempRot = rotator(Direction);
		//tempRot.Yaw += WeaponOwner.ShipOwner.TurnMagnitude/2;
		
		SetRotation(rotator(Direction));
		
		//GetAxes(tempRot, X, Y, Z);

		Velocity = (Speed + ( WeaponOwner.ShipOwner.ShipMovementSpeed)/2) * Direction;

		
	}else{
		SetRotation(rotator(Direction));
		Velocity = Speed * Direction;
	}

	Velocity.Z += TossZ;
	Acceleration = Velocity;//AccelRate * Normal(Velocity);
}

DefaultProperties
{
	MyDamageType=class'SDmgType_ShipDamage'

	AccelRate=10000

	Speed=4000
	MaxSpeed = 0
	DrawScale = 10
}
