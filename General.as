bool DebugEnabled = true;



texttag CreateTextTag(string text, float x, float y, float size) {
    texttag t = Jass::CreateTextTag();
    Jass::SetTextTagText(t, text, size);
    Jass::SetTextTagPos(t, x, y, 60);
    Jass::SetTextTagColor(t, 255, 255, 255, 255);
    Jass::SetTextTagVisibility(t, true);
    Jass::SetTextTagVelocity(t, Jass::GetRandomReal(-0.02, 0.02), Jass::GetRandomReal(0.01, 0.03), 0);
    Jass::SetTextTagPermanent(t, false);
    return t;
}

texttag CreateTextTag(string text, unit u, float size) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    return CreateTextTag(text, x, y, size);
}

texttag CreateTextTag(string text, unit u) {
    return CreateTextTag(text, u, 0.02);
}

texttag CreateTextTagTimed(string text, unit u, float size, float lifespan) {
    float x = Jass::GetUnitX(u);
    float y = Jass::GetUnitY(u);
    texttag t = CreateTextTag(text, x, y, size);
    Jass::SetTextTagLifespan(t, lifespan);
    Jass::SetTextTagFadepoint(t, lifespan/4);
    return t;
}

void Heal(unit target, float amount) {
    if (target == nil) return;

    float current = Jass::GetUnitCurrentLife(target);
    float max = Jass::GetUnitMaxLife(target);
    float newLife = current + amount;

    if (newLife > max) {
        newLife = max;
    }
    Jass::SetTextTagColor(CreateTextTagTimed("" + int(amount), target, 0.02, 2.0), 100, 255, 100, 255);
    Jass::SetUnitCurrentLife(target, newLife);
}

void Heal(unit healer, unit target, float amount) {
    if (healer == nil || target == nil) return;
    UnitData@ healerData = GetUnitData(healer);
    UnitData@ targetData = GetUnitData(target);
    if (healerData is null || targetData is null) {Heal(target, amount); return;};
    amount *= 1 + healerData.totalStats.healOutput;
    amount *= 1 + targetData.totalStats.healReceived;
    Heal(target, amount);
    //TODO Store healed amount.
}

void Debug(string functionName, string message) {
    if (!DebugEnabled) return;

    int len = Jass::StringLength(message);
    if (len > 0 && Jass::SubString(message, 0, 1) == "\n") {
        message = Jass::SubString(message, 1, len);
    }

    Jass::ConsolePrint("\n[" + functionName + "] " + message);
}

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