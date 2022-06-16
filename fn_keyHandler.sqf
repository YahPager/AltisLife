    case 38: { //L Key? If cop run checks for turning lights on.      
        if (_shift && playerSide in [west,independent]) then {
            if (!(isNull objectParent player) && (typeOf vehicle player) in ["C_Offroad_01_F","C_Hatchback_01_sport_F","C_SUV_01_F","B_G_Offroad_01_F","B_MRAP_01_F","O_MRAP_02_F","C_Offroad_02_unarmed_F"]) then {
                if (!isNil {vehicle player getVariable "lights"}) then {
                    if (playerSide isEqualTo west) then {
                        [vehicle player] call life_fnc_sirenLights;
                    } else {
                        [vehicle player] call life_fnc_medicSirenLights;
                    };
                    _handled = true;
                };
            };
        };
        if (!_alt && !_ctrlKey) then { [] call life_fnc_radar; };
    };
    
