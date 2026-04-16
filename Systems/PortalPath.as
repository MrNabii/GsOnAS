// ============================================================
//  PortalPath.as — Система порталов + поиск кратчайшего пути
//  Порталы связаны парами (A↔B), двусторонняя телепортация.
//  Поиск пути учитывает цепочки порталов (BFS/Bellman-Ford).
// ============================================================

hashtable PP_HT = Jass::InitHashtable();

// ---- Данные порталов ----
int PP_Count = 0;
array<float> PP_X(50);
array<float> PP_Y(50);
array<int> PP_Link(50);       // индекс связанного портала

float PP_ENTER_RADIUS = 150.0; // радиус зоны входа в портал

// ---- Результат поиска пути (временные, перезаписываются при каждом вызове) ----
int PP_RouteLen = 0;           // кол-во порталов в маршруте
array<int> PP_Route(20);       // индексы порталов для входа (по порядку)
float PP_RouteDist = 0.0;     // итоговая дистанция маршрута

// ============================================================
//  Регистрация пары порталов
// ============================================================
void PP_RegisterPair(float x1, float y1, float x2, float y2) {
    int a = PP_Count;
    int b = PP_Count + 1;
    PP_X[a] = x1;  PP_Y[a] = y1;
    PP_X[b] = x2;  PP_Y[b] = y2;
    PP_Link[a] = b;
    PP_Link[b] = a;
    PP_Count += 2;

    PP_CreateTeleportTrigger(a);
    PP_CreateTeleportTrigger(b);
}

// ============================================================
//  Телепортация при входе в зону портала
// ============================================================
void PP_CreateTeleportTrigger(int portalIdx) {
    float px = PP_X[portalIdx];
    float py = PP_Y[portalIdx];
    float r = PP_ENTER_RADIUS;

    rect rc = Jass::Rect(px - r, py - r, px + r, py + r);
    region reg = Jass::CreateRegion();
    Jass::RegionAddRect(reg, rc);

    Jass::SaveInteger(PP_HT, Jass::GetHandleId(reg), 'pidx', portalIdx);

    trigger t = Jass::CreateTrigger();
    Jass::TriggerRegisterEnterRegion(t, reg, nil);
    Jass::TriggerAddAction(t, @PP_OnEnterPortal);

    Jass::RemoveRect(rc);
    rc = nil;
    t = nil;
    reg = nil;
}

void PP_OnEnterPortal() {
    unit u = Jass::GetEnteringUnit();
    int uid = Jass::GetHandleId(u);

    // Анти-рекурсия: если юнит только что телепортировался — пропуск
    if (Jass::HaveSavedBoolean(PP_HT, uid, 'tpcd') && Jass::LoadBoolean(PP_HT, uid, 'tpcd')) {
        u = nil;
        return;
    }

    region reg = Jass::GetTriggeringRegion();
    int portalIdx = Jass::LoadInteger(PP_HT, Jass::GetHandleId(reg), 'pidx');
    int destIdx = PP_Link[portalIdx];

    // Ставим кулдаун
    Jass::SaveBoolean(PP_HT, uid, 'tpcd', true);

    // Телепортируем
    Jass::SetUnitX(u, PP_X[destIdx]);
    Jass::SetUnitY(u, PP_Y[destIdx]);

    // Если это моб с маршрутом — продвинуть шаг и отдать следующий приказ
    if (Jass::IsUnitInGroup(u, WS_AliveWaveUnits)) {
        PP_OnMobTeleported(u);
    } else if (Jass::IsUnitHero(u)) {
        // Камера для героев
        if (Jass::GetLocalPlayer() == Jass::GetOwningPlayer(u)) {
            Jass::PanCameraToTimed(PP_X[destIdx], PP_Y[destIdx], 0.01);
        }
        Jass::IssueImmediateOrder(u, "stop");
    }

    // Снимаем кулдаун через 0.5 сек
    timer tmr = Jass::CreateTimer();
    Jass::SaveInteger(PP_HT, Jass::GetHandleId(tmr), 'uid', uid);
    Jass::TimerStart(tmr, 0.5, false, @PP_ClearCooldown);

    u = nil;
    reg = nil;
    tmr = nil;
}

void PP_ClearCooldown() {
    timer t = Jass::GetExpiredTimer();
    int th = Jass::GetHandleId(t);
    int uid = Jass::LoadInteger(PP_HT, th, 'uid');
    Jass::SaveBoolean(PP_HT, uid, 'tpcd', false);
    Jass::FlushChildHashtable(PP_HT, th);
    Jass::DestroyTimer(t);
    t = nil;
}

