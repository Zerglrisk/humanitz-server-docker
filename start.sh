#!/bin/bash
set -e

# root로 실행된 경우에만 유저 변경 후 재실행
if [ "$(id -u)" = "0" ]; then
    echo "=== steam 유저 UID/GID 변경 ==="
    usermod -u ${PUID:-1000} steam
    groupmod -g ${PGID:-1000} steam
    chown -R steam:steam /home/steam
    echo "=== steam 유저로 재실행 ==="
    exec gosu steam "$0" "$@"
fi

# 여기서부터는 steam 유저로 실행됨
echo "=== 현재 실행 유저 정보 ==="
id

echo "=== HumanitZ 서버 파일 업데이트 중... ==="
steamcmd +force_install_dir /home/steam/serverfiles \
    +login anonymous \
    +app_update 2728330 -beta linuxbranch validate \
    +quit

echo "=== 서버 설정 적용 중... ==="
CONFIG_DIR="/home/steam/serverfiles/HumanitZServer"
REF_FILE="/home/steam/serverfiles/HumanitZServer/REF_GameServerSettings.ini"
INI_FILE="$CONFIG_DIR/GameServerSettings.ini"
mkdir -p "$CONFIG_DIR"

# ini 없을 때만 REF에서 복사
if [ ! -f "$INI_FILE" ]; then
    echo "=== ini 파일 없음, REF에서 복사 ==="
    cp "$REF_FILE" "$INI_FILE"
fi

# Version 라인 항상 삭제 후 환경변수 있으면 다시 추가
sed -i "/^Version=/d" "$INI_FILE"
[ -n "$VERSION" ] && sed -i "/^\[World Settings\]/a Version=$VERSION" "$INI_FILE"

# 환경변수 있는 것만 덮어쓰기 (매번 적용)
[ -n "$SERVER_NAME" ]     && sed -i "s|^ServerName=.*|ServerName=\"$SERVER_NAME\"|" "$INI_FILE"
[ -n "$SERVER_PASSWORD" ] && sed -i "s|^Password=.*|Password=\"$SERVER_PASSWORD\"|" "$INI_FILE"
[ -n "$ADMIN_PASSWORD" ]  && sed -i "s|^AdminPass=.*|AdminPass=\"$ADMIN_PASSWORD\"|" "$INI_FILE"
[ -n "$MAX_PLAYERS" ]     && sed -i "s|^MaxPlayers=.*|MaxPlayers=$MAX_PLAYERS|" "$INI_FILE"
[ -n "$SAVE_NAME" ]       && sed -i "s|^SaveName=.*|SaveName=\"$SAVE_NAME\"|" "$INI_FILE"
[ -n "$SEARCH_ID" ]       && sed -i "s|^SearchID=.*|SearchID=\"$SEARCH_ID\"|" "$INI_FILE"
[ -n "$RCON_ENABLED" ]    && sed -i "s|^RCONEnabled=.*|RCONEnabled=$RCON_ENABLED|" "$INI_FILE"
[ -n "$RCON_PASSWORD" ]   && sed -i "s|^RCONPass=.*|RCONPass=\"$RCON_PASSWORD\"|" "$INI_FILE"
[ -n "$PVP" ]             && sed -i "s|^PVP=.*|PVP=$PVP|" "$INI_FILE"
[ -n "$PERMA_DEATH" ]     && sed -i "s|^PermaDeath=.*|PermaDeath=$PERMA_DEATH|" "$INI_FILE"
[ -n "$ON_DEATH" ]        && sed -i "s|^OnDeath=.*|OnDeath=$ON_DEATH|" "$INI_FILE"
[ -n "$VITAL_DRAIN" ]     && sed -i "s|^VitalDrain=.*|VitalDrain=$VITAL_DRAIN|" "$INI_FILE"
[ -n "$XP_MULTIPLIER" ]   && sed -i "s|^XpMultiplier=.*|XpMultiplier=$XP_MULTIPLIER|" "$INI_FILE"
[ -n "$SAVE_INTERVAL" ]   && sed -i "s|^SaveIntervalSec=.*|SaveIntervalSec=$SAVE_INTERVAL|" "$INI_FILE"
[ -n "$ZOMBIE_HEALTH" ]   && sed -i "s|^ZombieDiffHealth=.*|ZombieDiffHealth=$ZOMBIE_HEALTH|" "$INI_FILE"
[ -n "$ZOMBIE_SPEED" ]    && sed -i "s|^ZombieDiffSpeed=.*|ZombieDiffSpeed=$ZOMBIE_SPEED|" "$INI_FILE"
[ -n "$ZOMBIE_DAMAGE" ]   && sed -i "s|^ZombieDiffDamage=.*|ZombieDiffDamage=$ZOMBIE_DAMAGE|" "$INI_FILE"
[ -n "$ZOMBIE_AMOUNT" ]   && sed -i "s|^ZombieAmountMulti=.*|ZombieAmountMulti=$ZOMBIE_AMOUNT|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityFood=.*|RarityFood=$LOOT_RARITY|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityDrink=.*|RarityDrink=$LOOT_RARITY|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityMelee=.*|RarityMelee=$LOOT_RARITY|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityRanged=.*|RarityRanged=$LOOT_RARITY|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityAmmo=.*|RarityAmmo=$LOOT_RARITY|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityArmor=.*|RarityArmor=$LOOT_RARITY|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityResources=.*|RarityResources=$LOOT_RARITY|" "$INI_FILE"
[ -n "$LOOT_RARITY" ]     && sed -i "s|^RarityOther=.*|RarityOther=$LOOT_RARITY|" "$INI_FILE"

echo "=== 서버 시작 ==="
cd /home/steam/serverfiles
chmod +x HumanitZServer.sh
exec ./HumanitZServer.sh -log -port=${PORT:-7777} -queryport=${QUERY_PORT:-27015}