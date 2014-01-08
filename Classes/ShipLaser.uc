class ShipLaser extends ShipWeapon;

var ParticleSystemComponent LaserComponent;
var ParticleSystem LaserParticleSystem;

var bool bFiring;

simulated event PostBeginPlay(){
	LaserComponent = new () class'ParticleSystemComponent';
		
		
	LaserComponent.SetScale(5);
	LaserComponent.SetTemplate(LaserParticleSystem);
	AttachComponent(LaserComponent);
}

event Tick(float DeltaTime){
	
	local Vector laserTarget, X, Y, Z;
	

	if(bFiring){
		LaserComponent.SetVectorParameter('TetherSource', self.Location);

		if(ShipOwner.EnemyShip != none){
		
			laserTarget = ShipOwner.EnemyShip.Location;
			LaserComponent.SetVectorParameter('TetherEnd', laserTarget);
		

		}else{
			GetAxes(Rotation, X, Y, Z);

			laserTarget = Location + Y * 2000;
			LaserComponent.SetVectorParameter('TetherEnd', laserTarget);
		}

		LaserComponent.ForceUpdate(false);
	}
}

function StartFire(){
	if(ShipOwner.bWeaponsOn){
		SpawnLaser();
		PlaySound(SoundCue'ProjectSSounds.LaserSounds.pew1_Cue', false, false, false);
	}
}

simulated function SpawnLaser(){

	bFiring = true;
	LaserComponent.SetActive(true);
	SetTimer(1.5, false, 'DeactivateLaser');
}

simulated function DeactivateLaser(){
	bFiring = false;
	LaserComponent.SetActive(false);
}

DefaultProperties
{
	bFiring=false
	//DrawScale = 1

	LaserParticleSystem = ParticleSystem'PXParticleSystems.TestBeam'
}