// ============================================================
//  Вспомогательные функции
// ============================================================
float PP_Dist(float x1, float y1, float x2, float y2) {
    float dx = x2 - x1;
    float dy = y2 - y1;
    return Jass::SquareRoot(dx * dx + dy * dy);
}

// ============================================================
//  Поиск ближайшего гоблина с учётом порталов
//  Возвращает unit гоблина, заполняет PP_Route / PP_RouteLen / PP_RouteDist
//
//  Алгоритм:
//   1. Bellman-Ford на графе порталов: dist[i] = мин. расстояние
//      от (startX,startY) до входа в портал i (через цепочки порталов).
//   2. Для каждого гоблина: min(прямое расстояние, через любой портал i:
//      dist[i] + расстояние(выход_портала_i → гоблин)).
//   3. Восстанавливаем маршрут через массив prev[].
// ============================================================
unit PP_FindNearestGoblin(float startX, float startY) {
    // ---- Bellman-Ford на графе порталов ----
    array<float> dist(PP_Count);
    array<int> prev(PP_Count);

    for (int i = 0; i < PP_Count; i++) {
        dist[i] = PP_Dist(startX, startY, PP_X[i], PP_Y[i]);
        prev[i] = -1;
    }

    int maxIter = PP_Count / 2 + 1;
    for (int iter = 0; iter < maxIter; iter++) {
        bool improved = false;
        for (int i = 0; i < PP_Count; i++) {
            // После входа в портал i → выход из link[i]
            int exitIdx = PP_Link[i];
            float exitX = PP_X[exitIdx];
            float exitY = PP_Y[exitIdx];

            for (int j = 0; j < PP_Count; j++) {
                if (j == i || j == exitIdx) continue;

                float newDist = dist[i] + PP_Dist(exitX, exitY, PP_X[j], PP_Y[j]);
                if (newDist < dist[j]) {
                    dist[j] = newDist;
                    prev[j] = i;
                    improved = true;
                }
            }
        }
        if (!improved) break;
    }

    // ---- Поиск ближайшего гоблина ----
    unit bestGoblin = nil;
    float bestDist = 999999.0;
    int bestPortal = -1;   // последний портал для входа (-1 = напрямую)

    for (int pn = 0; pn < 10; pn++) {
        unit g = GoblinUnit[pn];
        if (g == nil || !Jass::IsUnitAlive(g)) continue;

        float gx = Jass::GetUnitX(g);
        float gy = Jass::GetUnitY(g);

        // Прямое расстояние
        float directDist = PP_Dist(startX, startY, gx, gy);
        if (directDist < bestDist) {
            bestDist = directDist;
            bestGoblin = g;
            bestPortal = -1;
        }

        // Через каждый портал
        for (int i = 0; i < PP_Count; i++) {
            int exitIdx = PP_Link[i];
            float totalDist = dist[i] + PP_Dist(PP_X[exitIdx], PP_Y[exitIdx], gx, gy);
            if (totalDist < bestDist) {
                bestDist = totalDist;
                bestGoblin = g;
                bestPortal = i;
            }
        }
    }

    // ---- Восстановление маршрута ----
    PP_RouteLen = 0;
    PP_RouteDist = bestDist;

    if (bestPortal != -1) {
        // Собираем цепочку порталов (от конца к началу)
        array<int> chain(20);
        int chainLen = 0;
        int p = bestPortal;
        while (p != -1 && chainLen < 20) {
            chain[chainLen] = p;
            chainLen++;
            p = prev[p];
        }

        // Разворачиваем в правильный порядок
        PP_RouteLen = chainLen;
        for (int i = 0; i < chainLen; i++) {
            PP_Route[i] = chain[chainLen - 1 - i];
        }
    }

    return bestGoblin;
}

// ============================================================
//  Отладочный вывод маршрута
// ============================================================
void PP_PrintRoute(player p, unit goblin) {
    if (goblin == nil) {
        Jass::DisplayTimedTextToPlayer(p, 0, 0, 5, "|cFFff0000No goblin found|r");
        return;
    }

    string msg = "|cFF00ff00Nearest goblin|r dist: |cFFffcc00" + Jass::R2SW(PP_RouteDist, 1, 0) + "|r";

    if (PP_RouteLen == 0) {
        msg += " (direct)";
    } else {
        msg += " via |cFF00ccff" + Jass::I2S(PP_RouteLen) + "|r portal(s): ";
        for (int i = 0; i < PP_RouteLen; i++) {
            int idx = PP_Route[i];
            int dest = PP_Link[idx];
            if (i > 0) msg += " -> ";
            msg += "P" + Jass::I2S(idx) + "(" + Jass::R2SW(PP_X[idx], 1, 0) + "," + Jass::R2SW(PP_Y[idx], 1, 0) + ")";
            msg += "=>P" + Jass::I2S(dest) + "(" + Jass::R2SW(PP_X[dest], 1, 0) + "," + Jass::R2SW(PP_Y[dest], 1, 0) + ")";
        }
    }

    Jass::DisplayTimedTextToPlayer(p, 0, 0, 20, msg);
}

