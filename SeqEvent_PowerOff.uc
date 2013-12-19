class SeqEvent_PowerOff extends SequenceEvent;

event Activated(){
       `log("event activated.");
}
 
Defaultproperties
{
       ObjName="Power Off"
       ObjCategory="S Events"
       bPlayerOnly=false
	   OutputLinks[0]=(LinkDesc="Activated")
       MaxTriggerCount=0
}