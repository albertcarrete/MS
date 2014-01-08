class SProj_Infantry extends S_Projectile;

function Init(vector Direction){
	local Rotator tempRot;
	local Vector X, Y , Z, tempVel;
	
	if(WeaponOwner != none){
		
		//tempRot = rotator(Direction);
		//tempRot.Yaw += WeaponOwner.ShipOwner.TurnMagnitude/2;
		
		SetRotation(rotator(Direction));
		
		//GetAxes(tempRot, X, Y, Z);

		Velocity = (Speed + ( WeaponOwner.ShipOwner.ShipMovementSpeed)/2) * Direction;

	}else if(InfantryWeaponOwner != none){

		//VSize(InfantryWeaponOwner.Velocity).

		SetRotation(rotator(Direction));
		tempVel = (Speed * Direction);
		tempVel += InfantryWeaponOwner.Owner.Velocity;
		Velocity = tempVel;

	}else{
		SetRotation(rotator(Direction));
		Velocity = Speed * Direction;
	}

	Velocity.Z += TossZ;
	Acceleration = Velocity;//AccelRate * Normal(Velocity);
}

DefaultProperties
{
	MyDamageType=class'UTDmgType_LinkPlasma'

	AccelRate=10000

	Speed=4000
	MaxSpeed = 0
	DrawScale=1.2
}

