class ShipPawn extends UTPawn;

var float CamOffsetDistance; //distance to offset the camera from the player
var int IsoCamAngle; //pitch angle of the camera
var bool bWorldView;//if true, then in WorldView(topDown)
var bool bSprinting;
var repnotify float theAcceleration;

var Hallway HallwayActor;

var bool    bPressingForwards;
var bool    bPressingBackwards;

var bool    bFlashLightEnabled;

var bool bStrafingRight, bStrafingLeft;
/** PX: Whether Player is currently strafing Left(holding A for players usually)
 *  */

/** PX: By how much the pawns groundspeed is multiplied by when sprinting (Default 5.5)
 *  */
var float SprintSpeedMultiplier;

var SpotLightComponent MyLight;
var PointLightComponent MyLight2;

var StaticMeshComponent BeamMesh;

replication
{
	// replicated properties
	if (bNetDirty)
		theAcceleration;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	//Mesh.AttachComponentToSocket(MyLight, 'Light_Socket');
	//Mesh.AttachComponentToSocket(MyLight2, 'Light_Socket');
	//Mesh.AttachComponentToSocket(BeamMesh, 'Beam_Socket');
	BeamMesh.SetScale(0.25);
	BeamMesh.SetHidden(true);
}

exec function CreateShip(){
	local Rotator ShipRotation;

	ShipRotation.Pitch =0;
	ShipRotation.Yaw = 0;
	ShipRotation.Roll = 0;
    
	HallwayActor = Spawn(class'Hallway', , , Location, ShipRotation);
}

/*
exec function SpawnHallwayBottomRightCorridor(){
	HallwayActor.CreateBottomRightCorridor();
}
exec function SpawnHallwayBottomLeftCorridor(){
	HallwayActor.CreateBottomLeftCorridor();
}
exec function SpawnHallwayTopRightCorridor(){
	HallwayActor.CreateTopRightCorridor();
}
exec function SpawnHallwayTopLeftCorridor(){
	HallwayActor.CreateTopLeftCorridor();
}*/

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         SetMeshVisibility(UTPC.bBehindView); 
         UTPC.bNoCrosshair = true;
      }
   }
}

simulated event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	CalcAcceleration();
}

//state WorldView{
	
	simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV ){
	   out_CamLoc = Location;
	   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
	   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

	   out_CamRot.Pitch = -1 * IsoCamAngle;   
	   out_CamRot.Yaw = 0;
	   out_CamRot.Roll = 0;

		return true;
	}

//}

/*
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   out_CamLoc = Location;
   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

   out_CamRot.Pitch = -1 * IsoCamAngle;   
   out_CamRot.Yaw = 0;
   out_CamRot.Roll = 0;

   return true;
}

simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0;

   return POVRot;
}   */

function bool CheckMoving()//Checks to see if you are moving or not
{
	return (Vsize(Velocity) != 0); 
}

//////// FUNCTIONS THAT HANDLE BOOLS FOR HOLDING BUTTONS!!!!////////////

exec function PressWorldView(){
	bWorldView = !bWorldView;
	if(bWorldView){
		GotoState('WorldView');
		SController(Controller).GotoState('WorldView');
	}
	else
		GotoState('PlayerWalking');
		SController(Controller).GotoState('PlayerWalking');
}

exec function PressForwards(){
	SetPressForwards(true);
}

simulated function SetPressForwards(bool bForwards)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressForwards(bForwards);
	}

	bPressingForwards = bForwards;
}

reliable server function ServerSetPressForwards(bool bForwards)
{
	bPressingForwards = bForwards;
}

exec function StopPressForwards()
{
	SetPressForwards(false);
}

exec function PressBackwards()
{
	SetPressBackwards(true);
}

simulated function SetPressBackwards(bool bBackwards)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressBackwards(bBackwards);
	}

	bPressingBackwards = bBackwards;
}

reliable server function ServerSetPressBackwards(bool bBackwards)
{
	bPressingBackwards = bBackwards;
}

exec function StopPressBackwards()
{
	SetPressBackwards(false);
}

exec function StrafeLookLeft()
{
	SetStrafeLeft(true);
}

simulated function SetStrafeLeft(bool bStrafeLeft)
{
	if(Role < ROLE_Authority)
	{
		ServerSetStrafeLeft(bStrafeLeft);
	}
	bStrafingLeft = bStrafeLeft;
}

reliable server function ServerSetStrafeLeft(bool bStrafeLeft)
{
	bStrafingLeft = bStrafeLeft;
}

exec function StopStrafeLeft()
{
	SetStrafeLeft(false);
}

exec function StrafeLookRight()
{
	SetStrafeRight(true);
}

exec function SetCameraOffsetDistance(float OffsetDistance)
{
	CamOffsetDistance = OffsetDistance;
}

simulated function SetStrafeRight(bool bStrafeRight)
{
	if(Role < ROLE_Authority)
	{
		ServerSetStrafeRight(bStrafeRight);
	}
	bStrafingRight = bStrafeRight;
}

reliable server function ServerSetStrafeRight(bool bStrafeRight)
{
	bStrafingRight = bStrafeRight;
}

exec function StopStrafeRight()
{
	SetStrafeRight(false);
}

///////////////////////////////////////////////////////
//////////////////////////////////////////////////////

