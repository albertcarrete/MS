/*
 * MSHUD.uc
 * 
 */

class MSHud extends GFxMoviePlayer;


// Standard Flash Objects

var GFxObject 					RootMC;
var GFxObject                   xLocTextField,yLocTextField,zLocTextField;
var GFxObject                   pRotTextField,yRotTextField,rRotTextField;
var GFxObject                   magTextField;

// CLIK Widgets
var GFxClikWidget				TestBtn, ResBtn;

// Custom Mouse Class
var GFxMouse	 				MyMouse;

var SPlayer_Pawn                MyPawn;

/** Holds the players location, post-vector */
var float locX, locY, locZ;
var float rotP, rotY, rotR;
var float velX, velY, velZ;
var float mag;

//Strings For HUD
var string xLocStr, yLocStr, zLocStr; // string variables to hold the x,y,z player positions
var string pRotStr, yRotStr, rRotStr;
var string magStr;


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
	RootMC = GetVariableObject("root");
	
	// Demonstrates how to grab a public variable (SomeNumber) from an AS3 document class.
	testNumber = RootMC.GetInt("SomeNumber");
	`log("Test Number: " @ testNumber);
	
	AddFocusIgnoreKey('LeftShift'); // This key is used to toggle the mouse cursor on and off so it is ignored
	AddFocusIgnoreKey('W');
	AddFocusIgnoreKey('A');
	AddFocusIgnoreKey('S');
	AddFocusIgnoreKey('D');
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

//PLAYER LOCATION
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

function SetLocationText(string xLocCordinate, string yLocCordinate, string zLocCordinate)
{
    xLocTextField = GetVariableObject("_root.xLocation");
    yLocTextField = GetVariableObject("_root.yLocation");
    zLocTextField = GetVariableObject("_root.zLocation");

    xLocTextField.SetText(xLocCordinate);
	yLocTextField.SetText(yLocCordinate);
	zLocTextField.SetText(zLocCordinate);
}

function SetRotationText(string yRotCordinate, string pRotCordinate, string rRotCordinate)
{
    pRotTextField = GetVariableObject("_root.pRotation");
    yRotTextField = GetVariableObject("_root.yRotation");
    rRotTextField = GetVariableObject("_root.rRotation");

    pRotTextField.SetText(pRotCordinate);
	yRotTextField.SetText(yRotCordinate);
	rRotTextField.SetText(rRotCordinate);
}

function SetMagnitudeText(string magCordinate)
{
	magTextField = GetVariableObject("_root.mag");	
	magTextField.SetText(magCordinate);
}

// This function is called by the HUD Wrapper.
function TickHud(float DeltaTime)
{	

	setPlayerLocation();
	setPlayerRotation();
	setPlayerVelocity();

	xLocStr = "Player X:" @ locX;
	yLocStr = "Player Y:" @ locY;
	zLocStr = "Player Z:" @ locZ;

	yRotStr = "Player Yaw:" @ rotY;
	pRotStr = "Player Pitch:" @ rotP;
	rRotStr = "Player Roll:" @ rotR;

	magStr = "Player Mag:"@ mag;

	SetLocationText(xLocStr,yLocStr,zLocStr);
	SetRotationText(yRotStr,pRotStr,rRotStr);
	SetMagnitudeText(magStr);
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
