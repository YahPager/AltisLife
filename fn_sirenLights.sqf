#include "..\..\script_macros.hpp"
/*
██████████File: fn_sirenLights.sqf██████████
███████████████Author: Pager████████████████
██████████Date Created: 05.28.2026██████████
███████Date Modified: 05.28.2026 v2.0███████

    Improvements:
    - Cleaner structure
    - Faster vehicle validation using hash map
    - Safer variable handling
    - Prevents duplicate remoteExec calls
    - Easier to maintain
*/
// =========================================================
// life_fnc_toggleCopLights
// Toggles persistent cop vehicle lights on/off with JIP
// =========================================================

params [["_vehicle", objNull, [objNull]]];
if (isNull _vehicle) exitWith {};

// --- Allowed vehicle whitelist (lazy init) ---
if (isNil "life_allowedLightVehicles") then {
    life_allowedLightVehicles = createHashMapFromArray [
        ["C_Offroad_01_F",         true],
        ["C_Hatchback_01_sport_F", true],
        ["C_SUV_01_F",             true],
        ["B_G_Offroad_01_F",       true],
        ["B_MRAP_01_F",            true],
        ["O_MRAP_02_F",            true],
        ["C_Offroad_02_unarmed_F", true]
    ];
};
if !(life_allowedLightVehicles getOrDefault [typeOf _vehicle, false]) exitWith {};

// --- Race condition mutex ---
// Prevent two simultaneous callers both passing the JIP guard
if (_vehicle getVariable ["lightsBusy", false]) exitWith {};

_vehicle setVariable ["lightsBusy", true, true];


// --- Helper: disable lights and cancel JIP ---
private _disableLights = {

    _vehicle setVariable ["lights", false, true];

    private _jipId = _vehicle getVariable ["lightsJIP", nil];

    if (!(isNil "_jipId") && {_jipId != -1}) then {

        remoteExecCall ["", 0, _jipId];

    };

    _vehicle setVariable ["lightsJIP", nil, true];

};


// --- Toggle ---
private _lightsEnabled = _vehicle getVariable ["lights", false];

if (_lightsEnabled) then {
    call _disableLights;

} else {
    // Enable: spawn JIP execution on the owning client
    private _jipId = [_vehicle, 0.22] remoteExec ["life_fnc_copLights", RCLIENT, true];
    if (!(isNil "_jipId") && {_jipId isNotEqualTo ""}) then {

        _vehicle setVariable ["lights",    true,  true];
        _vehicle setVariable ["lightsJIP", _jipId, true];
    } else {
        // remoteExec failed — don't claim lights are on

        diag_log format ["[CopLights] remoteExec failed for %1", typeOf _vehicle];

    };
};

// --- Release mutex ---
_vehicle setVariable ["lightsBusy", false, true];