simulated function CalcAcceleration()
{
	local int speedMax;

	if(CheckMoving())
	{
		if(bSprinting && !bPressingBackwards && !bStrafingRight && !bStrafingLeft)
		{
			speedMax = default.GroundSpeed * SprintSpeedMultiplier;
		}
		else
		{
			speedMax = default.GroundSpeed;
		}
		
		if((theAcceleration + 10) < speedMax)
		{
			theAcceleration += 10;
		}
		else
		{
			theAcceleration = speedMax;
		}
	}
	else
	{
		if((theAcceleration - 50) > 5)
		{
			theAcceleration -= 50;
		}
		else
		{
			theAcceleration = 5;
		}
	}
		
	GroundSpeed = theAcceleration;

	/*
	if(speedMax > 0)
	{
		if(WalkSpeedBlendVar != none)
			WalkSpeedBlendVar.SetBlendTarget(TheAcceleration/speedMax, 0.1);
		if(SprintSpeedBlendVar != none)
			SprintSpeedBLendVar.SetBlendTarget(TheAcceleration/speedMax, 0.1);
	}*/
}

exec function StartSprint()
{
	SetSprint(true);
}

exec function StopSprint()
{
	SetSprint(false);
}

reliable server function ServerSetSprint(bool bSprint)
{
	SetSprint(bSprint);
}

simulated function SetSprint(bool bSprint)
{
	if(Role < ROLE_Authority)
	{
		ServerSetSprint(bSprint);
	}

	bSprinting = bSprint;
}

exec function ToggleTheFlashLight()
{
	bFlashLightEnabled = !bFlashLightEnabled;

	MyLight.SetEnabled(bFlashLightEnabled);
	MyLight2.SetEnabled(bFlashLightEnabled);
	BeamMesh.SetHidden(!bFlashLightEnabled);
}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
}


simulated function PlayAttack(bool bAttack)
{

}

simulated function SeeEnemyReaction()
{

}

simulated function EndSeeEnemyReaction()
{

}

defaultproperties
{
	bWorldView = false
	HallwayActor = none

	DrawScale = 1

   IsoCamAngle=15000//6420 //35.264 degrees
   CamOffsetDistance=2000.0

	CamOffset=(X=10,Y=30,Z=-5.0)

	GroundSpeed=75
	SprintSpeedMultiplier=3

	bSprinting = false

	bStrafingRight = false
	bStrafingLeft = false
	bPressingForwards = false
	bPressingBackwards = false
	bPushesRigidBodies=true
	bEnableFootPlacement = FALSE//*****WHOAAAAA Doesn't seem important, but if you don't have this as false, then your pawn as well as AI controlled pawns will sink into the ground.
								//Probably enable if you end up using foot placement stuff though :3
	bFlashLightEnabled = false

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0015.000000
		CollisionHeight=+0025.000000
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'Human1.Mesh.Humanoid1_SK'
		AnimTreeTemplate=AnimTree'Human1.AnimTree.Human1_AnimTree'
		AnimSets(0)=AnimSet'Human1.AnimSet.Humanoid1_AnimSet'
		PhysicsAsset=PhysicsAsset'MaleBase.Physics.MaleBase_Physics'
	End Object

		// Create the light function in script
	Begin Object Class=LightFunction Name=MyLightFunction
		SourceMaterial=Material'PXFlashLight.FlashLight_Pattern1_mat'
		Scale = (X=512, Y=512, Z=512)
	End Object


	Begin Object class=SpotLightComponent name=HeadLightComponentR
		LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING

	    CastShadows=TRUE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=TRUE
	    bForceDynamicLight=TRUE
	    UseDirectLightMap=FALSE
		
		Function = MyLightFunction

		LightColor=(R=203,G=231,B=203)
		bEnabled=false
		Radius=512//40000.000000
		FalloffExponent=2//200.000000
		Brightness = 3//2
		bCastCompositeShadow=True
		bAffectCompositeShadowDirection=True
		bRenderLightShafts = false
		LightShadowMode=LightShadow_Normal//LightShadow_Modulate
		//LightShaftConeAngle = 89
		OcclusionDepthRange = 1
		BloomScale = 0.1
		BloomTint = (B=219,G=248,R=255,A=0)
		RadialBlurPercent = 0.3
		InnerConeAngle = 10
		OuterConeAngle = 35
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE,Skybox=FALSE,bInitialized=TRUE)
		//Translation=(Y=-37,X=105, Z=-1.5)
	End Object
	MyLight=HeadLightComponentR
	Components.Add(HeadLightComponentR)

	Begin Object class=PointLightComponent name=PointLightComponentR
       LightColor=(R=203,G=231,B=203)
       CastShadows=False
       bEnabled=false
       Radius=128//4000.000000
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
	MyLight2 = PointLightComponentR
	Components.Add(PointLightComponentR)

	Begin Object Class=StaticMeshComponent Name=Beam
	//bCacheAnimSequenceNodes=FALSE
		StaticMesh=StaticMesh'PXFlashLight.LightBeam.Beam2'
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=false
		CastShadow=false
		BlockRigidBody=false
		//Rotation=(Pitch=0,Yaw=0,Roll=0)
	End Object
	Components.Add(Beam)
	BeamMesh = Beam
}