/*
	
	AUTHOR: aeroson
	NAME: onetime_cleanup.sqf
	VERSION: 2.1.1

	DESCRIPTION:
	one call deletes stuff within radius from player that is not really needed:
	dead bodies, dropped items, smokes, chemlights, explosives
	beware: if weapons on ground are intentional e.g. fancy weapons stack, it will delete them too
	beware: if dead bodies are intentional it will delete them to
	
	USAGE:
	put this into init of anything:
	this addAction ["Cleanup around you", { [300,["dropped","corpses","wrecks","misc"]] execVM "onetime_cleanup.sqf"; } ];
	where 300 is radius of cleanup, default is 1000
	[1000,["dropped","corpses","wrecks","misc"]] execVM "onetime_cleanup.sqf";
		
*/
         

private ["_start"];


_deletedWrecks = 0;
_deletedDroppedItems = 0;
_deletedCorpses = 0;
_deletedMisc = 0;

_start = diag_tickTime;


private	_pos = getPos player;
if(!isNil{ACE_player}) then {
	_pos = getPos ACE_player;
};

params [
	["_radius", 1000, [0]],
	["_whatToRemove", ["dropped","misc","corpses","wrecks"], [[""]]]
];


if("dropped" in _whatToRemove) then {
	{
		{ 
			if(isNull attachedTo _x) then { // for example backpack on chest is attached to player, we dont want to delete that
				deleteVehicle _x; 
				_deletedDroppedItems = _deletedDroppedItems+1;
			};
		} forEach (_pos nearObjects [_x, _radius]);
	} forEach ["WeaponHolder","GroundWeaponHolder","WeaponHolderSimulated","TimeBombCore","SmokeShell","AGM_SpareWheel","AGM_JerryCan","AGM_SpareTrack"];
};

if("misc" in _whatToRemove) then {
	{
		{ 
			if(isNull attachedTo _x) then { 
				deleteVehicle _x; 
				_deletedMisc = _deletedMisc+1;
			};
		} forEach (_pos nearObjects [_x, _radius]);
	} forEach ["ACE_envelope_small", "ACE_envelope_big", "CraterLong_small","CraterLong","AGM_FastRoping_Helper","#dynamicsound","#destructioneffects","#track","#particlesource"];
};

if("corpses" in _whatToRemove) then {
	{ 																																			
		if(!alive _x) then {
			deleteVehicle _x; 
			_deletedCorpses = _deletedCorpses + 1;
		};
	} forEach (_pos nearObjects ["Man", _radius]);
};

if("wrecks" in _whatToRemove) then {
	{ 	
		if(isNull attachedTo _x) then { 	
			if(_x distanceSqr _pos < _radius * _radius && !canMove _x ) then {
				deleteVehicle _x; 
				_deletedWrecks = _deletedWrecks + 1;
			};
		};
	} forEach vehicles;
};


hint format ["
Cleanup took %1 seconds\n
wrecks deleted: %2\n
dropped items deleted: %3\n
corpses deleted: %4\n
misc deleted: %5\n
in radius: %6 m
",diag_tickTime - _start, _deletedWrecks, _deletedDroppedItems, _deletedCorpses, _deletedMisc, _radius];