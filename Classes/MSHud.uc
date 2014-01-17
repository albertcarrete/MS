/*
 * MSHUD.uc
 * MetalStar Player HUD
 */
class MSHud extends GFxMoviePlayer;

// Standard Flash Objects
var GFxObject 					RootMC, 
								ReticleMC, ReticlesMC,
								OnBoardMC,
								xLocTextField,yLocTextField,zLocTextField,
								pRotTextField,yRotTextField,rRotTextField,
				                magTextField,
								shipHealthField,shipEnergyField;

// CLIK Widgets (buttons)
var GFxClikWidget				TestBtn, ResBtn;

// Custom Mouse Class
var GFxMouse	 				MyMouse;

var SPlayer_Pawn                MyPawn;

/** Holds the players location, post-vector */
var float locX, locY, locZ;
var float rotP, rotY, rotR;
var float velX, velY, velZ;
var float mag;

var int shipHealth, shipEnergy;
var int enemyShipHealth;
var int enemyShipEnergy;
var bool onboardShip;

// ======================================================================================
// STRINGS AND VALUES FOR HUD
// ======================================================================================
var string  xLocStr, yLocStr, zLocStr,      // string variables to hold the x,y,z player positions
			pRotStr, yRotStr, rRotStr,      //                     hold the p,y,r player positions
			magStr,                         // holds the magnitude of the player
			shipHealthStr,                  // Ship Health
			shipEnergyStr;                  // Ship Energy


//========================================================================================
//  START |  INITIALIZATION
//========================================================================================
// This initialization function is fired off by the HUD Wrapper when the HUD is instantiated.

