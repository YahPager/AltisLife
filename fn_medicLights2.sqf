/*
█████████File: fn_medicLights2.sqf██████████
███████████████Author: Pager████████████████
██████████Date Created: 05.28.2026██████████
███████Date Modified: 05.28.2026 v2.0███████
*/
// ============================================================================
// fn_medicLights2.sqf
// Attaches and animates lights on supported medic vehicles.
//
// Usage:  [vehicle] call fn_medicSirenLights;
//
// Trigger condition: "lights" vehicle variables must be true.
// ============================================================================

if (!hasInterface) exitWith {};

private _vehicle = param [0, objNull, [objNull]];
if (isNull _vehicle) exitWith {};

// "lights" must be true
private _lightsVar = _vehicle getVariable "lights";
if (isNil "_lightsVar" || { !_lightsVar }) exitWith {};

if ((player distance _vehicle) > 600) exitWith {};

uiSleep 1;

// ── Tunables ──────────────────────────────────────────────────────────────────

#define FLASH_COUNT   3
#define FLASH_ON      0.03
#define FLASH_OFF     0.05
#define HOLD_DURATION 0.15
#define CYCLE_PAUSE   0.05

// Light colours (RGB)
#define COL_RED    [1, 0, 0]
#define COL_WHITE  [1, 1, 1]
#define COL_YELLOW [1, 1, 0]

// ── How many cycles each pattern runs before switching ────────────────────────

#define PATTERN_CYCLES 6

// ── Day / night brightness ────────────────────────────────────────────────────

private _brightnessHigh = 0;
private _brightnessHold = 0;
private _attenuation    = [];
private _intensity      = 0;

if (sunOrMoon < 0.2) then {
    _brightnessHigh = 100;
    _brightnessHold = 75;
    _attenuation    = [0.001, 0,    50, 2500000, 0.001, 250];
    _intensity      = 1200;
} else {
    _brightnessHigh = 25;
    _brightnessHold = 15;
    _attenuation    = [0.001, 3000, 50,  500000, 0.001, 250];
    _intensity      = 120;
};

// ── Light factory ─────────────────────────────────────────────────────────────

private _fnCreateLight = {
    params ["_colorArr", "_position"];

    private _light = "#lightpoint" createVehicleLocal (getPos _vehicle);
    _light setLightAmbient    [0, 0, 0];
    _light setLightBrightness 0;
    _light setLightAttenuation _attenuation;
    _light setLightIntensity   _intensity;
    _light setLightColor       _colorArr;
    _light lightAttachObject  [_vehicle, _position];

    _light
};

// ── Vehicle light definitions ─────────────────────────────────────────────────

