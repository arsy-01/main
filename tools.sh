#!/bin/bash

BASE_URL="https://github.com/arsy-01/main/releases/download/delta"
LAYOUT_URL="https://raw.githubusercontent.com/arsy-01/main/refs/heads/main/layout.sh"
CONFIG_FILE="/sdcard/Download/.vip_link_arsy.txt"

# ==========================================
# FUNGSI BANTUAN
# ==========================================
drop_android_ram() {
    # Membuang cache RAM Kernel secara paksa via Root
    su -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
}

get_roblox_packages() {
    # Mendeteksi semua aplikasi dengan package name yang mengandung 'roblox'
    su -c 'pm list packages' | grep -i 'roblox' | awk -F':' '{print $2}' | tr -d '\r'
}

execute_layout() {
    echo "[*] Mengunduh dan mengeksekusi Setup Layout..."
    curl -sL "$LAYOUT_URL" | bash
    sleep 2
}

# ==========================================
# FUNGSI INSTALL APK
# ==========================================
install_apk() {
    APK_NAME=$1
    EXPECTED_HASH=$2
    PAUSE=$3
    FILE_PATH="/sdcard/Download/${APK_NAME}"

    clear
    echo "[*] Mengunduh $APK_NAME..."
    rm -f "$FILE_PATH"
    
    curl -L -# -o "$FILE_PATH" "${BASE_URL}/${APK_NAME}"

    if [ -f "$FILE_PATH" ]; then
        echo "[*] Memverifikasi integritas file..."
        ACTUAL_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')
        
        if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
            echo "[!] WARNING: Hash SHA256 berbeda! (Abaikan jika file update)"
        fi
        
        echo "[*] Sedang menginstal $APK_NAME..."
        INSTALL_STATUS=$(su -c "pm install -r $FILE_PATH" < /dev/null 2>&1)
        
        if [[ "$INSTALL_STATUS" == *"Success"* ]]; then
            echo "[v] BERHASIL! $APK_NAME terinstal."
        else
            echo "[X] GAGAL MENGINSTAL! Error: $INSTALL_STATUS"
        fi
    else
        echo "[!] ERROR: Gagal mengunduh $APK_NAME."
    fi
    
    if [ "$PAUSE" == "true" ]; then
        echo ""
        read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
    else
        echo "-----------------------------------"
        sleep 1
    fi
}

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
                install_apk "Deltaa.apk" "4d92bfdcf2124b567cf29eb0b5e1eb3ba52bcc14304d1ede729fe4fcd3775378" "false"
                install_apk "Deltab.apk" "b91f1106da9c326c07d6d906f5c88e1c8e4655ca8d5d7e14b686080529d8ba5b" "false"
                install_apk "Deltac.apk" "2dcf91449ff5ce46a0b2ccf8379f3a978526d1e052f735207706283b33cbca65" "false"
                install_apk "Deltad.apk" "a45ba2682b62fd75ddb00d4711d75d734d0c7dd15c43c6b97e8ccd1416a956e4" "false"
                echo ""
                read -p "Semua instalasi selesai! Tekan [ENTER] untuk kembali..." dummy < /dev/tty
                ;;
            0) break ;;
            *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
        esac
    done
}

# ==========================================
# FUNGSI INPUT LINK VIP
# ==========================================
input_vip_link() {
    clear
    echo "-----------------------------------"
    echo "       INPUT VIP SERVER LINK       "
    echo "-----------------------------------"
    local current_link=""
    if [ -f "$CONFIG_FILE" ]; then
        current_link=$(cat "$CONFIG_FILE")
    fi
    echo "Link Saat Ini: ${current_link:-[KOSONG]}"
    echo ""
    read -p "Masukkan Link VIP baru: " new_link
    
    if [ -n "$new_link" ]; then
        echo "$new_link" > "$CONFIG_FILE"
        echo "[+] Link VIP berhasil disimpan!"
    else
        echo "[!] Input kosong, dibatalkan."
    fi
    sleep 2
}

