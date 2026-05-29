/*
███████████File: fn_copLights.sqf███████████
████Author: [GSN] Pager & [GSN] Paronity████
██████████Date Created: 02.24.2015██████████
███████Date Modified: 05.28.2026 v6.0███████
*/

// ============================================================================
// fn_lightBar.sqf
// Attaches and animates emergency lightbar lights on supported vehicles.
//
// Usage:  [vehicle] call fn_lightBar;
//
// Flash patterns (set per vehicle in the switch block):
//   "ALTERNATE"  — left side flashes, then right side (classic split-flash)
//   "WIGWAG"     — left and right flash in strict opposition (never both ON)
//   "SIMULTANEOUS" — both sides flash together (pursuit / all-on)
// ============================================================================

if (!hasInterface) exitWith {};

private _vehicle = param [0, objNull, [objNull]];
if (isNull _vehicle) exitWith {};

// Hardened nil/false guard
private _lightsVar = _vehicle getVariable "lights";
if (isNil "_lightsVar" || { !_lightsVar }) exitWith {};

if ((player distance _vehicle) > 500) exitWith {};

uiSleep 1;

// ── Tunables ─────────────────────────────────────────────────────────────────

#define FLASH_COUNT   3      // flashes per side per cycle
#define FLASH_ON      0.05   // seconds light stays ON per flash
#define FLASH_OFF     0.075  // seconds between flashes (light OFF)
#define CYCLE_PAUSE   0.0    // optional pause between full L/R cycles

// Light colours (RGB)
#define COL_RED   [1,0,0]
#define COL_WHITE [1,1,1]
#define COL_BLUE  [0,0,1]

// ── Day / night brightness ────────────────────────────────────────────────────

private _brightnessHigh = 0;
private _attenuation    = [];
private _intensity      = 0;

if (sunOrMoon < 0.2) then {
    _brightnessHigh = 100;
    _attenuation    = [0.001, 0,    50, 2500000, 0.001, 250];
    _intensity      = 1000;
} else {
    _brightnessHigh = 20;
    _attenuation    = [0.001, 3000, 50,  500000, 0.001, 250];
    _intensity      = 100;
};

// ── Light factory ─────────────────────────────────────────────────────────────
// Creates and attaches a single light point.
// Returns the light object.
//
// _colorArr  : RGB array (use COL_* macros)
// _position  : model-space offset [x, y, z]
//              +x = driver's right | -x = driver's left
//              +y = forward        | -y = rearward

private _fnCreateLight = {
    params ["_colorArr", "_position"];

    private _light = "#lightpoint" createVehicleLocal (getPos _vehicle);
    _light setLightAmbient    [0, 0, 0];
    _light setLightBrightness 0;
    _light setLightAttenuation _attenuation;
    _light setLightIntensity   _intensity;
    _light setLightColor       _colorArr;
    _light lightAttachObject  [_vehicle, _position];

    _light  // return
};

// ── Vehicle light definitions ─────────────────────────────────────────────────
// Format per entry: [side, colorMacro, [x, y, z]]
//   side : "L" = driver's left (x < 0) | "R" = driver's right (x > 0)
//
// Returns: [[leftLights], [rightLights], "PATTERN"]

private _leftLights  = [];
private _rightLights = [];
private _pattern     = "ALTERNATE";   // default; overridden per vehicle

private _buildLights = {
    params ["_defs"];
    {
        _x params ["_side", "_color", "_pos"];
        private _light = [_color, _pos] call _fnCreateLight;
        if (_side == "L") then { _leftLights  pushBack _light; }
                          else { _rightLights pushBack _light; };
    } forEach _defs;
};

