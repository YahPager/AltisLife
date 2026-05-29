/*
███████████File: fn_copLights.sqf███████████
████Author: [GSN] Pager & [GSN] Paronity████
██████████Date Created: 02.24.2015██████████
███████Date Modified: 05.28.2026 v6.0███████
*/

if (!hasInterface) exitWith {};

private _vehicle = param [0, objNull, [objNull]];

if (isNull _vehicle) exitWith {};

// Hardened variable check — handles nil, false, and missing variable
private _lightsVar = _vehicle getVariable "lights";
if (isNil "_lightsVar" || {!_lightsVar}) exitWith {};

if ((player distance _vehicle) > 500) exitWith {};

uiSleep 1;

// ── Color constants ───────────────────────────────────────────────────────────
private _redLights   = [1,0,0];
private _whiteLights = [1,1,1];
private _blueLights  = [0,0,1];

// ── Flash config ──────────────────────────────────────────────────────────────
private _flashes  = 3;     // number of flashes per side per cycle
private _flashOn  = 0.05;  // seconds light is ON per flash
private _flashOff = 0.075; // seconds light is OFF between flashes

// ── Brightness / attenuation (day vs night) ───────────────────────────────────
private _brightnessLow  = 0;
private _brightnessHigh = 0;
private _attenuation    = [];
private _intensity      = 0;

if (sunOrMoon < 0.2) then { // NIGHT
    _brightnessHigh = 100;
    _attenuation    = [0.001,0,50,2500000,0.001,250];
    _intensity      = 1000;
} else { // DAY
    _brightnessHigh = 20;
    _attenuation    = [0.001,3000,50,500000,0.001,250];
    _intensity      = 100;
};

private _leftLights  = [];
private _rightLights = [];

// ── Light attach helper ───────────────────────────────────────────────────────
// Params: [isDriverLeft, "COLOR", [x, y, z]]
// Coordinate convention: positive X = driver's right, negative X = driver's left
//                        positive Y = forward,         negative Y = rearward
private _attach = {
    params ["_isLeft", "_color", "_position"];

    private _light = "#lightpoint" createVehicleLocal (getPos _vehicle);

    _light setLightAmbient    [0,0,0];
    _light setLightBrightness 0;
    _light setLightAttenuation _attenuation;
    _light setLightIntensity   _intensity;

    switch (_color) do {
        case "RED":   { _light setLightColor _redLights;   };
        case "WHITE": { _light setLightColor _whiteLights; };
        case "BLUE":  { _light setLightColor _blueLights;  };
    };

    _light lightAttachObject [_vehicle, _position];

    if (_isLeft) then {
        _leftLights  pushBack _light;
    } else {
        _rightLights pushBack _light;
    };
};

// ── Per-vehicle light positions ───────────────────────────────────────────────
// Each entry: [isDriverLeft, "COLOR", [x, y, z]]
// isDriverLeft matches the sign of x: negative x = left (true), positive x = right (false)

