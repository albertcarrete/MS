class RoomLight extends Actor;

var PointLightComponent TheLight;

function SetLightEnabled(bool bEnabled){
	TheLight.SetEnabled(bEnabled);
}

DefaultProperties
{
	Begin Object class=PointLightComponent name=PointLightComponentR
       LightColor=(R=203,G=231,B=203)
       CastShadows=False
       bEnabled=false
       Radius=4000.000000
       FalloffExponent=15//200.000000
       Brightness = 1
		//CastShadows=True
		CastStaticShadows=True
       CastDynamicShadows=True
       bCastCompositeShadow=True
       bAffectCompositeShadowDirection=True
	   bRenderLightShafts = false
		LightShadowMode=LightShadow_Normal
		//LightShaftConeAngle = 89
		OcclusionDepthRange = 1
		BloomScale = 0.1
		BloomTint = (B=219,G=248,R=255,A=0)
		RadialBlurPercent = 0.3
		//InnerConeAngle = 10
		//OuterConeAngle = 2
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE,Skybox=FALSE,bInitialized=TRUE)

		Translation=(Y=0,X=10, Z=30)
	End Object
	TheLight = PointLightComponentR
	Components.Add(PointLightComponentR)
}
