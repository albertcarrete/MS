class GFxMouse extends GFxMoviePlayer;
	
var MSHud					MSHud;
	
// Standard Flash Objects
var GFxObject 					MouseContainerMC, MouseCursorMC;
	
var Vector2D 					lastMousePOS;


	
function Init(optional LocalPlayer player)
{
	local float x0, y0, x1, y1;
	
	super.Init(player);
	
	// Get the HUD's viewport size and set the mouse's initial position to the center of the screen.

	MSHud.GetVisibleFrameRect(x0, y0, x1, y1);
	lastMousePOS.X = (x1-x0)/2;
	lastMousePOS.Y = (y1-y0)/2;

}

// This function gives us a reference to the HUD which created the mouse.
function RegisterHud(MSHud hud)
{
	MSHud = hud;
}

// This function either attaches the mouse to the stage of the HUD or removes it, always maintaining the last known position.
function ToggleMouse(bool enableMouse)
{	
	if (enableMouse)
	{
		// Attaches the mouse container movie clip to the stage/root of the HUD and caches a reference to it.
		MouseContainerMC = MSHud.GetVariableObject("root").AttachMovie("MouseCursorContainer", "MouseConatinerMC"); // argument1 = Flash AS3 class name; argument2 = new instance name
		
		// Caches a reference to the actual mouse cursor movie clip, which is inside the mouse container movie clip.
		MouseCursorMC = MouseContainerMC.GetObject("mCursor");
		
		// Ensures that the Unreal/Windows mouse is set to the last known Flash mouse position.
		GetGameViewportClient().SetMouse(lastMousePOS.X,lastMousePOS.Y); 
			
		// Sets the position of the Flash mouse cursor movie clip to match the Unreal/Windows mouse position.
		MouseCursorMC.SetPosition(lastMousePOS.X,lastMousePOS.Y);
			
		// Ensures the mouse cursor is drawn on top of all other movie clips.
		MouseContainerMC.SetBool("topmostLevel", true);
	}
	else
	{
		// Saves the mouse cursor's last known position on the screen before removing it.
		lastMousePOS.X = MouseCursorMC.GetFloat("x");
		lastMousePOS.Y = MouseCursorMC.GetFloat("y");
		
		// Removes the Flash mouse container movie clip using a custom class 'GFxDisplayObject'.		
		GFxDisplayObject(MouseContainerMC.GetObject("parent",class'GFxDisplayObject')).RemoveChild(MouseContainerMC);
	}
}

defaultproperties
{
}