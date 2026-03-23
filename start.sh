#!/bin/bash
set -e

# 컬러 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;97m'
NC='\033[0m'

log_info()    { echo -e "[$(date '+%H:%M:%S')] ${GREEN}[HumanitZ/INFO]${NC} ${WHITE}$1${NC}"; }
log_warn()    { echo -e "[$(date '+%H:%M:%S')] ${YELLOW}[HumanitZ/WARN]${NC} ${WHITE}$1${NC}"; }
log_error()   { echo -e "[$(date '+%H:%M:%S')] ${RED}[HumanitZ/ERROR]${NC} ${WHITE}$1${NC}"; }

echo -e "${CYAN}"
echo "  _   _                              _ _   ____"
echo " | | | |_   _ _ __ ___   __ _ _ __ (_) |_|_  /"
echo " | |_| | | | | '_ \` _ \ / _\` | '_ \| | __/ / "
echo " |  _  | |_| | | | | | | (_| | | | | | |_ / /_"
echo " |_| |_|\__,_|_| |_| |_|\__,_|_| |_|_|\__/____|"
echo -e "${NC}"
echo -e "${WHITE} Dedicated Server${NC}"
echo -e "${YELLOW} by Zerglrisk with Claude Sonnet 4.6${NC}"
echo ""

# root로 실행된 경우에만 유저 변경 후 재실행
if [ "$(id -u)" = "0" ]; then
    log_info "Setting up user permissions (PUID=${PUID:-1000}, PGID=${PGID:-1000})..."
    usermod -u ${PUID:-1000} steam
    groupmod -g ${PGID:-1000} steam
    chown -R steam:steam /home/steam
    log_info "Restarting as steam user..."
    exec gosu steam "$0" "$@"
fi

log_info "Running as: $(id)"

# 처음 설치 여부 확인
REF_FILE="/home/steam/serverfiles/HumanitZServer/REF_GameServerSettings.ini"
FIRST_INSTALL=false
if [ ! -f "$REF_FILE" ]; then
    FIRST_INSTALL=true
fi

# 업데이트 전 버전 저장
BEFORE_VERSION=$(grep "^Version=" "$REF_FILE" 2>/dev/null | cut -d= -f2 | tr -d '\r' || echo "")

log_info "Updating HumanitZ server files..."
if [ "${STEAMCMD_DEBUG:-false}" = "true" ]; then
    steamcmd +force_install_dir /home/steam/serverfiles \
        +login anonymous \
        +app_update 2728330 -beta linuxbranch validate \
        +quit
else
    steamcmd +force_install_dir /home/steam/serverfiles \
        +login anonymous \
        +app_update 2728330 -beta linuxbranch validate \
        +quit 2>&1 | grep -E "^Error|^Failed|fully installed|up to date" || true
fi

# 업데이트 후 버전 확인
AFTER_VERSION=$(grep "^Version=" "$REF_FILE" 2>/dev/null | cut -d= -f2 | tr -d '\r' || echo "")

if [ "${FIRST_INSTALL}" = "true" ]; then
    log_info "Server files installed. (v$AFTER_VERSION)"    
elif [ "$BEFORE_VERSION" != "$AFTER_VERSION" ]; then
    log_info "Server updated: v$BEFORE_VERSION → v$AFTER_VERSION"
else
    log_info "Server is up to date. (v$AFTER_VERSION)"
fi

log_info "Applying server configuration..."
CONFIG_DIR="/home/steam/serverfiles/HumanitZServer"
INI_FILE="$CONFIG_DIR/GameServerSettings.ini"
mkdir -p "$CONFIG_DIR"

if [ ! -f "$INI_FILE" ]; then
    log_info "No config found, copying from REF..."
    cp "$REF_FILE" "$INI_FILE"
fi

sed -i "/^Version=/d" "$INI_FILE"
[ -n "$VERSION" ] && sed -i "/^\[World Settings\]/a Version=$VERSION" "$INI_FILE"

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

log_info "Configuration applied."
log_info "Starting HumanitZ Dedicated Server on port ${PORT:-7777}..."

cd /home/steam/serverfiles
chmod +x HumanitZServer.sh
exec ./HumanitZServer.sh -log -port=${PORT:-7777} -queryport=${QUERY_PORT:-27015}