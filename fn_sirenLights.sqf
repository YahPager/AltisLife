#include "..\..\script_macros.hpp"
/*
██████████File: fn_sirenLights.sqf██████████
███████████████Author: Pager████████████████
██████████Date Created: 05.28.2026██████████
███████Date Modified: 05.28.2026 v1.0███████
*/
    Improvements:
    - Cleaner structure
    - Faster vehicle validation using hash map
    - Safer variable handling
    - Prevents duplicate remoteExec calls
    - Easier to maintain
*/
params [
    ["_vehicle", objNull, [objNull]]
];

if (isNull _vehicle) exitWith {};

//==============================================================
// Allowed vehicles
//==============================================================

if (isNil "life_allowedLightVehicles") then {
    life_allowedLightVehicles = createHashMapFromArray [
        ["C_Offroad_01_F", true],
        ["C_Hatchback_01_sport_F", true],
        ["C_SUV_01_F", true],
        ["B_G_Offroad_01_F", true],
        ["B_MRAP_01_F", true],
        ["O_MRAP_02_F", true],
        ["C_Offroad_02_unarmed_F", true]
    ];
};

if !(life_allowedLightVehicles getOrDefault [typeOf _vehicle, false]) exitWith {};

//==============================================================
// Current state
//==============================================================

private _lightsEnabled = _vehicle getVariable ["lights", false];

//==============================================================
// Disable lights
//==============================================================

if (_lightsEnabled) exitWith {

    _vehicle setVariable ["lights", false, true];

    private _jipId = _vehicle getVariable ["lightsJIP", -1];

    if (_jipId != -1) then {

        // Remove persistent JIP execution
        remoteExecCall ["", 0, _jipId];

        _vehicle setVariable ["lightsJIP", nil, true];
    };
};

//==============================================================
// Prevent duplicate execution
//==============================================================

private _existingJip = _vehicle getVariable ["lightsJIP", -1];

if (_existingJip != -1) exitWith {};

//==============================================================
// Enable lights
//==============================================================

private _jipId = [
    _vehicle,
    0.22
] remoteExec ["life_fnc_copLights", RCLIENT, true];

if (!isNil "_jipId") then {

    _vehicle setVariable ["lights", true, true];
    _vehicle setVariable ["lightsJIP", _jipId, true];
};
