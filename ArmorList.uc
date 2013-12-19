class ArmorList extends Actor;

var array< class<Armor> > ArmorArray;

function array< class<Armor> > GetHelmetArray(){
	local array< class<Armor> > tempArray;

	tempArray.AddItem(class'ArA_Helmet');
	tempArray.AddItem(class'ArB_Helmet');

	return tempArray;
}

function class<Armor> GetNextHelmet(class<Armor> ArmorClass){
	local array< class<Armor> > tempArray;
	local int i;

	tempArray = GetHelmetArray();

	for(i = 0; i < tempArray.Length; i++){
		if(tempArray[i].Name == ArmorClass.Name)
			if(tempArray[i+1] != none)//reached the end of the array
				return tempArray[i+1];
			else
				return tempArray[0];//return the first one
	}
	
	return ArmorClass;
}

DefaultProperties
{
}
