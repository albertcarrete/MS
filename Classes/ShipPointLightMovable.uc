class ShipPointLightMovable extends PointLightMovable;

var PointLightComponent theLight;

DefaultProperties
{
		// Light component.
	Begin Object Name=PointLightComponent0
	    LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING

		bEnabled = true
		Radius=550

		Brightness=3

	    CastShadows=FALSE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=TRUE
	    bForceDynamicLight=FALSE
	    UseDirectLightMap=FALSE

	    LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
	End Object
	theLight = PointLightComponent0

	bNoDelete = false
	
    //for use with actor.move()
    bCollideActors = false
	bCollideWorld = false
}
