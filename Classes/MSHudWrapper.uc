/* This is the HUD wrapper. Its job is to instantiate the HUD and to tell it to update after each frame is rendered. */

class MSHudWrapper extends UTHUDBase;

/** Movie */
var MSHud   			HudMovie;
var Vector2D			HudMovieSize;
var bool cursorStatus;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	CreateHUDMovie();
}


function CreateHUDMovie()
{
	local float x0, y0, x1, y1;
	
	HudMovie = new class'MSHud';

	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
	
	/* Using SM_NoScale, the Flash movie will not be scaled larger or smaller, regardless of the game's resolution. */
	/* Using SM_NoBorder, the Flash movie is scaled but with some varying levels of fail with the GetVisibleFrameRect() below*/
	HudMovie.SetViewScaleMode(SM_NoBorder);
	HudMovie.SetAlignment(Align_TopLeft);
	
	/* GetVisibleFrameRect(x1, y0, x1, y1) will allow us to determine the current viewport size. */
	HudMovie.GetVisibleFrameRect(x0, y0, x1, y1);
	HudMovieSize.X = x1-x0;
	HudMovieSize.Y = y1-y0;
}

exec function ToggleMouseCursor(bool showCursor)
{
	cursorStatus = HudMovie.ToggleMouseCursor(showCursor);
}

/* 
* Events 
*/

event PostRender()
{	
	super.PostRender();

	if (HudMovie != none)
	{
			
			HudMovie.TickHud(0);				

	}
	
}



defaultproperties
{
}