function Init(optional LocalPlayer player)
{	
	local int testNumber;
	
	super.Init(player);

    Start();
    Advance(0);

	// Creates the mouse cursor.
	MyMouse = new class'GFxMouse';
	MyMouse.RegisterHud(self);
	MyMouse.SetTimingMode(TM_Real);
	MyMouse.Init(player);
	
	// Caches a reference to the Flash root timeline.
	RootMC      = GetVariableObject("root");
	ReticleMC   = RootMC.GetObject("reticle");
	OnBoardMC   = RootMC.GetObject("OnBoard");

	// Demonstrates how to grab a public variable (SomeNumber) from an AS3 document class.
	testNumber = RootMC.GetInt("SomeNumber");
	`log("Test Number: " @ testNumber);
	
	//When this menu is in use, ignore these keys
	AddFocusIgnoreKey('LeftShift'); // This key is used to toggle the mouse cursor on and off so it is ignored
	AddFocusIgnoreKey('W');
	AddFocusIgnoreKey('A');
	AddFocusIgnoreKey('S');
	AddFocusIgnoreKey('D');
}

//========================================================================================
//  GET |  SHIP HEALTH & ENERGY
//========================================================================================
// Determines if the player is onboard a ship via 'S_Pawn(GetPC().Pawn).ShipActor' which
// checks to see if the player has a ship actor. 
function int getShipHealth(){
	if(S_Pawn(GetPC().Pawn).ShipActor != none){
		return S_Pawn(GetPC().Pawn).ShipActor.Health;
	}
	else{
		return 0;
	}
}
function setShipHealth(){
	shipHealth = getShipHealth();
}
function int getShipEnergy(){
	if(S_Pawn(GetPC().Pawn).ShipActor != none){
		return S_Pawn(GetPC().Pawn).ShipActor.Energy;
	}
	else{
		return 0;
	}
}
function setShipEnergy(){
	shipEnergy = getShipEnergy();
}

//========================================================================================
//  GET |  ENEMY SHIP HEALTH & ENERGY
//========================================================================================

function int getEnemyShipHealth(){
	if(S_Pawn(GetPC().Pawn).ShipActor.EnemyShip != none){
		return S_Pawn(GetPC().Pawn).ShipActor.EnemyShip.Health;
	}
	else{
		return 0;
	}
}
function setEnemyShipHealth(){
	enemyShipHealth = getEnemyShipHealth();
}
function int getEnemyShipEnergy(){
	if(S_Pawn(GetPC().Pawn).ShipActor.EnemyShip != none){
		return S_Pawn(GetPC().Pawn).ShipActor.EnemyShip.Energy;
	}
	else{
		return 0;
	}
}
function int getShipTimerTime(){
	if(S_Pawn(GetPC().Pawn).ShipActor != none){
		return S_Pawn(GetPC().Pawn).ShipActor.TimerTime;
	}
	else{
		return 0;
	}
}

//PLAYER VELOCITY
function vector getPlayerVelocity(){
	return GetPC().Pawn.Velocity;
}
function setPlayerVelocity(){
	
	local vector tempVelocity;

	tempVelocity = getPlayerVelocity();
	velX = tempVelocity.X;
	velY = tempVelocity.Y;
	velZ = tempVelocity.Z;

	mag = getMag();
}

//PLAYER MAGNITUDE
function float getMag(){
	
	local float magnitude;

	magnitude = Sqrt(Square(velX)+Square(velY)+Square(VelZ)); 

	return magnitude;
	
}

//PLAYER ROTATION
function rotator getPlayerRotation(){
	return GetPC().Pawn.Rotation;
}
function setPlayerRotation(){
	
	local rotator tempRotation;

	tempRotation = getPlayerRotation();
	rotY = tempRotation.Yaw;
	rotP = tempRotation.Pitch;
	rotR = tempRotation.Roll;

}

// PLAYER LOCATION
function vector getPlayerLocation(){
	return GetPC().Pawn.Location;
}
function setPlayerLocation(){
	
	local vector tempLocation;

	tempLocation = getPlayerLocation();

	locX = tempLocation.X;
	locY = tempLocation.Y;
	locZ = tempLocation.Z;

}

//========================================================================================
//  SET |  HUD STRINGS AND VALUES
//========================================================================================
// Notes: Might be beneficial to combine these all into one function, however comparmentalizing them
// allows us to set the text only when needed if we have multiple huds or data being used / not used.
// 

function SetLocationText(string xLocCordinate, string yLocCordinate, string zLocCordinate)
{
	// Retreive the field in the swf root                       // Set the value for that AS3 field
    xLocTextField = GetVariableObject("_root.xLocation");       xLocTextField.SetText(xLocCordinate);
    yLocTextField = GetVariableObject("_root.yLocation");       yLocTextField.SetText(yLocCordinate);
    zLocTextField = GetVariableObject("_root.zLocation");   	zLocTextField.SetText(zLocCordinate);
}

function SetRotationText(string yRotCordinate, string pRotCordinate, string rRotCordinate)
{
	// Retrieve the field in the swf root                       // Set the value for that AS3 field
    pRotTextField = GetVariableObject("_root.pRotation");       pRotTextField.SetText(pRotCordinate);
    yRotTextField = GetVariableObject("_root.yRotation");       yRotTextField.SetText(yRotCordinate);
    rRotTextField = GetVariableObject("_root.rRotation");       rRotTextField.SetText(rRotCordinate);
}

function SetMagnitudeText(string magCordinate)
{
	magTextField = GetVariableObject("_root.mag");	            magTextField.SetText(magCordinate);
}

function SetShipHealthText(string shipHealthValue)
{
	shipHealthField = GetVariableObject("_root.OnBoard.shipHealth");            shipHealthField.SetText(shipHealthValue);
}
function SetShipEnergyText(string shipEnergyValue)
{
	shipEnergyField = GetVariableObject("_root.OnBoard.shipEnergy");            shipEnergyField.SetText(shipEnergyValue);
}

//========================================================================================
//  TICK
//========================================================================================
// This function is called by the HUD Wrapper.
function TickHud(float DeltaTime)
{	
	setPlayerLocation();
	setPlayerRotation();
	setPlayerVelocity();
	setShipHealth();
	setShipEnergy();

	// Update Player Location Data
	xLocStr = "Player X:" @ locX;       yRotStr = "Player Yaw:" @ rotY;
	yLocStr = "Player Y:" @ locY;       pRotStr = "Player Pitch:" @ rotP;
	zLocStr = "Player Z:" @ locZ;       rRotStr = "Player Roll:" @ rotR;

	magStr = "Player Mag: " @ mag;

	shipHealthStr = "Ship Health: " @ shipHealth;
	shipEnergyStr = "Ship Energy: " @ shipEnergy;

	SetLocationText(xLocStr,yLocStr,zLocStr);
	SetRotationText(yRotStr,pRotStr,rRotStr);
	SetMagnitudeText(magStr);
	SetShipHealthText(shipHealthStr);
	SetShipEnergyText(shipEnergyStr);
	
	ToggleOnShip(ShipHealth);
}

// Toggles mouse cursor on/off
function bool ToggleMouseCursor(bool showCursor)
{	
	if (showCursor)
	{
		MyMouse.ToggleMouse(true);
	}
	else
	{
		MyMouse.ToggleMouse(false);
	}
	
	// When showCursor is true, the movie should capture all input, including mouse input; otherwise, it should not capture any input.
	self.bCaptureInput = showCursor; // disables mouse look when holding down shift
	self.bIgnoreMouseInput = !showCursor;	

	return showCursor;
}

//========================================================================================
//  ToggleOnShip
//========================================================================================
// Determines if player is on ship and displays the appropriate health and energy data.
// 
// Abstract: The onboardShip bool is determined by if the player is receiving a ship health
// value and not by 

function ToggleOnShip(int ShipHealthValue)
{
	if((ShipHealthValue > 0) && (onboardShip == false)){
		GetPC().Pawn.ClientMessage('OnBoard Ship  Altering Reticle');
		//ReticleMC.GotoAndStopI(20);
		//ReticlesMC.GotoAndPlay("open");
		ReticleMC.GotoAndPlay("dim");
		OnBoardMC.GotoAndPlay("reveal");
		//ReticleMC.GotoAndStopI(2);

		onboardShip = true;
	}
    if((ShipHealthValue <= 0) && (onboardShip == true)){
		GetPC().Pawn.ClientMessage('Offsite  Altering Reticle');
		ReticleMC.GotoAndPlay("bright");
		OnBoardMC.GotoAndPlay("fade");
		onboardShip = false;
	}
}
// Callback when a CLIK widget with enableInitCallback set to TRUE is initialized.  Returns TRUE if the widget was handled, FALSE if not.
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{    
    switch (WidgetName) // WidgetName = instance name of a Flash object.
    {         
		case ('testBtn'):
			TestBtn = GFxClikWidget(Widget);
			SetUpButtonEvents(TestBtn);
			break;
		case('resBtn'):
			ResBtn = GFxClikWidget(Widget);
			SetUpButtonEvents(ResBtn);
			break;
        default:
            break;
    }
    return true;
}


// Adds an event listener and sets the text that will be displayed on the button
function SetUpButtonEvents(GFxClikWidget button)
{
	button.AddEventListener('CLIK_buttonPress', handleRollOver);

}

function handleRollOver(GFxClikWidget.EventData ev)
{
	local GFxObject button;
	button = ev._this.GetObject("target");
	
	switch (button.GetString("name"))
	{
		case ("testBtn"):
			`log("Over Button!");
			ConsoleCommand("createVehicle");
			GetPC().Pawn.ClientMessage('Toggle Mouse');
			break;
		case ("resBtn"):
			ConsoleCommand("SETRES 1920x1080f");
			break;
		default:
			break;
	}
}

defaultproperties
{		
	WidgetBindings(0)={(WidgetName="testBtn",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(1)={(WidgetName="resBtn",WidgetClass=class'GFxClikWidget')}

	MovieInfo = SwfMovie'MSUI.MSHudAS3'
	
	bIgnoreMouseInput = true
	bDisplayWithHudOff = false
	bEnableGammaCorrection = false
	bPauseGameWhileActive = false
	bCaptureInput = false;
}
