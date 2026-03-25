#!/bin/bash

echo "=== 1. PERSIAPAN SISTEM & ORIENTASI ==="
su -c "settings put system accelerometer_rotation 0"
su -c "settings put system user_rotation 1"
echo "[+] Orientasi dikunci ke Landscape."
sleep 1

echo "=== 2. SCANNING APLIKASI ==="
apps=($(su -c "pm list packages" | grep "com.roblox.clien" | cut -d':' -f2 | tr -d '\r' | sort))
count=${#apps[@]}

if [ "$count" -eq 0 ]; then
    echo "[!] Tidak ada aplikasi ditemukan."
    exit 1
fi

SCREEN_RES=$(su -c "wm size" | awk '{print $NF}' | tail -n 1)
W=$(echo $SCREEN_RES | cut -d'x' -f1)
H=$(echo $SCREEN_RES | cut -d'x' -f2)

if [ "$W" -lt "$H" ]; then
    temp=$W
    W=$H
    H=$temp
fi

cols=1
while [ $((cols * cols)) -lt "$count" ]; do
    cols=$((cols + 1))
done
rows=$(( (count + cols - 1) / cols ))

OFFSET_TOP=35
H_USABLE=$(( H - OFFSET_TOP ))

cellW=$(( W / cols ))
cellH=$(( H_USABLE / rows ))

MARGIN_TEPI=2
GAP_ANTAR=2

echo "[+] Resolusi: ${W}x${H} | Grid: ${cols}x${rows}"

for i in "${!apps[@]}"; do
    app=${apps[$i]}
    ACTIVITY="$app/com.roblox.client.startup.ActivitySplash"
    
    echo "-----------------------------------"
    echo "-> Memproses ($((i+1))/$count): $app"
    
    su -c "am force-stop $app"
    sleep 0.5
    
    c=$(( i % cols ))
    r=$(( i / cols ))
    
    L=$(( c * cellW + MARGIN_TEPI ))
    R=$(( (c + 1) * cellW - MARGIN_TEPI ))
    T=$(( r * cellH + OFFSET_TOP + MARGIN_TEPI ))
    B=$(( (r + 1) * cellH + OFFSET_TOP - GAP_ANTAR ))
    
    echo "   [+] Kordinat: L:$L, T:$T, R:$R, B:$B"
    
    su -c "am start -n $ACTIVITY --windowingMode 5 > /dev/null 2>&1"
    sleep 3
    
    TASK_ID=$(su -c "dumpsys activity activities | grep 'TaskRecord' | grep '$app' | grep -o '#[0-9]*' | tr -d '#' | head -n 1")
    
    if [ -n "$TASK_ID" ]; then
        su -c "am task resize $TASK_ID $L $T $R $B > /dev/null 2>&1"
    else
        echo "   [!] Task ID tidak ditemukan."
    fi
    sleep 1.5
done
echo "=== DONE! ==="
