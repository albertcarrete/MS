class JetPackFlame extends Actor;

var ParticleSystemComponent JetPackFlameComponent;

DefaultProperties
{
	Begin Object Class=ParticleSystemComponent Name=JetPackParticleSystemComponent
		Template = ParticleSystem'PXParticleSystems.Dust.Ember2'
		AbsoluteTranslation=true
 		AbsoluteRotation=true
		SecondsBeforeInactive=0.0
	End Object
	Components.Add(JetPackParticleSystemComponent);
	JetPackFlameComponent=JetPackParticleSystemComponent
}
