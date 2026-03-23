#!/bin/bash

BASE_URL="https://github.com/arsy-01/main/releases/download/delta"
LAYOUT_URL="https://raw.githubusercontent.com/arsy-01/main/refs/heads/main/layout.sh"

# Fungsi inti untuk unduh dan instal
install_apk() {
    APK_NAME=$1
    EXPECTED_HASH=$2
    PAUSE=$3 # Parameter untuk menentukan apakah perlu menunggu tombol Enter
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
        
        echo "[*] Sedang menginstal $APK_NAME di latar belakang..."
        
        # Eksekusi instalasi via Root
        INSTALL_STATUS=$(su -c "pm install -r $FILE_PATH" < /dev/null 2>&1)
        
        if [[ "$INSTALL_STATUS" == *"Success"* ]]; then
            echo "[v] BERHASIL! $APK_NAME telah terinstal."
        else
            echo "[X] GAGAL MENGINSTAL! Error: $INSTALL_STATUS"
        fi
    else
        echo "[!] ERROR: Gagal mengunduh $APK_NAME."
    fi
    
    # Jika instalasi satuan, minta tekan Enter. Jika "Install Semua", lewati.
    if [ "$PAUSE" == "true" ]; then
        echo ""
        read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
    else
        echo "-----------------------------------"
        sleep 1
    fi
}

# Fungsi Sub-Menu APK
apk_menu() {
    while true; do
        clear
        echo "-----------------------------------"
        echo "            INSTALL APK            "
        echo "-----------------------------------"
        echo "[1] Delta A"
        echo "[2] Delta B"
        echo "[3] Delta C"
        echo "[4] Delta D"
        echo "[5] Install Semua Sekaligus"
        echo "[0] Kembali ke Menu Utama"
        echo "-----------------------------------"
        read -p "Pilih APK [0-5]: " apk_choice

        case $apk_choice in
            1) install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" "true" ;;
            2) install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" "true" ;;
            3) install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" "true" ;;
            4) install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" "true" ;;
            5) 
                # Eksekusi berurutan tanpa jeda Enter di setiap aplikasi
                install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" "false"
                install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" "false"
                install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" "false"
                install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" "false"
                echo ""
                read -p "Semua instalasi selesai! Tekan [ENTER] untuk kembali..." dummy < /dev/tty
                ;;
            0) break ;; # Keluar dari loop apk_menu dan kembali ke menu utama
            *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
        esac
    done
}

run_layout() {
    clear
    echo "[*] Mengunduh dan menjalankan Setup Layout..."
    curl -sL "$LAYOUT_URL" | bash
    echo ""
    read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
}

# Looping Menu Utama
while true; do
    clear
    echo "-----------------------------------"
    echo "             MENU UTAMA            "
    echo "-----------------------------------"
    echo "[1] Install APK"
    echo "[2] Setup Layout"
    echo "[0] Keluar"
    echo "-----------------------------------"
    read -p "Pilih menu [0-2]: " main_choice

    case $main_choice in
        1) apk_menu ;;
        2) run_layout ;;
        0) clear; exit 0 ;;
        *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
    esac
done