# ==========================================
# SUB-MENU SETUP & JALANKAN APLIKASI
# ==========================================
run_layout_and_engine() {
    while true; do
        clear
        echo "-----------------------------------"
        echo "     SETUP LAYOUT & JALANKAN       "
        echo "-----------------------------------"
        echo "[1] Setup Layout (Normal Open untuk Login)"
        echo "[2] Jalankan Aplikasi (Auto VIP + Mode AFK)"
        echo "[0] Kembali ke Menu Utama"
        echo "-----------------------------------"
        read -p "Pilih menu [0-2]: " run_choice

        case $run_choice in
            1)
                clear
                echo "[*] Memulai proses Setup Layout & Buka Aplikasi..."
                execute_layout
                
                PACKAGES=$(get_roblox_packages)
                if [ -z "$PACKAGES" ]; then
                    echo "[!] Tidak ada aplikasi Roblox yang terdeteksi!"
                    sleep 2
                    continue
                fi

                echo "[*] Menghentikan semua instance agar fresh..."
                for pkg in $PACKAGES; do
                    su -c "am force-stop $pkg"
                done
                sleep 2

                echo "[*] Membuka semua aplikasi untuk Login..."
                for pkg in $PACKAGES; do
                    echo " -> Membuka $pkg..."
                    # Menggunakan 'monkey' untuk membuka app secara default tanpa link intent
                    su -c "monkey -p $pkg -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1"
                    sleep 1
                done
                
                echo ""
                echo "[+] Selesai! Silakan login ke akun Anda di masing-masing aplikasi."
                read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
                ;;
            2)
                clear
                if [ ! -f "$CONFIG_FILE" ]; then
                    echo "[!] Link VIP belum diatur! Silakan isi di Menu Utama."
                    sleep 2
                    continue
                fi
                VIP_LINK=$(cat "$CONFIG_FILE")
                
                echo "[*] Memulai proses Setup Layout & Mesin Auto AFK..."
                execute_layout

                PACKAGES=$(get_roblox_packages)
                if [ -z "$PACKAGES" ]; then
                    echo "[!] Tidak ada aplikasi Roblox yang terdeteksi!"
                    sleep 2
                    continue
                fi

                echo "[*] Menghentikan semua instance agar fresh..."
                for pkg in $PACKAGES; do
                    su -c "am force-stop $pkg"
                done
                sleep 2

                echo "[*] Membawa Termux ke Background (Menuju Home Screen)..."
                # Mensimulasikan tombol Home agar Termux berjalan senyap di belakang
                su -c "input keyevent 3"
                sleep 2

                # Karena Termux di-hide, kita jalankan Roblox di atasnya
                echo "[*] Membuka VIP Server di semua instance..."
                for pkg in $PACKAGES; do
                    su -c "am start -a android.intent.action.VIEW -d \"$VIP_LINK\" $pkg > /dev/null 2>&1"
                    sleep 1
                done

                # Optimasi awal
                drop_android_ram

                # Menangkap perintah CTRL+C jika Anda membuka Termux lagi
                trap "echo -e '\n[!] Keluar dari Mode AFK...'; break" INT
                loop_count=1
                
                # Proses RAM berjalan senyap di background setiap 5 Menit (300 Detik)
                while true; do
                    sleep 300
                    drop_android_ram
                    ((loop_count++))
                done
                trap - INT # Reset fungsi CTRL+C ke default setelah loop selesai
                ;;
            0) break ;;
            *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
        esac
    done
}

# ==========================================
# MENU UTAMA
# ==========================================
while true; do
    clear
    echo "-----------------------------------"
    echo "             MENU UTAMA            "
    echo "-----------------------------------"
    echo "[1] Install APK"
    echo "[2] Input Link VIP Server"
    echo "[3] Setup Layout & Jalankan Aplikasi"
    echo "[0] Keluar"
    echo "-----------------------------------"
    
    STATUS_LINK="[KOSONG]"
    if [ -f "$CONFIG_FILE" ]; then
        STATUS_LINK="[Terisi]"
    fi
    echo "* Status VIP Link: $STATUS_LINK"
    echo "-----------------------------------"
    
    read -p "Pilih menu [0-3]: " main_choice

    case $main_choice in
        1) apk_menu ;;
        2) input_vip_link ;;
        3) run_layout_and_engine ;;
        0) clear; exit 0 ;;
        *) echo "[!] Pilihan tidak valid"; sleep 1 ;;
    esac
done
