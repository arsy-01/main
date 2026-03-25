#!/bin/bash
echo "[*] Menjalankan layout.sh (Dynamic Grid Auto-Resize)..."

# --- TAMBAHAN: Memaksa Sistem Android Menjadi Landscape ---
echo "    [*] Mengunci layar ke mode Default (Landscape)..."
su -c 'settings put system accelerometer_rotation 0' > /dev/null 2>&1
su -c 'settings put system user_rotation 0' > /dev/null 2>&1
su -c 'content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:0' > /dev/null 2>&1
su -c 'wm rotation 0' > /dev/null 2>&1
sleep 2
# ----------------------------------------------------------

# Deteksi package Roblox
PACKAGES=$(su -c 'pm list packages' | grep -i 'roblox' | awk -F':' '{print $2}' | tr -d '\r')
TOTAL_APPS=$(echo "$PACKAGES" | wc -w)

if [ "$TOTAL_APPS" -eq 0 ]; then
    echo "    [!] Tidak ada aplikasi Roblox yang terdeteksi!"
    exit 1
fi

# 1. Menentukan jumlah grid (dibulatkan ke genap)
SLOTS=$TOTAL_APPS
if [ $((SLOTS % 2)) -ne 0 ]; then
    SLOTS=$((SLOTS + 1))
fi

# Menentukan kolom dan baris berdasarkan jumlah slot
if [ "$SLOTS" -le 2 ]; then COLS=2; ROWS=1
elif [ "$SLOTS" -le 4 ]; then COLS=2; ROWS=2
elif [ "$SLOTS" -le 6 ]; then COLS=3; ROWS=2
elif [ "$SLOTS" -le 8 ]; then COLS=4; ROWS=2
else COLS=4; ROWS=$(((SLOTS + 3) / 4))
fi

# 2. Mendapatkan Resolusi Layar Otomatis
RES=$(su -c 'wm size' | grep -o '[0-9]*x[0-9]*' | head -n 1)
W=$(echo "$RES" | cut -d'x' -f1)
H=$(echo "$RES" | cut -d'x' -f2)

# Pastikan perhitungan selalu menganggap layar sedang Landscape
if [ "$H" -gt "$W" ]; then
    TEMP=$W; W=$H; H=$TEMP
fi

# 3. Rumus Ukuran Jendela
BOX_W=$(( (W - 4 - (COLS - 1) * 4) / COLS ))
BOX_H=$(( (H - 40 - (ROWS - 1) * 4) / ROWS ))

echo "    [i] Resolusi: ${W}x${H} | Format Grid: ${COLS}x${ROWS}"

# 4. Mengeksekusi Resize ke setiap Aplikasi
INDEX=0
for pkg in $PACKAGES; do
    ROW=$(( INDEX / COLS ))
    COL=$(( INDEX % COLS ))

    LEFT=$(( 2 + COL * (BOX_W + 4) ))
    TOP=$(( 37 + ROW * (BOX_H + 4) ))
    RIGHT=$(( LEFT + BOX_W ))
    BOTTOM=$(( TOP + BOX_H ))

    echo " -> Memproses ($((INDEX+1))/$TOTAL_APPS): $pkg"
    
    # Menarik Task ID dari game untuk dieksekusi resizenya
    TASK_ID=$(su -c "dumpsys activity activities | grep -E 'TaskRecord.*$pkg' | grep -o '#[0-9]*' | tr -d '#' | head -n 1")
    
    if [ -n "$TASK_ID" ]; then
        su -c "am task resize $TASK_ID $LEFT $TOP $RIGHT $BOTTOM" > /dev/null 2>&1
    else
        echo "    [!] Gagal melacak Task ID untuk $pkg. Lewati..."
    fi

    INDEX=$(( INDEX + 1 ))
    sleep 1
done
echo "    *** LAYOUT SELESAI! ***"
