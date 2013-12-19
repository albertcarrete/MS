class SPlayer_Pawn extends S_Pawn;

var LinearColor GlossColor;
var LinearColor FirstColor;
var LinearColor SecondColor;
var LinearColor LightColor;
var LinearColor BladeColor;

var ArmorList theArmorList;

var bool bAiming;

/** used to keep track of melee combos*/
var int currentmeleeNum;

var AudioComponent BladeAC;

var bool bAllowJump;

var ParticleSystem JetPackParticleSystem;
var JetPackFlame FlameActor;
var JetPackFlame FlameActor2;
var ParticleSystemComponent JetPackComponent;
var ParticleSystemComponent JetPackComponent2;

var AudioComponent JetPackAC;

var PointLightComponent JetPackLight;

var array<Armor> ArmorArray;

var class<Armor> HelmetClass;

var class<Armor> ChestPieceClass;
var class<Armor> BackPieceClass;

var class<Armor> R_ClavicleClass;
var class<Armor> L_ClavicleClass;
var class<Armor> R_ShoulderClass;
var class<Armor> L_ShoulderClass;
var class<Armor> R_UpperArmClass;
var class<Armor> L_UpperArmClass;
var class<Armor> R_BicepClass;
var class<Armor> L_BicepClass;
var class<Armor> R_ForeArmClass;
var class<Armor> L_ForeArmClass;
var class<Armor> R_HandClass;
var class<Armor> L_HandClass;

var class<Armor> Waist2Class;
var class<Armor> Waist1Class;

var class<Armor> R_ThighClass;
var class<Armor> L_ThighClass;
var class<Armor> R_KneeClass;
var class<Armor> L_KneeClass;
var class<Armor> R_CalfClass;
var class<Armor> L_CalfClass;
var class<Armor> R_FootClass;
var class<Armor> L_FootClass;

var class<Armor> MeleeBladeClass;
var class<Armor> ShieldClass;

var Armor HelmetActor;
var Armor ChestPieceActor;
var Armor BackPieceActor;

var Armor R_ClavicleActor;
var Armor L_ClavicleActor;
var Armor R_ShoulderActor;
var Armor L_ShoulderActor;
var Armor R_UpperArmActor;
var Armor L_UpperArmActor;
var Armor R_BicepActor;
var Armor L_BicepActor;
var Armor R_ForeArmActor;
var Armor L_ForeArmActor;
var Armor R_HandActor;
var Armor L_HandActor;

var Armor Waist1Actor;
var Armor Waist2Actor;

var Armor R_ThighActor;
var Armor L_ThighActor;
var Armor R_KneeActor;
var Armor L_KneeActor;
var Armor R_CalfActor;
var Armor L_CalfActor;
var Armor R_FootActor;
var Armor L_FootActor;

var Armor MeleeBladeActor;
var Armor ShieldActor;

var PointLightComponent MyLight2;

var StaticMeshComponent BeamMesh;

simulated function PostBeginPlay(){

	Super.PostBeginPlay();
	Mesh.AttachComponentToSocket(MyLight, 'Light_Socket');
	Mesh.AttachComponentToSocket(MyLight2, 'Light_Socket');
	Mesh.AttachComponentToSocket(BeamMesh, 'Beam_Socket');
	BeamMesh.SetScale(0.25);
	BeamMesh.SetHidden(true);
	SetUpArmor();

	theArmorList = Spawn(class'ArmorList');

	UpdateColors();
	RandomizeColors();
}

function AddDefaultInventory()
{

}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);
/*
	if (SkelComp == Mesh){
		LeftArmAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('LeftArmSlot'));
		RightArmAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('RightArmSlot'));
		TorsoAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('TorsoSlot'));
		ArmsAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('ArmsSlot'));
		HeadAnimSlot = SAnimNodeSlotMirror(Mesh.FindAnimNode('HeadSlot'));

		DriveBlend = AnimNodeBlend(Mesh.FindAnimNode('DriveBlend'));
	}*/
}

