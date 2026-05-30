 /*
    case 38: { // L key
    private _veh = vehicle player;

    // Whitelisted emergency vehicles
    private _emergencyVehicles = [
        "C_Offroad_01_F",
        "C_Hatchback_01_sport_F",
        "C_SUV_01_F",
        "B_G_Offroad_01_F",
        "B_MRAP_01_F",
        "O_MRAP_02_F",
        "C_Offroad_02_unarmed_F"
    ];

    private _isEmergencySide = playerSide isEqualTo west || playerSide isEqualTo independent;
    private _isInVehicle     = _veh != player;
    private _isValidVehicle  = (typeOf _veh) in _emergencyVehicles;
    private _hasLights       = !isNil { _veh getVariable "lights" };

    // Shift+L — Toggle siren lights (emergency sides only)
    if (_shift && _isEmergencySide && _isInVehicle && _isValidVehicle && _hasLights) then {
        switch (true) do {
            case (playerSide isEqualTo west):        { [_veh] call life_fnc_sirenLights;       };
            case (playerSide isEqualTo independent): { [_veh] call life_fnc_medicSirenLights;  };
        };
        _handled = true;
    };

    // L alone — Open radar (no modifier keys)
    if (!_handled && !_alt && !_ctrlKey && !_shift) then {
        [] call life_fnc_radar;
    };
};
*/

/*
██████████File: fn_keyHandler.sqf███████████
███████████████Author: Pager████████████████
██████████Date Created: 05.28.2026██████████
███████Date Modified: 05.28.2026 v2.0███████
*/

// ── Parameter unpacking ───────────────────────────────────────────────────────

params [
    ["_ctrl",    controlNull, [controlNull]],
    ["_code",    0,           [0]],
    ["_shift",   false,       [false]],
    ["_ctrlKey", false,       [false]],
    ["_alt",     false,       [false]]
];

private _handled  = false;
private _veh      = vehicle player;
private _inVeh    = (_veh != player);
private _isDriver = (_inVeh && { driver _veh == player });

// ── Key bindings ──────────────────────────────────────────────────────────────

private _interactionKey = if (count (actionKeys "User10") == 0)
                            then { 219 }
                            else { (actionKeys "User10") select 0 };
private _mapKey         = (actionKeys "ShowMap") select 0;

// Keys that interrupt long actions (W, A, S, D)
private _interruptionKeys = [17, 30, 31, 32];

// ── Guard: restrained players can only vault / salute ─────────────────────────

if ((_code in (actionKeys "GetOver") || _code in (actionKeys "salute"))
    && { player getVariable ["restrained", false] }) exitWith { true };

// ── Guard: action in progress ─────────────────────────────────────────────────

if (life_action_inUse) exitWith {
    if (!life_interrupted && _code in _interruptionKeys) then {
        life_interrupted = true;
    };
    _handled
};

// ── Hotfix: interaction via inputAction (some OS can't bind User10) ───────────

if (count (actionKeys "User10") != 0 && { inputAction "User10" > 0 }) exitWith {
    if (!life_action_inUse) then {
        [] spawn {
            private _handle = [] spawn life_fnc_actionKeyHandler;
            waitUntil { scriptDone _handle };
            life_action_inUse = false;
        };
    };
    true
};

// ── Main switch ───────────────────────────────────────────────────────────────