private _leftLights  = [];
private _rightLights = [];

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
    case "C_Offroad_01_F":
    {
        [
            ["L", COL_RED,    [-0.440,  0.000,  0.5125]],
            ["R", COL_YELLOW, [ 0.345,  0.000,  0.5125]],
            ["R", COL_RED,    [ 0.575, -2.950, -0.7700]],
            ["L", COL_YELLOW, [-0.645, -2.950, -0.7700]],
            ["L", COL_RED,    [-0.905, -2.875, -0.2250]],
            ["R", COL_RED,    [ 0.825, -2.875, -0.2250]],
            ["L", COL_RED,    [-0.300,  2.500, -0.500]],
            ["R", COL_YELLOW, [ 0.300,  2.500, -0.500]]
        ] call _buildLights;
    };

    case "B_G_Offroad_01_repair_F";
    case "O_Offroad_01_repair_F":
    {
        [
            ["L", COL_YELLOW, [-0.440, 0, 0.5125]],
            ["R", COL_YELLOW, [ 0.345, 0, 0.5125]],
            ["L", COL_YELLOW, [-0.300, 2.500, -0.500]],
            ["R", COL_YELLOW, [ 0.300, 2.500, -0.500]]
        ] call _buildLights;
    };

    case "C_SUV_01_F":
    {
        [
            ["L", COL_RED,    [-0.390,  2.280, -0.520]],
            ["R", COL_YELLOW, [ 0.380,  2.280, -0.520]],
            ["L", COL_RED,    [-0.860, -2.750, -0.180]],
            ["R", COL_RED,    [ 0.860, -2.750, -0.180]],
            ["L", COL_YELLOW, [-0.600, -2.925, -0.240]],
            ["R", COL_YELLOW, [ 0.590, -2.925, -0.240]],
            ["L", COL_RED,    [-0.350,  2.700, -0.600]],
            ["R", COL_YELLOW, [ 0.350,  2.700, -0.600]],
            ["L", COL_RED,    [-0.200,  1.200,  0.100]],
            ["R", COL_YELLOW, [ 0.200,  1.200,  0.100]]
        ] call _buildLights;
    };

    case "C_Hatchback_01_F":
    {
        [
            ["L", COL_RED,    [-0.030,  0.000,  0.200]],
            ["R", COL_YELLOW, [-0.030,  0.000,  0.200]],
            ["L", COL_RED,    [-0.800, -2.250, -0.300]],
            ["R", COL_YELLOW, [ 0.780, -2.250, -0.300]],
            ["L", COL_RED,    [-0.280,  2.100, -0.450]],
            ["R", COL_YELLOW, [ 0.280,  2.100, -0.450]]
        ] call _buildLights;
    };

    case "C_Hatchback_01_sport_F":
    {
        [
            ["L", COL_RED,    [-0.030,  0.000,  0.200]],
            ["R", COL_YELLOW, [-0.030,  0.000,  0.200]],
            ["L", COL_RED,    [-0.800, -2.250, -0.300]],
            ["R", COL_YELLOW, [ 0.780, -2.250, -0.300]],
            ["L", COL_RED,    [-0.280,  2.200, -0.480]],
            ["R", COL_YELLOW, [ 0.280,  2.200, -0.480]]
        ] call _buildLights;
    };

    case "C_Truck_02_box_F":
    {
        [
            ["L", COL_RED,    [-0.790, -0.17275,  1.325]],
            ["R", COL_YELLOW, [ 0.750, -0.17275,  1.325]],
            ["L", COL_RED,    [-0.710,  2.12750, -0.750]],
            ["R", COL_YELLOW, [ 0.675,  2.12750, -0.750]],
            ["L", COL_RED,    [-0.735, -3.47250,  1.260]],
            ["R", COL_RED,    [ 0.7125,-3.47250,  1.260]],
            ["L", COL_YELLOW, [-0.225, -3.47250,  1.260]],
            ["R", COL_YELLOW, [ 0.210, -3.47250,  1.260]],
            ["L", COL_RED,    [-0.650,  3.200, -0.700]],
            ["R", COL_YELLOW, [ 0.650,  3.200, -0.700]]
        ] call _buildLights;
    };

    case "I_MRAP_03_F":
    {
        [
            ["R", COL_YELLOW, [ 0.900,  2.200, -0.800]],
            ["L", COL_RED,    [-0.900,  2.200, -0.800]],
            ["R", COL_YELLOW, [ 0.000, -3.000,  0.025]],
            ["L", COL_RED,    [-0.725, -3.100,  0.025]],
            ["L", COL_RED,    [-0.800,  2.600, -0.900]],
            ["R", COL_YELLOW, [ 0.800,  2.600, -0.900]]
        ] call _buildLights;
    };

    case "O_MRAP_02_F":
    {
        [
            ["R", COL_YELLOW, [ 1.175, -1.500,  0.3650]],
            ["L", COL_RED,    [-1.175, -1.500,  0.3650]],
            ["L", COL_RED,    [-0.4325,-1.500,  0.6275]],
            ["R", COL_YELLOW, [ 0.4325,-1.500,  0.6275]],
            ["L", COL_RED,    [-0.200,  1.575, -1.1250]],
            ["R", COL_YELLOW, [ 0.200,  1.575, -1.1250]],
            ["R", COL_RED,    [ 0.525, -4.500, -1.3000]],
            ["L", COL_YELLOW, [-0.525, -4.500, -1.3000]],
            ["L", COL_RED,    [-0.400, -4.950,  0.1550]],
            ["R", COL_YELLOW, [ 0.400, -4.950,  0.1550]],
            ["L", COL_RED,    [-0.900,  2.000, -1.200]],
            ["R", COL_YELLOW, [ 0.900,  2.000, -1.200]]
        ] call _buildLights;
    };

    default {
        diag_log format ["[LightsOnly] Unsupported vehicle type: %1", typeOf _vehicle];
    };
};

