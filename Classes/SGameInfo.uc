class SGameInfo extends UTDeathMatch;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SpawnRocks(Rand(800), 100000, 100);
	
}

event InitGame( string Options, out string ErrorMessage )
{
	Super.InitGame(Options, ErrorMessage);
}
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return class'ProjectS.SGameInfo';
}
function SpawnRocks(int spawnAmount, int MaxDistance, int MaxSize)
{
	local int i, j;

	local Actor tempRock;
	local Vector spawnLoc, randVel, tempVec;
	local Rotator spawnRot;
	local StaticMeshComponent RockMesh;

	i =0;
	while(i < spawnAmount){
		i++;
		
		spawnRot = GetRandomRotation();
		spawnLoc = GetRandomLocation(MaxDistance);
		tempRock = Spawn(class'SPushableObject', , , spawnLoc, spawnRot);
		SPushableObject(tempRock).TheKActor.SetDrawScale(1 + Rand(MaxSize));
		RockMesh = SPushableObject(tempRock).TheKActor.theMesh;

		j = Rand(30);
		if(j < 7){
			randVel = GetRandomVelocity(40);
			//tempVec = GetRandomLocation(50, 0);
			tempVec = tempRock.Location;
			SPushableObject(tempRock).TheKActor.theMesh.AddForce(randVel, tempVec);
			randVel = GetRandomVelocity(2000);
			SPushableObject(tempRock).TheKActor.theMesh.AddForce(randVel);
		}
	}
}


function Rotator GetRandomRotation(){
	local Rotator randomRot;
	local float randYawOffset, randRollOffset, randPitchOffset;

	randYawOffset = Rand(65536);
	randRollOffset = Rand(65536);
	randPitchOffset = Rand(65536);
	
	randomRot.Yaw = randYawOffset;
	randomRot.Roll = randRollOffset;
	randomRot.Pitch = randPitchOffset;

	return randomRot;
}

function Vector GetRandomVelocity(float MaxVel){
	local Vector tempVel;
	local float randXOffset, randYOffset, randZOffset;
	local int tempRand;

	randXOffset = Rand(MaxVel);
	randYOffset = Rand(MaxVel);
	randZOffset = Rand(MaxVel);

	tempRand = Rand(2);
	if(tempRand == 0)
		randXOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randYOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randZOffset *= -1;

	tempVel.X = randXOffset;
	tempVel.Y = randYOffset;
	tempVel.Z = randZOffset;

	return tempVel;
}

simulated function Vector GetRandomLocation(int MaxXandYDistance, optional int MinXandYDistance, optional Vector StartingPoint)
{
	local Vector randomLoc;
	local float randXOffset, randYOffset, randZOffset, tempRand;

	if(StartingPoint != vect(0,0,0))
		randomLoc = StartingPoint;
	else{
		randomLoc.X = 0;
		randomLoc.Y = 0;
		randomLoc.Z = 0;
	}

	if(MinXandYDistance > 0 || MinXandYDistance < 0){
		randXOffset = MinXandYDistance;
		randYOffset = MinXandYDistance;
		randZOffset = MinXandYDistance;
	}

	randXOffset += Rand(MaxXandYDistance);
	randYOffset += Rand(MaxXandYDistance);
	randZOffset += Rand(MaxXandYDistance);

	tempRand = Rand(2);
	if(tempRand == 0)
		randXOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randYOffset *= -1;
	tempRand = Rand(2);
	if(tempRand == 0)
		randZOffset *= -1;

	randomLoc.X += randXOffset;
	randomLoc.Y += randYOffset;
	randomLoc.Z += randZOffset;

	return randomLoc;
}

function AddDefaultInventory( pawn PlayerPawn )
{
	//PlayerPawn.CreateInventory(class'SWeap_LinkGun');
}

DefaultProperties
{
	bWaitForNetPlayers = false
	bWaitingToStartMatch = false

	DefaultPawnClass=class'SPlayer_Pawn'//class'SPlayerWithShip_Pawn'
	PlayerControllerClass=class'SController'
	HUDType=class'ProjectS.MSHudWrapper'	
	//HUDType=class'SHud'
	MapPrefixes[0]="S"
	bUseClassicHUD=true
	Name = "Default__SGameInfo"
}
