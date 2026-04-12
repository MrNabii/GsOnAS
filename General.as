bool IsUnitEngineer(unit u) {
    return Jass::GetUnitTypeId(u) == 'N000' || Jass::GetUnitTypeId(u) == 'N100';
}

bool IsUnitPirik(unit u) {
    return Jass::GetUnitTypeId(u) == 'N001' || Jass::GetUnitTypeId(u) == 'N101';
}

void DisplayTextToPlayers(string text) {
    for (int i = 0; i < 16; i++) {
        if (Jass::IsPlayerInForce(Jass::Player(i), PlayerForces)) {
            Jass::DisplayTextToPlayer(Jass::Player(i), 0, 0, text);
        }
    }
}

string PlayerColour(int pn) {
    if (pn == 1) return "|c00FF0000";
    if (pn == 2) return "|c000000FF";
    if (pn == 3) return "|c001CE6B9";
    if (pn == 4) return "|c00540081";
    if (pn == 5) return "|c00FFFC01";
    if (pn == 6) return "|c00FEBA0E";
    if (pn == 7) return "|c0020C000";
    if (pn == 8) return "|c00E55BB0";
    if (pn == 9) return "|c00C0C0C0";
    if (pn == 10) return "|c007EBFF1";
    if (pn == 11) return "|c00106246";
    if (pn == 12) return "|c004E2A04";
    return "|c00FFFFFF";
}

int forceCountPlayers = 0;
int CountPlayersInForce(force f) {
    forceCountPlayers = 0;
    Jass::ForForce(f, function(){
        forceCountPlayers += 1;
    });
    return forceCountPlayers;
}

bool RectContainsCoords(rect r, float x, float y) {
    return (Jass::GetRectMinX(r) <= x) and (x <= Jass::GetRectMaxX(r)) and (Jass::GetRectMinY(r) <= y) and (y <= Jass::GetRectMaxY(r));
}