switch (typeOf _vehicle) do
{
    // ── Civilian Offroad ──────────────────────────────────────────────────────
    case "C_Offroad_01_F":
    {
        _pattern = "ALTERNATE";
        [
            // Roof bar
            ["L", COL_RED,   [-0.44,   0,      0.525]],
            ["R", COL_BLUE,  [ 0.345,  0,      0.525]],
            // Rear low
            ["R", COL_RED,   [ 0.575, -2.95,  -0.77 ]],
            ["L", COL_BLUE,  [-0.645, -2.95,  -0.77 ]],
            // Rear mid
            ["L", COL_RED,   [-0.905, -2.875, -0.225]],
            ["R", COL_RED,   [ 0.825, -2.875, -0.225]],
            // Front bumper
            ["R", COL_WHITE, [ 0.61,   2.2825,-0.355]],
            ["L", COL_WHITE, [-0.695,  2.2825,-0.355]]
        ] call _buildLights;
    };

    // ── BG Offroad ────────────────────────────────────────────────────────────
    case "B_G_Offroad_01_F":
    {
        _pattern = "WIGWAG";
        [
            ["R", COL_RED,   [ 0.575, -2.95,  -0.77 ]],
            ["L", COL_BLUE,  [-0.645, -2.95,  -0.77 ]],
            ["L", COL_RED,   [-0.905, -2.875, -0.225]],
            ["R", COL_RED,   [ 0.825, -2.875, -0.225]],
            ["R", COL_BLUE,  [ 0.61,   2.2825,-0.355]],
            ["L", COL_RED,   [-0.695,  2.2825,-0.355]]
        ] call _buildLights;
    };

    // ── SUV ───────────────────────────────────────────────────────────────────
    case "C_SUV_01_F":
    {
        _pattern = "WIGWAG";
        [
            ["L", COL_RED,   [-0.39,  2.28,  -0.52]],
            ["R", COL_BLUE,  [ 0.38,  2.28,  -0.52]],
            ["L", COL_RED,   [-0.86, -2.75,  -0.18]],
            ["R", COL_RED,   [ 0.86, -2.75,  -0.18]],
            ["L", COL_BLUE,  [-0.6,  -2.925, -0.24]],
            ["R", COL_BLUE,  [ 0.59, -2.925, -0.24]],
            ["R", COL_WHITE, [ 0.8,   1.95,  -0.48]],
            ["L", COL_WHITE, [-0.8,   1.95,  -0.48]]
        ] call _buildLights;
    };

    // ── Hatchback ─────────────────────────────────────────────────────────────
    case "C_Hatchback_01_F":
    {
        _pattern = "ALTERNATE";
        [
            ["L", COL_BLUE,  [-0.03,  0,     0.2  ]],
            ["R", COL_BLUE,  [-0.03,  0,     0.2  ]],
            ["L", COL_BLUE,  [ 0.78, -2.25, -0.3  ]],
            ["R", COL_BLUE,  [-0.8,  -2.25, -0.3  ]],
            ["R", COL_WHITE, [ 0.75,  1.615,-0.52 ]],
            ["L", COL_WHITE, [-0.8,   1.615,-0.525]]
        ] call _buildLights;
    };

    // ── Sport Hatchback ───────────────────────────────────────────────────────
    case "C_Hatchback_01_sport_F":
    {
        _pattern = "ALTERNATE";
        [
            ["L", COL_RED,   [-0.03,  0,     0.2  ]],
            ["R", COL_BLUE,  [-0.03,  0,     0.2  ]],
            ["L", COL_RED,   [-0.8,  -2.25, -0.3  ]],
            ["R", COL_BLUE,  [ 0.78, -2.25, -0.3  ]],
            ["R", COL_WHITE, [ 0.75,  1.615,-0.52 ]],
            ["L", COL_WHITE, [-0.8,   1.615,-0.525]]
        ] call _buildLights;
    };

    // ── Hunter (MRAP) ─────────────────────────────────────────────────────────
    case "B_MRAP_01_F":
    {
        _pattern = "WIGWAG";
        [
            ["L", COL_RED,   [-0.85,  -0.9,  0.6 ]],
            ["R", COL_BLUE,  [ 0.85,  -0.9,  0.6 ]],
            ["L", COL_RED,   [-0.93,  -2.8,  0.6 ]],
            ["R", COL_BLUE,  [ 0.93,  -2.8,  0.6 ]],
            ["L", COL_WHITE, [-0.85,   1.475,-0.75]],
            ["R", COL_WHITE, [ 0.85,   1.475,-0.75]]
        ] call _buildLights;
    };

    // ── Ifrit (MRAP) ──────────────────────────────────────────────────────────
    case "O_MRAP_02_F":
    {
        _pattern = "ALTERNATE";
        [
            ["R", COL_BLUE,  [ 1.175, -1.5,   0.365 ]],
            ["L", COL_RED,   [-1.175, -1.5,   0.365 ]],
            ["L", COL_RED,   [ 0.4325,-1.5,   0.6275]],
            ["R", COL_BLUE,  [ 0.4325,-1.5,   0.6275]],
            ["L", COL_RED,   [-0.2,   1.575, -1.125 ]],
            ["R", COL_BLUE,  [ 0.2,   1.575, -1.125 ]],
            ["L", COL_WHITE, [-0.775, 1.475,  -1    ]],
            ["R", COL_WHITE, [ 0.775, 1.475,  -1    ]],
            ["R", COL_BLUE,  [-0.525,-4.5,   -1.3   ]],
            ["L", COL_RED,   [ 0.525,-4.5,   -1.3   ]],
            ["L", COL_RED,   [-0.4,  -4.95,   0.155 ]],
            ["R", COL_BLUE,  [ 0.4,  -4.95,   0.155 ]]
        ] call _buildLights;
    };

    // ── Jeep (Offroad 02) ─────────────────────────────────────────────────────
    case "C_Offroad_02_unarmed_F":
    {
        _pattern = "WIGWAG";
        [
            ["R", COL_RED,  [ 0.5,  1.25, -0.16]],
            ["L", COL_BLUE, [-0.5,  1.25, -0.16]]
        ] call _buildLights;
    };

    default {
        diag_log format ["[LightBar] Unsupported vehicle type: %1", typeOf _vehicle];
    };
};