simulated function bool CalcThirdPersonCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset, ChestPieceLoc, ChestPieceRot, ChestX, ChestY, ChestZ;
	local float DesiredCameraZOffset;

	ModifyRotForDebugFreeCam(out_CamRot);
	//Mesh.GetSocketWorldLocationAndRotation('ChestPiece_Socket', ChestPieceLoc, ChestPieceRot);
	//GetAxes(ChestPieceRot, ChestX, ChestY, ChestZ);

	CamStart = Location;
	CurrentCamOffset = CamOffset;

	if ( bWinnerCam )
	{
		// use "hero" cam
		SetHeroCam(out_CamRot);
		CurrentCamOffset = vect(0,0,0);
		CurrentCamOffset.X = GetCollisionRadius();
	}
	else
	{
		DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
		CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
		if ( Health <= 0 )
		{
			CurrentCamOffset = vect(0,0,0);
			CurrentCamOffset.X = GetCollisionRadius();
		}
	}
	CamStart.Z += CameraZOffset;
	GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
	CamDirX *= CurrentCameraScale;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// adjust camera position to make sure it's not clipping into world
		// @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
		FindSpot(GetCollisionExtent(),CamStart);
	}
	if (CurrentCameraScale < CameraScale)
	{
		CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	else if (CurrentCameraScale > CameraScale)
	{
		CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	if (CamDirX.Z > GetCollisionHeight())
	{
		CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
	}
	out_CamLoc = CamStart - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;
	if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
	{
		out_CamLoc = HitLocation;
		return false;
	}
	return true;
}

function SetHelmet(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 0, 'Helmet_Socket');
}

function SetChest(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 1, 'ChestPiece_Socket');
}

function SetR_Clavicle(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 2, 'R_Clavicle_Socket');
}

function SetL_Clavicle(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 3, 'L_Clavicle_Socket');
}

function SetR_Shoulder(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 4, 'R_Shoulder_Socket');
}

function SetL_Shoulder(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 5, 'L_Shoulder_Socket');
}

function SetR_UpperArm(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 6, 'R_UpperArm_Socket');
}

function SetL_UpperArm(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 7, 'L_UpperArm_Socket');
}

function SetR_Bicep(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 8, 'R_Bicep_Socket');
}

function SetL_Bicep(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 9, 'L_Bicep_Socket');
}

function SetR_ForeArm(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 10, 'R_ForeArm_Socket');
}

function SetL_ForeArm(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 11, 'L_ForeArm_Socket');
}

function SetR_Hand(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 12, 'R_Hand_Socket');
}

function SetL_Hand(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 13, 'L_Hand_Socket');
}

function SetBack(class<Armor> ArmorClass){
	
	SetArmor(ArmorClass, 14, 'Back_Socket');
}

function SetWaist2(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 15, 'Waist_Socket_2');
}

function SetWaist(class<Armor> ArmorClass){
	
	SetArmor(ArmorClass, 16, 'Waist1_Socket');
}

function SetR_Thigh(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 17, 'R_Thigh_Socket');
}

function SetL_Thigh(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 18, 'L_Thigh_Socket');
}

function SetR_Knee(class<Armor> ArmorClass){
	
	SetArmor(ArmorClass, 19, 'R_Knee_Socket');
}

function SetL_Knee(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 20, 'L_Knee_Socket');
}

function SetR_Calf(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 21, 'R_Calf_Socket');
}

function SetL_Calf(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 22, 'L_Calf_Socket');
}

function SetR_Foot(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 23, 'R_Foot_Socket');
}

function SetL_Foot(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 24, 'L_Foot_Socket');
}

function SetMeleeBlade(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 25, 'R_ForeArm_Socket');

}

function SetShield(class<Armor> ArmorClass){

	SetArmor(ArmorClass, 26, 'L_ForeArm_Socket');

}