// ============================================================
//  Mob Pathfinding AI
// ============================================================

// Сохранить маршрут для юнита в PP_HT
// Ключи: uid -> 'rlen' (длина), 'rstp' (текущий шаг), 300+i (порталы),
//         'rtgx'/'rtgy' (координаты гоблина)
void PP_SaveRoute(unit u, unit goblin) {
    int uid = Jass::GetHandleId(u);
    Jass::SaveInteger(PP_HT, uid, 'rlen', PP_RouteLen);
    Jass::SaveInteger(PP_HT, uid, 'rstp', 0);
    Jass::SaveReal(PP_HT, uid, 'rtgx', Jass::GetUnitX(goblin));
    Jass::SaveReal(PP_HT, uid, 'rtgy', Jass::GetUnitY(goblin));
    for (int i = 0; i < PP_RouteLen; i++) {
        Jass::SaveInteger(PP_HT, uid, 300 + i, PP_Route[i]);
    }
}

// Отдать приказ юниту двигаться к следующей точке маршрута
void PP_IssueNextOrder(unit u) {
    int uid = Jass::GetHandleId(u);
    int rlen = Jass::LoadInteger(PP_HT, uid, 'rlen');
    int step = Jass::LoadInteger(PP_HT, uid, 'rstp');

    float tx;
    float ty;

    if (step < rlen) {
        // Идти к следующему порталу
        int portalIdx = Jass::LoadInteger(PP_HT, uid, 300 + step);
        tx = PP_X[portalIdx];
        ty = PP_Y[portalIdx];
    } else {
        // Идти напрямую к гоблину
        tx = Jass::LoadReal(PP_HT, uid, 'rtgx');
        ty = Jass::LoadReal(PP_HT, uid, 'rtgy');
    }

    if (!Jass::IssuePointOrder(u, "attack", tx, ty)) {
        Jass::IssuePointOrder(u, "move", tx, ty);
    }
}

// Обработать одного моба: найти путь, сохранить маршрут, отдать приказ
void PP_ProcessMob(unit u) {
    if (u == nil || !Jass::IsUnitAlive(u)) return;

    float ux = Jass::GetUnitX(u);
    float uy = Jass::GetUnitY(u);

    unit goblin = PP_FindNearestGoblin(ux, uy);
    if (goblin == nil) return;

    PP_SaveRoute(u, goblin);
    PP_IssueNextOrder(u);
}

// Вызывается после телепортации моба — продвигает шаг маршрута
void PP_OnMobTeleported(unit u) {
    int uid = Jass::GetHandleId(u);
    if (!Jass::HaveSavedInteger(PP_HT, uid, 'rlen')) return;

    int step = Jass::LoadInteger(PP_HT, uid, 'rstp');
    Jass::SaveInteger(PP_HT, uid, 'rstp', step + 1);
    PP_IssueNextOrder(u);
}

// Таймер — обработать всех мобов
void PP_MobTimerCallback() {
    // Обработать каждого моба
    int count = Jass::GroupGetCount(WS_AliveWaveUnits);
    for (int i = 0; i < count; i++) {
        unit u = Jass::GroupGetUnitByIndex(WS_AliveWaveUnits, i);
        PP_ProcessMob(u);
    }
}

// ============================================================
//  Инициализация — регистрация пар порталов
//  Вызывать из GameStart после InitSpawnTrigger
//  ЗАПОЛНИТЕ координаты своих порталов:
// ============================================================
void InitPortalPath() {

    // Пары порталов (u1 <-> u2)
    PP_RegisterPair(12157, -420, 13402, -393);
    PP_RegisterPair(15100, -308, -7175, -1296);
    PP_RegisterPair(7897, 2003, 6953, 2770);
    PP_RegisterPair(-393.5, -6934, 7715, 5135);
    PP_RegisterPair(11060.5, 5220, 9588, -7072);
    PP_RegisterPair(7604.5, -1408, -7173, 2923);
    PP_RegisterPair(-6858.5, -6316, 7750, -6647);
    PP_RegisterPair(-4299.5, 7030, -2748, -1312);

    // Периодический таймер для AI мобов (каждые 7 секунд)
    timer ppAiTimer = Jass::CreateTimer();
    Jass::TimerStart(ppAiTimer, 7.0, true, @PP_MobTimerCallback);
    ppAiTimer = nil;

    Debug("InitPortalPath", "\nPortalPath system initialized, portals: " + Jass::I2S(PP_Count));
}