switch (_code) do {

    // ── [SPACE] Jump ──────────────────────────────────────────────────────────
    case 57: {
        if (isNil "jumpActionTime") then { jumpActionTime = 0 };
        if (_shift
            && { !(animationState player == "AovrPercMrunSrasWrflDf") }
            && { isTouchingGround player }
            && { stance player == "STAND" }
            && { speed player > 2 }
            && { !life_is_arrested }
            && { (velocity player select 2) < 2.5 }
            && { time - jumpActionTime > 1.5 }) then {
            jumpActionTime = time;
            [player, true]  spawn life_fnc_jumpFnc;
            [player, false] remoteExec ["life_fnc_jumpFnc", RANY];
            _handled = true;
        };
    };

    // ── [MAP KEY] Open map + side markers ────────────────────────────────────
    case _mapKey: {
        switch (playerSide) do {
            case west:        { if (!visibleMap) then { [] spawn life_fnc_copMarkers;    } };
            case independent: { if (!visibleMap) then { [] spawn life_fnc_medicMarkers; } };
        };
    };

    // ── [H] Holster / recall weapon ───────────────────────────────────────────
    // Shift+H = holster | Ctrl+H = re-equip last weapon
    case 35: {
        if (_shift && !_ctrlKey && currentWeapon player != "") then {
            life_curWep_h = currentWeapon player;
            player action ["SwitchWeapon", player, player, 100];
            player switchCamera cameraView;
        };
        if (!_shift && _ctrlKey
            && !isNil "life_curWep_h"
            && { life_curWep_h != "" }) then {
            if (life_curWep_h in [RIFLE, LAUNCHER, PISTOL]) then {
                player selectWeapon life_curWep_h;
            };
        };
    };

    // ── [WIN / User10] Interaction menu ───────────────────────────────────────
    case _interactionKey: {
        if (!life_action_inUse) then {
            [] spawn {
                private _handle = [] spawn life_fnc_actionKeyHandler;
                waitUntil { scriptDone _handle };
                life_action_inUse = false;
            };
        };
    };

    // ── [R] Restrain (Shift+R, cops only) ─────────────────────────────────────
    case 19: {
        if (_shift) then { _handled = true };
        if (_shift
            && playerSide == west
            && { !isNull cursorTarget }
            && { cursorTarget isKindOf "Man" }
            && { isPlayer cursorTarget }
            && { side cursorTarget in [civilian, independent] }
            && { alive cursorTarget }
            && { cursorTarget distance player < 3.5 }
            && { !(cursorTarget getVariable "Escorting") }
            && { !(cursorTarget getVariable "restrained") }
            && { speed cursorTarget < 1 }) then {
            [] call life_fnc_restrainAction;
        };
    };

    // ── [G] Knock out (Shift+G, civilians only) ───────────────────────────────
    case 34: {
        if (_shift) then { _handled = true };
        if (_shift
            && playerSide == civilian
            && { !isNull cursorTarget }
            && { cursorTarget isKindOf "Man" }
            && { isPlayer cursorTarget }
            && { alive cursorTarget }
            && { cursorTarget distance player < 4 }
            && { speed cursorTarget < 1 }
            && { animationState cursorTarget != "Incapacitated" }
            && { currentWeapon player in [RIFLE, PISTOL] }
            && { currentWeapon player != "" }
            && { !life_knockout }
            && { !(player getVariable ["restrained", false]) }
            && { !life_istazed }) then {
            [cursorTarget] spawn life_fnc_knockoutAction;
        };
    };

    // ── [T] Trunk / inventory ─────────────────────────────────────────────────
    case 20: {
        if (!_alt && !_ctrlKey && !dialog && { !life_action_inUse }) then {
            if (_inVeh && alive _veh) then {
                if (_veh in life_vehicles) then {
                    [_veh] call life_fnc_openInventory;
                };
            } else {
                private _targetList = ["landVehicle", "Air", "Ship", "House_F"];
                if (cursorTarget isKindOf "Man"
                    && { isPlayer cursorTarget }
                    && { player distance cursorTarget < 4 }
                    && { vehicle player == player }
                    && { playerSide == west }
                    && { alive cursorTarget }) then {
                    // Search a player on the ground (cops only, downed target)
                    if (animationState cursorTarget == "Incapacitated") then {
                        [cursorTarget] call life_fnc_searchPlayer;
                    };
                } else {
                    if (KINDOF_ARRAY(cursorTarget, _targetList)
                        && { player distance cursorTarget < 7 }
                        && { vehicle player == player }
                        && { alive cursorTarget }
                        && { !life_action_inUse }) then {
                        if (cursorTarget in life_vehicles
                            || { !(cursorTarget getVariable ["locked", true]) }) then {
                            [cursorTarget] call life_fnc_openInventory;
                        };
                    };
                };
            };
        };
    };

    // ── [L] Lights + Radar ────────────────────────────────────────────────────
    case 38: { // L key
    private _veh = vehicle player;

    // Whitelisted emergency vehicles
    private _emergencyVehicles = [
        "C_Offroad_01_F",
        "C_Hatchback_01_sport_F",
        "C_SUV_01_F",
        "B_G_Offroad_01_F",
        "B_MRAP_01_F",
        "O_MRAP_02_F",
        "C_Offroad_02_unarmed_F"
    ];

    private _isEmergencySide = playerSide isEqualTo west || playerSide isEqualTo independent;
    private _isInVehicle     = _veh != player;
    private _isValidVehicle  = (typeOf _veh) in _emergencyVehicles;
    private _hasLights       = !isNil { _veh getVariable "lights" };

    // Shift+L — Toggle siren lights (emergency sides only)
    if (_shift && _isEmergencySide && _isInVehicle && _isValidVehicle && _hasLights) then {
        switch (true) do {
            case (playerSide isEqualTo west):        { [_veh] call life_fnc_sirenLights;       };
            case (playerSide isEqualTo independent): { [_veh] call life_fnc_medicSirenLights;  };
        };
        _handled = true;
    };

    // L alone — Open radar (no modifier keys)
    if (!_handled && !_alt && !_ctrlKey && !_shift) then {
        [] call life_fnc_radar;
        };
    };

    // ── [Y] Player menu ───────────────────────────────────────────────────────
    case 21: {
        if (!_alt && !_ctrlKey && !dialog && { !life_action_inUse }) then {
            [] call life_fnc_p_openMenu;
        };
    };

    // ── [F] Siren toggle ──────────────────────────────────────────────────────
    case 33: {
        if (playerSide in [west, independent]
            && { _inVeh }
            && { !life_siren_active }
            && { _isDriver }) then {
            [] spawn {
                life_siren_active = true;
                sleep 4.7;
                life_siren_active = false;
            };
            if (isNil { _veh getVariable "siren" }) then {
                _veh setVariable ["siren", false, true];
            };
            if (_veh getVariable "siren") then {
                titleText [localize "STR_MISC_SirensOFF", "PLAIN"];
                _veh setVariable ["siren", false, true];
            } else {
                titleText [localize "STR_MISC_SirensON", "PLAIN"];
                _veh setVariable ["siren", true, true];
                if (playerSide == west) then {
                    [_veh] remoteExec ["life_fnc_copSiren", RCLIENT];
                } else {
                    // Uncomment when medic siren sound is available:
                    // [_veh] remoteExec ["life_fnc_medicSiren", RCLIENT];
                };
            };
        };
    };

    // ── [O] Sound fade (Shift+O) ──────────────────────────────────────────────
    case 24: {
        if (_shift) then {
            if (soundVolume != 1) then {
                1 fadeSound 1;
                systemChat localize "STR_MISC_soundnormal";
            } else {
                1 fadeSound 0.1;
                systemChat localize "STR_MISC_soundfade";
            };
        };
    };

    // ── [U] Lock / unlock vehicle or house door ───────────────────────────────
    case 22: {
        if (!_alt && !_ctrlKey) then {
            private _target = if (_inVeh) then { _veh } else { cursorTarget };

            if (_target isKindOf "House_F" && { playerSide == civilian }) then {
                if (_target in life_vehicles && player distance _target < 8) then {
                    private _door = [_target] call life_fnc_nearestDoor;
                    if (_door == 0) exitWith { hint localize "STR_House_Door_NotNear" };
                    private _locked = _target getVariable [format ["bis_disabled_Door_%1", _door], 0];
                    if (_locked == 0) then {
                        _target setVariable [format ["bis_disabled_Door_%1", _door], 1, true];
                        _target animate [format ["door_%1_rot", _door], 0];
                        systemChat localize "STR_House_Door_Lock";
                    } else {
                        _target setVariable [format ["bis_disabled_Door_%1", _door], 0, true];
                        _target animate [format ["door_%1_rot", _door], 1];
                        systemChat localize "STR_House_Door_Unlock";
                    };
                };
            } else {
                if (_target in life_vehicles && player distance _target < 8) then {
                    private _lockState = locked _target;
                    private _newLock   = if (_lockState == 2) then { 0 } else { 2 };
                    private _msg       = if (_lockState == 2)
                                            then { localize "STR_MISC_VehUnlock" }
                                            else { localize "STR_MISC_VehLock"   };
                    if (local _target) then {
                        _target lock _newLock;
                    } else {
                        [_target, _newLock] remoteExecCall ["life_fnc_lockVehicle", _target];
                    };
                    systemChat _msg;
                };
            };
        };
    };

    // ── [X] Surrender (Shift+X, civilians only) ───────────────────────────────
    case 45: {
        if (_shift && playerSide == civilian && { vehicle player == player }) then {
            if (!isNil "life_fnc_surrender") then {
                [] call life_fnc_surrender;
                _handled = true;
            };
        };
    };

    // ── [K] Zip-ties / Escort toggle (Shift+K, cops only) ────────────────────
    case 37: {
        if (_shift && playerSide == west) then {
            if (!isNull cursorTarget
                && { cursorTarget isKindOf "Man" }
                && { isPlayer cursorTarget }
                && { alive cursorTarget }
                && { cursorTarget distance player < 3.5 }
                && { cursorTarget getVariable ["restrained", false] }) then {
                if (cursorTarget getVariable ["Escorting", false]) then {
                    [cursorTarget] call life_fnc_stopEscort;
                } else {
                    [cursorTarget] call life_fnc_startEscort;
                };
                _handled = true;
            };
        };
    };

    // ── [B] Breathalyser / Licence check (Shift+B, cops only) ────────────────
    case 48: {
        if (_shift && playerSide == west) then {
            if (!isNull cursorTarget
                && { cursorTarget isKindOf "Man" }
                && { isPlayer cursorTarget }
                && { alive cursorTarget }
                && { cursorTarget distance player < 3.5 }) then {
                if (!isNil "life_fnc_checkLicenses") then {
                    [cursorTarget] call life_fnc_checkLicenses;
                    _handled = true;
                };
            };
        };
    };

    // ── [N] Notepad / notebook ────────────────────────────────────────────────
    case 49: {
        if (!_alt && !_ctrlKey && !dialog && { !life_action_inUse }) then {
            if (!isNil "life_fnc_openNotepad") then {
                [] call life_fnc_openNotepad;
                _handled = true;
            };
        };
    };

    // ── [M] Drag / carry downed player (Shift+M) ──────────────────────────────
    case 50: {
        if (_shift && { vehicle player == player }) then {
            if (!isNull cursorTarget
                && { cursorTarget isKindOf "Man" }
                && { isPlayer cursorTarget }
                && { !alive cursorTarget || animationState cursorTarget == "Incapacitated" }
                && { cursorTarget distance player < 4 }) then {
                if (!isNil "life_fnc_dragPlayer") then {
                    [cursorTarget] call life_fnc_dragPlayer;
                    _handled = true;
                };
            };
        };
    };
};

_handled
