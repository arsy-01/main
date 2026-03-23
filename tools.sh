#!/bin/bash

BASE_URL="https://github.com/arsy-01/main/releases/download/delta"
LAYOUT_URL="https://raw.githubusercontent.com/arsy-01/main/refs/heads/main/layout.sh"

install_apk() {
    APK_NAME=$1
    EXPECTED_HASH=$2
    FILE_PATH="/sdcard/Download/${APK_NAME}"

    clear
    echo "[*] Mengunduh $APK_NAME..."
    rm -f "$FILE_PATH" # Bersihkan file lama
    
    curl -L -# -o "$FILE_PATH" "${BASE_URL}/${APK_NAME}"

    if [ -f "$FILE_PATH" ]; then
        echo "[*] Memverifikasi integritas file (SHA256)..."
        ACTUAL_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')
        
        if [ "$ACTUAL_HASH" == "$EXPECTED_HASH" ]; then
            echo "[*] Verifikasi sukses!"
        else
            echo "[!] WARNING: Hash SHA256 berbeda! (Abaikan jika ini file update terbaru)"
        fi
        
        echo "[*] Sedang menginstal di latar belakang (Silent Install)..."
        echo "[*] Mohon tunggu sebentar..."
        
        # Eksekusi instalasi via Root (-r untuk Update/Reinstall tanpa hapus data)
        INSTALL_STATUS=$(su -c "pm install -r $FILE_PATH")
        
        if [[ "$INSTALL_STATUS" == *"Success"* ]]; then
            echo "[v] BERHASIL! $APK_NAME telah terinstal/diperbarui."
        else
            echo "[X] GAGAL MENGINSTAL! Error: $INSTALL_STATUS"
        fi
    else
        echo "[!] ERROR: Gagal mengunduh $APK_NAME."
    fi
    
    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

run_layout() {
    clear
    echo "[*] Mengunduh dan menjalankan Setup Layout..."
    curl -sL "$LAYOUT_URL" | bash
    echo ""
    read -p "Tekan [ENTER] untuk kembali ke menu..."
}

while true; do
    clear
    echo "-----------------------------------"
    echo "             MENU UTAMA            "
    echo "-----------------------------------"
    echo "[1] Install / Update Delta A"
    echo "[2] Install / Update Delta B"
    echo "[3] Install / Update Delta C"
    echo "[4] Install / Update Delta D"
    echo "[5] Setup Layout"
    echo "[0] Keluar"
    echo "-----------------------------------"
    read -p "Pilih menu [0-5]: " choice

    case $choice in
        1) install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" ;;
        2) install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" ;;
        3) install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" ;;
        4) install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" ;;
        5) run_layout ;;
        0) clear; exit 0 ;;
        *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
    esac
done