// ── Guard ─────────────────────────────────────────────────────────────────────

if (_leftLights isEqualTo [] && { _rightLights isEqualTo [] }) exitWith {
    diag_log "[LightsOnly] No lights attached — aborting.";
};

// ── Flash helpers ─────────────────────────────────────────────────────────────

private _fnBurst = {
    params ["_lights"];
    for "_i" from 1 to FLASH_COUNT do {
        { _x setLightBrightness _brightnessHigh; } forEach _lights;
        uiSleep FLASH_ON;
        { _x setLightBrightness 0;               } forEach _lights;
        uiSleep FLASH_OFF;
    };
};

// Pattern 0 — Wigwag Hold (original): left burst, right burst, all hold dim
private _fnWigwagHold = {
    [_leftLights]  call _fnBurst;
    [_rightLights] call _fnBurst;
    { _x setLightBrightness _brightnessHold; } forEach (_leftLights + _rightLights);
    uiSleep HOLD_DURATION;
    { _x setLightBrightness 0;               } forEach (_leftLights + _rightLights);
};

// Pattern 1 — Alternating: classic left/right trade-off, no burst
private _fnAlternating = {
    { _x setLightBrightness _brightnessHigh; } forEach _leftLights;
    { _x setLightBrightness 0;               } forEach _rightLights;
    uiSleep HOLD_DURATION;
    { _x setLightBrightness 0;               } forEach _leftLights;
    { _x setLightBrightness _brightnessHigh; } forEach _rightLights;
    uiSleep HOLD_DURATION;
    { _x setLightBrightness 0;               } forEach _rightLights;
};

// Pattern 2 — Strobe: all lights rapid fire
private _fnStrobe = {
    for "_i" from 1 to 6 do {
        { _x setLightBrightness _brightnessHigh; } forEach (_leftLights + _rightLights);
        uiSleep 0.02;
        { _x setLightBrightness 0;               } forEach (_leftLights + _rightLights);
        uiSleep 0.02;
    };
};

// ── Active-check closure ──────────────────────────────────────────────────────

private _fnIsActive = {
    if (!alive _vehicle) exitWith { false };
    private _lv = _vehicle getVariable ["lights", false];
    !isNil "_lv" && { _lv }
};

// ── Main flash loop — cycles through all three patterns ───────────────────────

private _phase        = 0;
private _cycleCounter = 0;

while { call _fnIsActive } do {

    switch (_phase) do {
        case 0: { call _fnWigwagHold;  };
        case 1: { call _fnAlternating; };
        case 2: { call _fnStrobe;      };
    };

    if (CYCLE_PAUSE > 0) then { uiSleep CYCLE_PAUSE; };

    // Advance pattern after PATTERN_CYCLES repetitions
    _cycleCounter = _cycleCounter + 1;
    if (_cycleCounter >= PATTERN_CYCLES) then {
        _cycleCounter = 0;
        _phase = (_phase + 1) % 3;
    };
};

// ── Cleanup ───────────────────────────────────────────────────────────────────

{ deleteVehicle _x; } forEach (_leftLights + _rightLights);
_leftLights  = [];
_rightLights = [];
