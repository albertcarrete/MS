class SeqEvent_RestorePower extends SequenceEvent;

event Activated(){
       `log("event activated.");
}
 
Defaultproperties
{
       ObjName="Restore Power"
       ObjCategory="S Events"
       bPlayerOnly=false
	   OutputLinks[0]=(LinkDesc="Activated")
       MaxTriggerCount=0
}