function SetArmor(class<Armor> ArmorClass, int ArmorActorInt, name socketName){
	local Vector tempLocation;
	local Rotator tempRotation;

	Mesh.GetSocketWorldLocationAndRotation(socketName, tempLocation, tempRotation);

	switch(ArmorActorInt){
	
	case 0:
		if(HelmetActor != none){
			HelmetActor.Destroy();
			ClientMessage("Helmet Deleted");
		}
		HelmetActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		ArmorArray[ArmorActorInt] = HelmetActor;
		Mesh.AttachComponentToSocket(HelmetActor.ArmorMesh, socketName);
		HelmetActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 1:
		if(ChestPieceActor != none)
			ChestPieceActor.Destroy();
		ChestPieceActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(ChestPieceActor.ArmorMesh, socketName);
		ChestPieceActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 2:
		if(R_ClavicleActor != none)
			R_ClavicleActor.Destroy();
		R_ClavicleActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_ClavicleActor.ArmorMesh, socketName);
		R_ClavicleActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 3:
		if(L_ClavicleActor != none)
			L_ClavicleActor.Destroy();
		L_ClavicleActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_ClavicleActor.ArmorMesh, socketName);
		L_ClavicleActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 4:
		if(R_ShoulderActor != none)
			R_ShoulderActor.Destroy();
		R_ShoulderActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_ShoulderActor.ArmorMesh, socketName);
		R_ShoulderActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 5:
		if(L_ShoulderActor != none)
			L_ShoulderActor.Destroy();
		L_ShoulderActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_ShoulderActor.ArmorMesh, socketName);
		L_ShoulderActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 6:
		if(R_UpperArmActor != none)
			R_UpperArmActor.Destroy();
		R_UpperArmActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_UpperArmActor.ArmorMesh, socketName);
		R_UpperArmActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 7:
		if(L_UpperArmActor != none)
			L_UpperArmActor.Destroy();
		L_UpperArmActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_UpperArmActor.ArmorMesh, socketName);
		L_UpperArmActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 8:
		if(R_BicepActor != none)
			R_BicepActor.Destroy();
		R_BicepActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_BicepActor.ArmorMesh, socketName);
		R_BicepActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 9:
		if(L_BicepActor != none)
			L_BicepActor.Destroy();
		L_BicepActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_BicepActor.ArmorMesh, socketName);
		L_BicepActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 10:
		if(R_ForeArmActor != none)
			R_ForeArmActor.Destroy();
		R_ForeArmActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_ForeArmActor.ArmorMesh, socketName);
		R_ForeArmActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 11:
		if(L_ForeArmActor != none)
			L_ForeArmActor.Destroy();
		L_ForeArmActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_ForeArmActor.ArmorMesh, socketName);
		L_ForeArmActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 12:
		if(R_HandActor != none)
			R_HandActor.Destroy();
		R_HandActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_HandActor.ArmorMesh, socketName);
		R_HandActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 13:
		if(L_HandActor != none)
			L_HandActor.Destroy();
		L_HandActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_HandActor.ArmorMesh, socketName);
		L_HandActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 14:
		if(BackPieceActor != none)
			BackPieceActor.Destroy();
		BackPieceActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(BackPieceActor.ArmorMesh, socketName);
		BackPieceActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 15:
		if(Waist2Actor != none)
			Waist2Actor.Destroy();
		Waist2Actor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(Waist2Actor.ArmorMesh, socketName);
		Waist2Actor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 16:
		if(Waist1Actor != none)
			Waist1Actor.Destroy();
		Waist1Actor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(Waist1Actor.ArmorMesh, socketName);
		Waist1Actor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 17:
		if(R_ThighActor != none)
			R_ThighActor.Destroy();
		R_ThighActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_ThighActor.ArmorMesh, socketName);
		R_ThighActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 18:
		if(L_ThighActor != none)
			L_ThighActor.Destroy();
		L_ThighActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_ThighActor.ArmorMesh, socketName);
		L_ThighActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 19:
		if(R_KneeActor != none)
			R_KneeActor.Destroy();
		R_KneeActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_KneeActor.ArmorMesh, socketName);
		R_KneeActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 20:
		if(L_KneeActor != none)
			L_KneeActor.Destroy();
		L_KneeActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_KneeActor.ArmorMesh, socketName);
		L_KneeActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 21:
		if(R_CalfActor != none)
			R_CalfActor.Destroy();
		R_CalfActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_CalfActor.ArmorMesh, socketName);
		R_CalfActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 22:
		if(L_CalfActor != none)
			L_CalfActor.Destroy();
		L_CalfActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_CalfActor.ArmorMesh, socketName);
		L_CalfActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 23:
		if(R_FootActor != none)
			R_FootActor.Destroy();
		R_FootActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(R_FootActor.ArmorMesh, socketName);
		R_FootActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 24:
		if(L_FootActor != none)
			L_FootActor.Destroy();
		L_FootActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(L_FootActor.ArmorMesh, socketName);
		L_FootActor.ArmorMesh.SetShadowParent(Mesh);
		break;
	case 25:
		if(MeleeBladeActor != none)
			MeleeBladeActor.Destroy();
		MeleeBladeActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(MeleeBladeActor.ArmorMesh, socketName);
		MeleeBladeActor.ArmorMesh.SetShadowParent(Mesh);
		MeleeBladeActor.ArmorMesh.SetHidden(true);
		break;
	case 26:
		if(ShieldActor != none)
			ShieldActor.Destroy();
		ShieldActor = Spawn(ArmorClass, , , tempLocation, tempRotation);
		Mesh.AttachComponentToSocket(ShieldActor.ArmorMesh, socketName);
		ShieldActor.ArmorMesh.SetShadowParent(Mesh);
		ShieldActor.ArmorMesh.SetHidden(true);
		break;
	default:
		`log("Could not attach armor!!!!!!");
	}

	UpdateColors();
		
	WorldInfo.ForceGarbageCollection();
}

simulated function StartFire(byte FireModeNum){
	
	local Vector X, Y, Z, tempVel;
	local Rotator tempRot;

	// firing cancels feign death
	if (bFeigningDeath)
		FeignDeath();
	else if(bDrivingShip)
		ShipActor.FireAllWeapons();
	else{
		// firing cancels feign death
		if (bFeigningDeath)
		{
			FeignDeath();
		}
		else
		{
			if( bNoWeaponFIring )
			{
				return;
			}

			if( Weapon != None )
			{
				Weapon.StartFire(FireModeNum);
			}else if(!bPlayingMelee || bAllowNextMelee){

					SetTimer(0.6, false, 'DeactivateBlade');
					SetTimer(0.3, false, 'AllowNextMelee');
					
					if(currentmeleeNum == 0){
						FullAnimSlot.PlayCustomMirrorAnim('H_MeleeBladeAttack_2', 4, , 0.1, 0.2);
						currentmeleeNum++;
					}
					else{
						FullAnimSlot.PlayCustomMirrorAnim('H_MeleeBladeAttack_1', 4, , 0.25, 0.2);
						currentmeleeNum = 0;
					}

					bPlayingMelee = true;
					bAllowNextMelee = false;

					tempRot = Controller.Rotation;
					
					if(Physics == PHYS_Walking)
						tempRot.Pitch = 0;
					
					//tempRot.Roll = 0;
					GetAxes(tempRot, X, Y ,Z);
					tempVel = X*500;
						
					if(bExperiencingGravity){
						SetPhysics(PHYS_Falling);
						tempVel+= GravityDirection * -100;
					}
						
					Velocity += tempVel;      

					//MELEE BLADE STUFF!!

			}
			
		}
	}
}

simulated function ActivateBlade(){
	MeleeBladeActor.ArmorMesh.SetHidden(false);
	BladeAC.Stop();
	BladeAC.Play();
}

simulated function DeactivateBlade(){
	bPlayingMelee = false;
	MeleeBladeActor.ArmorMesh.SetHidden(true);
	currentmeleeNum = 0;
}

function AllowNextMelee(){
	bAllowNextMelee = true;
}

function SetUpArmor(){
	local Vector tempLocation;
	local Rotator tempRotation;

	SetHelmet(HelmetClass);
	SetChest(ChestPieceClass);
	SetR_Clavicle(R_ClavicleClass);
	SetL_Clavicle(L_ClavicleClass);
	SetR_Shoulder(R_ShoulderClass);
	SetL_Shoulder(L_ShoulderClass);
	SetR_Bicep(R_BicepClass);
	SetL_Bicep(L_BicepClass);
	SetR_ForeArm(R_ForeArmClass);
	SetL_ForeArm(L_ForeArmClass);
	SetR_Hand(R_HandClass);
	SetL_Hand(L_HandClass);
	SetBack(BackPieceClass);
	SetWaist2(Waist2Class);
	SetWaist(Waist1Class);
	SetR_Thigh(R_ThighClass);
	SetL_Thigh(L_ThighClass);
	SetR_Knee(R_KneeClass);
	SetL_Knee(L_KneeClass);
	SetR_Calf(R_CalfClass);
	SetL_Calf(L_CalfClass);
	SetR_Foot(R_FootClass);
	SetL_Foot(L_FootClass);

	SetMeleeBlade(class'MeleeBlade');
	SetShield(ShieldClass);


	JetPackComponent = new () class'ParticleSystemComponent';
	JetPackComponent.SetTemplate(JetPackParticleSystem);
	Mesh.GetSocketWorldLocationAndRotation('JetPack_Socket', tempLocation, tempRotation);
	Mesh.AttachComponentToSocket(JetPackComponent , 'JetPack_Socket');

	JetPackComponent2 = new () class'ParticleSystemComponent';
	JetPackComponent2.SetTemplate(JetPackParticleSystem);
	Mesh.GetSocketWorldLocationAndRotation('JetPack_Socket_2', tempLocation, tempRotation);
	Mesh.AttachComponentToSocket(JetPackComponent2 , 'JetPack_Socket_2');

	JetPackComponent.SetActive(false);
	JetPackComponent2.SetActive(false);

	Mesh.GetSocketWorldLocationAndRotation('JetPackLight_Socket', tempLocation, tempRotation);
	Mesh.AttachComponentToSocket(JetPackLight , 'JetPackLight_Socket');

	ArmorArray.AddItem(HelmetActor);
	ArmorArray.AddItem(ChestPieceActor);
	ArmorArray.AddItem(BackPieceActor);

	ArmorArray.AddItem(R_ClavicleActor);
	ArmorArray.AddItem(L_ClavicleActor);
	ArmorArray.AddItem(R_ShoulderActor);
	ArmorArray.AddItem(L_ShoulderActor);
	ArmorArray.AddItem(R_UpperArmActor);
	ArmorArray.AddItem(L_UpperArmActor);
	ArmorArray.AddItem(R_BicepActor);
	ArmorArray.AddItem(L_BicepActor);
	ArmorArray.AddItem(R_ForeArmActor);
	ArmorArray.AddItem(L_ForeArmActor);
	ArmorArray.AddItem(R_HandActor);
	ArmorArray.AddItem(L_HandActor);

	ArmorArray.AddItem(Waist1Actor);
	ArmorArray.AddItem(Waist2Actor);

	ArmorArray.AddItem(R_ThighActor);
	ArmorArray.AddItem(L_ThighActor);
	ArmorArray.AddItem(R_KneeActor);
	ArmorArray.AddItem(L_KneeActor);
	ArmorArray.AddItem(R_CalfActor);
	ArmorArray.AddItem(L_CalfActor);
	ArmorArray.AddItem(R_FootActor);
	ArmorArray.AddItem(L_FootActor);

	ArmorArray.AddItem(MeleeBladeActor);
	ArmorArray.AddItem(ShieldActor);
}

simulated function SetWeapAnimType(EWeapAnimType AnimType)
{
	ClientMessage("SetWeapAnimType()");
	HandleWeaponAnims();
}

simulated function HandleWeaponAnims()
{
	if(SWeapon(Weapon) != none){
		PlaySlotAnims(ArmsAnimSlot, SWeapon(Weapon).HoldAnim, 3, true,,0.2,0.2,true);
		ClientMessage("Found SWeapon: HandleWeaponAnims()");
	}
	else
		StopPlaySlotAnims(ArmsAnimSlot, 0.2);
}

function SetJetpackActive(bool bActive){
	bJetPackOn=bActive;
	
	JetPackComponent.SetActive(bActive);
	JetPackComponent2.SetActive(bActive);
	JetPackLight.SetEnabled(bActive);
	if(bActive && !JetPackAC.IsPlaying())
		JetPackAC.Play();
	else if(!bActive)
		JetPackAC.Stop();
}

exec function PlayJetPackSound(){
	JetPackAC.Play();
}

function SetBuildingMode(bool bBuildingMode){
	if(bBuildingMode)
		BuildingActor.StartGlow();
	else
		BuildingActor.StopGlow();
}

function ChangeBuildingActor(ShipPart newBuildingActor){
	if(newBuildingActor != none){
		BuildingActor.StopGlow();
		BuildingActor = newBuildingActor;
		BuildingActor.StartGlow();
	}
}

exec function ChangeAllArmorColor(int ArmorMaterialNumber, float red, float green, float blue, float alpha){
	local int i;
	for( i = 0; i < ArmorArray.Length; i++)
		ArmorArray[i].ChangeColor(ArmorMaterialNumber, red , green, blue, alpha);
}

function RandomizeColors(){
	GlossColor.R = Rand(99) * 0.01;
	GlossColor.B = Rand(99) * 0.01;
	GlossColor.G = Rand(99) * 0.01;

	FirstColor.R = Rand(99) * 0.01;
	FirstColor.B = Rand(99) * 0.01;
	FirstColor.G = Rand(99) * 0.01;

	SecondColor.R = Rand(99) * 0.01;
	SecondColor.B = Rand(99) * 0.01;
	SecondColor.G = Rand(99) * 0.01;

	LightColor.R = Rand(99) * 0.01;
	LightColor.B = Rand(99) * 0.01;
	LightColor.G = Rand(99) * 0.01;

	BladeColor.R = Rand(99) * 0.01;
	BladeColor.B = Rand(99) * 0.01;
	BladeColor.G = Rand(99) * 0.01;

	UpdateColors();
}

function UpdateColors(){
	local int i;
	local LinearColor tempColor;

	for(i = 0; i < 5; i++){
		if(i == 0)
			tempColor = GlossColor;
		else if(i==1)
			tempColor = FirstColor;
		else if(i==2)
			tempColor = SecondColor;
		else if(i==3)
			tempColor = LightColor;
		else if(i==4)
			tempColor = BladeColor;
		else
			return;

		ChangeAllArmorColor(i, tempColor.R, tempColor.G, tempColor.B, tempColor.A);
	}
}

exec function CreateShip(){
	local Rotator ShipRotation;
	local Vector ShipLocation;

	ShipLocation.X = 0;
	ShipLocation.Y = 0;
	ShipLocation.Z = 0;//1280.000000;
	//ShipLocation.Z -= 150;

	ShipRotation.Pitch =0;
	ShipRotation.Yaw = 0;
	ShipRotation.Roll = 0;
    
	BuildingActor = Spawn(class'Hallway', , , ShipLocation, ShipRotation);
	BuildingActor.PawnOwner = self;
	SetBuildingMode(true);
}

exec function CreateVehicle(){
	local Rotator ShipRotation;         // Will hold the rotation of the spawned vehicle
	local Vector ShipLocation, X, Y, Z; // Will hold the location of the spawned vehicle
	ShipLocation = Location;
	// Whatever class you are in Location is the actors location (players location here)

	GetAxes(Rotation,X,Y,Z);
	ShipLocation+=X*500;
    
	VehicleActor = Spawn(class'SVehicle', , , ShipLocation, ShipRotation);
	ShipActor = VehicleActor;
}

exec function DriveVehicle(){
	local Vector SeatLocation;
	local Rotator SeatRotation;

	VehicleActor.vehicleMesh.GetSocketWorldLocationAndRotation('SeatSocket',SeatLocation,SeatRotation);


	SetCollision(false,false); //Before moving into seat disable collision on player
	CamOffset.X+=40;

	SetLocation(SeatLocation);
	SetRotation(SeatRotation);

	SetPhysics(PHYS_None);
	SetDriveShip(true);

	SetBase(VehicleActor);
}


//CHANGE ARMOR EXEC FUNCTIONS

exec function ChangeToNextHelmet(){
	if(theArmorList != none){
		HelmetClass = theArmorList.GetNextHelmet(HelmetClass);
		SetHelmet(HelmetClass);
	}
}exec function ChangeToPreviousHelmet(){

}



/////////////////////////////////



exec function SpawnTopWall(){
	Hallway(BuildingActor).CreateTopWall();
}
exec function SpawnBottomWall(){
	Hallway(BuildingActor).CreateBottomWall();
}
exec function SpawnRightWall(){
	Hallway(BuildingActor).CreateRightWall();
}
exec function SpawnLeftWall(){
	Hallway(BuildingActor).CreateLeftWall();
}

exec function SpawnTopFloor(){
	Hallway(BuildingActor).CreateTopFloor();
}
exec function SpawnBottomFloor(){
	Hallway(BuildingActor).CreateBottomFloor();
}
exec function SpawnRightFloor(){
	Hallway(BuildingActor).CreateRightFloor();
}
exec function SpawnLeftFloor(){
	Hallway(BuildingActor).CreateLeftFloor();
}

exec function StartBuildingMode(){
	SetBuildingMode(true);
}
exec function EndBuilding(){
	SetBuildingMode(false);
}

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
	local Vector tempVel, ChestPieceLoc, ChestX, ChestY, ChestZ;
	local Rotator ChestPieceRot;

	Super.Tick(DeltaTime);

	if(Physics == PHYS_Flying || Physics == PHYS_Falling)
		AimNode.SetActiveProfileByName('Flying');
	else{
		AimNode.SetActiveProfileByName('Default');
	}

	/*if(!bDrivingShip){
		if(bJetPackActive){
			Mesh.GetSocketWorldLocationAndRotation('ChestPiece_Socket', ChestPieceLoc, ChestPieceRot);
			GetAxes(ChestPieceRot, ChestX, ChestY, ChestZ);
			tempVel = ChestZ*5 + Velocity;
			Velocity = tempVel;
			if(!bJetPackOn)
				SetJetpackActive(true);
		}
		else{
			if(Physics == PHYS_Flying && CheckMoving()){
				if(!bJetPackOn)
					SetJetpackActive(true);
			}
			else{
				if(bJetPackOn)
					SetJetpackActive(false);
			}
		}
	}*/
}

state WorldView{
	
	simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV ){
	   out_CamLoc = Location;
	   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
	   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

	   out_CamRot.Pitch = -1 * IsoCamAngle;   
	   out_CamRot.Yaw = 0;
	   out_CamRot.Roll = 0;

		return true;
	}

}

function bool CheckMoving()//Checks to see if you are moving or not
{
	return (Vsize(Velocity) != 0); 
}
/*
simulated function StartJump()
{
	SController(Controller).ReadyJump();
	//SetTimer(0.25, false, 'DrainJumpStamina');
}*/

simulated function AllowJump()
{
	bAllowJump = true;
}

function SetDriveShip(bool bDriving){
	bDrivingShip = bDriving;
	if(bDriving){
		DriveBlend.SetBlendTarget(1, 0.5);
		SController(Controller).GotoState('PlayerDriving');
	}
	else{
		DriveBlend.SetBlendTarget(0, 0.5);
		Controller.GotoState('PlayerWalking');
	}
}

//////// FUNCTIONS THAT HANDLE BOOLS FOR HOLDING BUTTONS!!!!////////////

exec function ToggleDriveShip(){
	SetDriveShip(!bDrivingShip);
}

exec function PressRollRight(){
	bPressingRollRight = true;
}

exec function StopPressRollRight(){
	bPressingRollRight = false;
}

exec function PressRollLeft(){
	bPressingRollLeft = true;
}

exec function StopPressRollLeft(){
	bPressingRollLeft = false;
}

exec function StopPressJump(){
	bPressingJump = false;
	bJetPackActive = false;
}

function ActivateJetPack(){
	if(bPressingJump)
		bJetPackActive = true;
}

exec function PressWorldView(){
	bWorldView = !bWorldView;
	if(bWorldView){
		GotoState('WorldView');
		//SController(Controller).GotoState('WorldView');
	}
	else
		GotoState('PlayerWalking');
		//SController(Controller).GotoState('PlayerWalking');
}

simulated function SetPressShipTurnRight(bool bTurnRight)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressShipTurnRight(bTurnRight);
	}

	bPressingShipTurnRight = bTurnRight;
}

reliable server function ServerSetPressShipTurnRight(bool bTurnRight)
{
	bPressingShipTurnRight = bTurnRight;
}

simulated function SetPressShipTurnLeft(bool bTurnLeft)
{
	if(Role < ROLE_Authority)
	{
		ServerSetPressShipTurnLeft(bTurnLeft);
	}

	bPressingShipTurnLeft = bTurnLeft;
}

reliable server function ServerSetPressShipTurnLeft(bool bTurnLeft)
{
	bPressingShipTurnLeft = bTurnLeft;
}

exec function SetCameraOffsetDistance(float OffsetDistance)
{
	CamOffsetDistance = OffsetDistance;
}

///////////////////////////////////////////////////////
//////////////////////////////////////////////////////
/*
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	if(bDrivingShip){
		
	}
	else if ( Physics == PHYS_Flying )
	{
		SetRotation(NewRotation);
	}
	else
		Super.FaceRotation(NewRotation, DeltaTime);
}*/

exec function StartAim()
{
	if(Weapon != none){
		bAiming = true;
		PlaySlotAnims(TorsoAnimSlot, SWeapon(Weapon).AimAnim, 3, true,,0.2,0.2,true);
		UTPlayerController(Controller).StartZoom(45,60);
	}else{
		ActivateShield();
	}
}

exec function StopAim(){
	bAiming = false;
	StopPlaySlotAnims(TorsoAnimSlot, 0.2);
	UTPlayerController(Controller).StartZoom(SController(Controller).DefaultFOV,60);
	//PlaySlotAnims(TorsoAnimSlot, SWeapon(Weapon).HoldAnim, 3, true,,0.2,0.2,true);

	DeactivateShield();
}

simulated function ActivateShield(){
	FullAnimSlot.PlayCustomMirrorAnim('H_ShieldAnim_2', 1, false, 0.2, 0.25, true);
	ShieldActor.ArmorMesh.SetHidden(false);
}simulated function DeactivateShield(){
	StopPlaySlotAnims(FullAnimSlot, 0.25);
	ShieldActor.ArmorMesh.SetHidden(true);
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
	GlossColor=(R=1,G=1,B=1,A=1)
	FirstColor=(R=0.2,G=0.2,B=0.2,A=1)
	SecondColor=(R=0.5,G=0.5,B=0.5,A=1)
	LightColor=(R=1,G=1,B=1,A=1)
	BladeColor=(R=1,G=1,B=1,A=1)

	bPlayingMelee = false
	bAllowNextMelee = false
	currentmeleeNum = 0

	JetPackParticleSystem = ParticleSystem'PXParticleSystems.Dust.Ember2'

	//ARMOR
	HelmetClass = class'ArA_Helmet'
	ChestPieceClass = class'ArA_ChestPiece'

	//BackPieceClass = class'ArA_ChestPiece'

	R_ClavicleClass = class'R_Clavicle'
	L_ClavicleClass = class'L_Clavicle'
	R_ShoulderClass = class'R_Shoulder'
	L_ShoulderClass = class'L_Shoulder'
	R_UpperArmClass = class'R_UpperArm'
	L_UpperArmClass = class'L_UpperArm'
	R_BicepClass = class'R_Bicep'
	L_BicepClass = class'L_Bicep'
	R_ForeArmClass = class'R_ForeArm'
	L_ForeArmClass = class'L_ForeArm'
	R_HandClass = class'R_Hand'
	L_HandClass = class'L_Hand'

	BackPieceClass = class'Back'
	Waist2Class = class'Waist2'
	Waist1Class = class'Waist'

	R_ThighClass = class'R_Thigh'
	L_ThighClass = class'L_Thigh'
	R_KneeClass = class'R_Knee'
	L_KneeClass = class'L_Knee'
	R_CalfClass = class'R_Calf'
	L_CalfClass = class'L_Calf'
	R_FootClass = class'R_Foot'
	L_FootClass = class'L_Foot'

	ShieldClass = class'Shield'

	DrawScale = 1.1

   IsoCamAngle=15000//6420 //35.264 degrees

	CamOffset=(X=15,Y=30,Z=-30)

	//GroundSpeed=60
	//AirSpeed = 60
	//SprintSpeedMultiplier=4

	bPushesRigidBodies=true

	bFlashLightEnabled = false

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0015.000000
		CollisionHeight=+0050.000000

	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'Human1.Mesh.Human_Base1'
		AnimTreeTemplate=AnimTree'Human1.AnimTree.Human1_AnimTree'
		AnimSets(0)=AnimSet'Human1.AnimSet.Humanoid1_AnimSet'
		AnimSets(1)=AnimSet'Human1.AnimSet.Humanoid_AnimSet'
		PhysicsAsset=PhysicsAsset'MaleBase.Physics.MaleBase_Physics'
	End Object

	Begin Object Class=AudioComponent Name=JetPackAudioComponent
		SoundCue=SoundCue'Human1.Sounds.JetPack_cue'
	End Object
	Components.Add(JetPackAudioComponent)
	JetPackAC = JetPackAudioComponent

	Begin Object Class=AudioComponent Name=BladeAudioComponent
		SoundCue=SoundCue'ArA_Armor.Sounds.Swooshh1_Cue'
	End Object
	Components.Add(BladeAudioComponent)
	BladeAC = BladeAudioComponent

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
		Radius=1024//40000.000000
		FalloffExponent=2//200.000000
		Brightness = 5//2
		bCastCompositeShadow=True
		bAffectCompositeShadowDirection=True
		bRenderLightShafts = false
		LightShadowMode=LightShadow_Normal//LightShadow_Modulate
		//LightShaftConeAngle = 89
		OcclusionDepthRange = 1
		BloomScale = 0.1
		BloomTint = (B=255,G=255,R=255,A=0)
		RadialBlurPercent = 0.3
		InnerConeAngle = 10
		OuterConeAngle = 35
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE,Skybox=FALSE,bInitialized=TRUE)
		LightFunction=MyLightFunction
	End Object
	MyLight=HeadLightComponentR
	Components.Add(HeadLightComponentR)

	Begin Object class=PointLightComponent name=PointLightComponentR
       LightColor=(R=203,G=231,B=203)
       CastShadows=False
       bEnabled=false
       Radius=128
       FalloffExponent=15
       Brightness = 3
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
		BloomTint = (B=255,G=255,R=255,A=0)
		RadialBlurPercent = 0.3
		//InnerConeAngle = 10
		//OuterConeAngle = 2
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,CompositeDynamic=TRUE,Skybox=FALSE,bInitialized=TRUE)

		Translation=(Y=0,X=10, Z=30)
	End Object
	MyLight2 = PointLightComponentR
	Components.Add(PointLightComponentR)

	Begin Object class=PointLightComponent name=JetPackLightComponent
        LightColor=(R=255,G=255,B=255)
        CastShadows=false
        bEnabled=false
        Radius=50
        FalloffExponent=3.000000
        Brightness=1
        CastStaticShadows=False
        CastDynamicShadows=False
        bCastCompositeShadow=False
        bAffectCompositeShadowDirection=False
    End Object
    JetPackLight=JetPackLightComponent
	Components.Add(JetPackLightComponent)

/*
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
	BeamMesh = Beam*/
}