// ── Guard: nothing attached → bail ───────────────────────────────────────────
if (_leftLights isEqualTo [] && { _rightLights isEqualTo [] }) exitWith {
    diag_log "[LightBar] No lights attached — aborting.";
};

// ── Flash helpers ─────────────────────────────────────────────────────────────
// Burst: flash one set of lights N times.
private _fnBurst = {
    params ["_lights"];
    for "_i" from 1 to FLASH_COUNT do {
        { _x setLightBrightness _brightnessHigh; } forEach _lights;
        uiSleep FLASH_ON;
        { _x setLightBrightness 0; } forEach _lights;
        uiSleep FLASH_OFF;
    };
};

// Wig-wag step: L on while R off, then swap — one interleaved pair per call.
private _fnWigwagStep = {
    // Phase A: left ON, right OFF
    { _x setLightBrightness _brightnessHigh; } forEach _leftLights;
    { _x setLightBrightness 0;               } forEach _rightLights;
    uiSleep FLASH_ON;
    { _x setLightBrightness 0;               } forEach _leftLights;
    uiSleep FLASH_OFF;

    // Phase B: right ON, left OFF
    { _x setLightBrightness _brightnessHigh; } forEach _rightLights;
    { _x setLightBrightness 0;               } forEach _leftLights;
    uiSleep FLASH_ON;
    { _x setLightBrightness 0;               } forEach _rightLights;
    uiSleep FLASH_OFF;
};

// ── Active-check closure (evaluated once, reused cheaply in loop) ─────────────
// Caches the condition as a code block to avoid string eval overhead.
private _fnIsActive = {
    if (!alive _vehicle) exitWith { false };
    private _v = _vehicle getVariable ["lights", false];
    !isNil "_v" && { _v }
};

// ── Main flash loop ───────────────────────────────────────────────────────────
while { call _fnIsActive } do {
    switch (_pattern) do {

        case "ALTERNATE": {
            [_leftLights]  call _fnBurst;
            [_rightLights] call _fnBurst;
        };

        case "WIGWAG": {
            for "_i" from 1 to FLASH_COUNT do {
                call _fnWigwagStep;
            };
        };

        case "SIMULTANEOUS": {
            [_leftLights + _rightLights] call _fnBurst;
            // brief pause so "simultaneous" doesn't look identical to rapid ALTERNATE
            uiSleep 0.15;
        };
    };

    if (CYCLE_PAUSE > 0) then { uiSleep CYCLE_PAUSE; };
};

// ── Cleanup ───────────────────────────────────────────────────────────────────
{ deleteVehicle _x; } forEach (_leftLights + _rightLights);
_leftLights  = [];
_rightLights = [];