switch (typeOf _vehicle) do
{
    case "C_Offroad_01_F": // Offroad
    {
        // Roof bar
        [true,  "RED",  [-0.44,  0,      0.525]]  call _attach; // roof left
        [false, "BLUE", [ 0.345, 0,      0.525]]  call _attach; // roof right
        // Rear low
        [false, "RED",  [ 0.575,-2.95,  -0.77]]   call _attach; // rear right low
        [true,  "BLUE", [-0.645,-2.95,  -0.77]]   call _attach; // rear left low
        // Rear mid
        [true,  "RED",  [-0.905,-2.875, -0.225]]  call _attach; // rear left mid
        [false, "RED",  [ 0.825,-2.875, -0.225]]  call _attach; // rear right mid
        // Front bumper
        [false, "WHITE",[ 0.61,  2.2825,-0.355]]  call _attach; // front right
        [true,  "WHITE",[-0.695, 2.2825,-0.355]]  call _attach; // front left
    };

    case "B_G_Offroad_01_F": // BG_Offroad
    {
        // Rear low
        [false, "RED",  [ 0.575,-2.95,  -0.77]]   call _attach; // rear right low
        [true,  "BLUE", [-0.645,-2.95,  -0.77]]   call _attach; // rear left low
        // Rear mid
        [true,  "RED",  [-0.905,-2.875, -0.225]]  call _attach; // rear left mid
        [false, "RED",  [ 0.825,-2.875, -0.225]]  call _attach; // rear right mid
        // Front bumper
        [false, "BLUE", [ 0.61,  2.2825,-0.355]]  call _attach; // front right
        [true,  "RED",  [-0.695, 2.2825,-0.355]]  call _attach; // front left
    };

    case "C_SUV_01_F": // SUV
    {
        // Front
        [true,  "RED",  [-0.39, 2.28,  -0.52]]  call _attach; // front left
        [false, "BLUE", [ 0.38, 2.28,  -0.52]]  call _attach; // front right
        // Rear high
        [true,  "RED",  [-0.86,-2.75,  -0.18]]  call _attach; // rear left high
        [false, "RED",  [ 0.86,-2.75,  -0.18]]  call _attach; // rear right high
        // Rear low
        [true,  "BLUE", [-0.6, -2.925, -0.24]]  call _attach; // rear left low
        [false, "BLUE", [ 0.59,-2.925, -0.24]]  call _attach; // rear right low
        // Front bumper
        [false, "WHITE",[ 0.8,  1.95,  -0.48]]  call _attach; // front right
        [true,  "WHITE",[-0.8,  1.95,  -0.48]]  call _attach; // front left
    };

    case "C_Hatchback_01_F": // Hatch
    {
        // Roof centre (both sides share near-centre position)
        [true,  "BLUE", [-0.03, 0,    0.2]]   call _attach; // roof left
        [false, "BLUE", [-0.03, 0,    0.2]]   call _attach; // roof right
        // Rear
        [true,  "BLUE", [ 0.78,-2.25,-0.3]]   call _attach; // rear left
        [false, "BLUE", [-0.8, -2.25,-0.3]]   call _attach; // rear right
        // Front bumper
        [false, "WHITE",[ 0.75, 1.615,-0.52]]  call _attach; // front right
        [true,  "WHITE",[-0.8,  1.615,-0.525]] call _attach; // front left
    };

    case "C_Hatchback_01_sport_F": // Sport Hatch
    {
        // Roof centre
        [true,  "RED",  [-0.03, 0,    0.2]]   call _attach; // roof left
        [false, "BLUE", [-0.03, 0,    0.2]]   call _attach; // roof right
        // Rear
        [true,  "RED",  [-0.8, -2.25,-0.3]]   call _attach; // rear left
        [false, "BLUE", [ 0.78,-2.25,-0.3]]   call _attach; // rear right
        // Front bumper
        [false, "WHITE",[ 0.75, 1.615,-0.52]]  call _attach; // front right
        [true,  "WHITE",[-0.8,  1.615,-0.525]] call _attach; // front left
    };

    case "B_MRAP_01_F": // Hunter
    {
        // Roof mid
        [true,  "RED",  [-0.85,-0.9,  0.6]]   call _attach; // roof left
        [false, "BLUE", [ 0.85,-0.9,  0.6]]   call _attach; // roof right
        // Roof rear
        [true,  "RED",  [-0.93,-2.8,  0.6]]   call _attach; // roof rear left
        [false, "BLUE", [ 0.93,-2.8,  0.6]]   call _attach; // roof rear right
        // Front bumper
        [true,  "WHITE",[-0.85, 1.475,-0.75]]  call _attach; // front left
        [false, "WHITE",[ 0.85, 1.475,-0.75]]  call _attach; // front right
    };

    case "O_MRAP_02_F": // Ifrit
    {
        // Side mid
        [false, "BLUE", [ 1.175,-1.5,  0.365]]  call _attach; // right side
        [true,  "RED",  [-1.175,-1.5,  0.365]]  call _attach; // left side
        // Roof rear centre
        [true,  "RED",  [ 0.4325,-1.5, 0.6275]] call _attach; // roof rear left
        [false, "BLUE", [ 0.4325,-1.5, 0.6275]] call _attach; // roof rear right
        // Front low
        [true,  "RED",  [-0.2,  1.575,-1.125]]  call _attach; // front left
        [false, "BLUE", [ 0.2,  1.575,-1.125]]  call _attach; // front right
        // Front bumper outer
        [true,  "WHITE",[-0.775, 1.475,-1]]     call _attach; // front left
        [false, "WHITE",[ 0.775, 1.475,-1]]     call _attach; // front right
        // Rear low
        [false, "BLUE", [-0.525,-4.5, -1.3]]    call _attach; // rear right
        [true,  "RED",  [ 0.525,-4.5, -1.3]]    call _attach; // rear left
        // Rear high
        [true,  "RED",  [-0.4,  -4.95, 0.155]]  call _attach; // rear left high
        [false, "BLUE", [ 0.4,  -4.95, 0.155]]  call _attach; // rear right high
    };

    case "C_Offroad_02_unarmed_F": // Jeep
    {
        [false, "RED",  [ 0.5,  1.25,-0.16]]  call _attach; // front right
        [true,  "BLUE", [-0.5,  1.25,-0.16]]  call _attach; // front left
    };

    default {
        diag_log format ["[LightBar] Unsupported vehicle type: %1", typeOf _vehicle];
    };
};

// ── Guard: exit if no lights were attached (unsupported vehicle) ──────────────
if (_leftLights isEqualTo [] && {_rightLights isEqualTo []}) exitWith {
    diag_log "[LightBar] No lights attached — aborting flash loop.";
};

// ── Flash loop ────────────────────────────────────────────────────────────────
while {
    alive _vehicle &&
    {
        private _v = _vehicle getVariable "lights";
        !isNil "_v" && {_v}
    }
} do {
    // LEFT side flash
    for "_i" from 1 to _flashes do {
        { _x setLightBrightness _brightnessHigh; } forEach _leftLights;
        uiSleep _flashOn;
        { _x setLightBrightness _brightnessLow;  } forEach _leftLights;
        uiSleep _flashOff;
    };

    // RIGHT side flash
    for "_i" from 1 to _flashes do {
        { _x setLightBrightness _brightnessHigh; } forEach _rightLights;
        uiSleep _flashOn;
        { _x setLightBrightness _brightnessLow;  } forEach _rightLights;
        uiSleep _flashOff;
    };
};

// ── Cleanup ───────────────────────────────────────────────────────────────────
{ deleteVehicle _x; } forEach (_leftLights + _rightLights);

_leftLights  = [];
_rightLights = [];
