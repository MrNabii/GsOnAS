bool IsUnitEngineer(unit u) {
    return Jass::GetUnitTypeId(u) == 'N000' || Jass::GetUnitTypeId(u) == 'N100';
}

bool IsUnitPirik(unit u) {
    return Jass::GetUnitTypeId(u) == 'N001' || Jass::GetUnitTypeId(u) == 'N101';
}