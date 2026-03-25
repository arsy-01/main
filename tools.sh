#!/bin/bash

BASE_URL="https://github.com/arsy-01/main/releases/download/delta"
LAYOUT_URL="https://raw.githubusercontent.com/arsy-01/main/refs/heads/main/layout.sh"
CONFIG_FILE="/sdcard/Download/.vip_link_arsy.txt"

# ==========================================
# FUNGSI BANTUAN
# ==========================================
drop_android_ram() {
    su -c 'am kill-all' > /dev/null 2>&1
    PACKAGES=$(get_roblox_packages)
    for pkg in $PACKAGES; do
        su -c "cmd activity send-trim-memory $pkg RUNNING_LOW" > /dev/null 2>&1
    done
}

get_roblox_packages() {
    su -c 'pm list packages' | grep -i 'roblox' | awk -F':' '{print $2}' | tr -d '\r'
}

execute_layout() {
    echo "[*] Mengunduh dan mengeksekusi Setup Layout dari GitHub..."
    curl -sL "$LAYOUT_URL" | bash
    sleep 2
}

deploy_lua_script() {
    echo "[*] Mempersiapkan injeksi file Lua ke Delta..."
    PACKAGES=$(get_roblox_packages)
    LUA_CONTENT='loadstring(game:HttpGet("https://raw.githubusercontent.com/arsy-01/main/main/card.lua"))()'
    
    for pkg in $PACKAGES; do
        DIR_AUTOEXEC="/sdcard/Android/data/$pkg/files/gloop/external/Autoexecute"
        DIR_SCRIPTS="/sdcard/Android/data/$pkg/files/gloop/external/Scripts"
        
        echo " -> Memproses $pkg..."
        
        if su -c "[ -d \"$DIR_AUTOEXEC\" ]"; then
            su -c "echo '$LUA_CONTENT' > \"$DIR_AUTOEXEC/arsy_card.lua\""
            echo "    [v] Berhasil ditambahkan di folder Autoexecute"
        else
            echo "    [!] Folder Autoexecute belum ada (Dilewati)"
        fi
        
        if su -c "[ -d \"$DIR_SCRIPTS\" ]"; then
            su -c "echo '$LUA_CONTENT' > \"$DIR_SCRIPTS/arsy_card.lua\""
            echo "    [v] Berhasil ditambahkan di folder Scripts"
        else
            echo "    [!] Folder Scripts belum ada (Dilewati)"
        fi
    done
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
        echo "[*] Memverifikasi dan menginstal..."
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

input_vip_link() {
    clear
    echo "-----------------------------------"
    echo "       INPUT VIP SERVER LINK       "
    echo "-----------------------------------"
    local current_link=""
    if [ -f "$CONFIG_FILE" ]; then current_link=$(cat "$CONFIG_FILE"); fi
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
                echo "[*] Memulai proses Buka Aplikasi & Setup Layout..."
                PACKAGES=$(get_roblox_packages)
                if [ -z "$PACKAGES" ]; then echo "[!] Tidak ada aplikasi Roblox yang terdeteksi!"; sleep 2; continue; fi

                echo "[*] Menghentikan semua instance agar fresh..."
                for pkg in $PACKAGES; do su -c "am force-stop $pkg"; done
                sleep 2

                deploy_lua_script

                echo "[*] Membuka semua aplikasi untuk Login..."
                for pkg in $PACKAGES; do
                    echo " -> Membuka $pkg..."
                    su -c "monkey -p $pkg -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1"
                    sleep 3
                done
                
                execute_layout
                
                echo ""
                echo "[+] Selesai! Aplikasi sudah berukuran Grid. Silakan login ke akun Anda."
                read -p "Tekan [ENTER] untuk kembali..." dummy < /dev/tty
                ;;
            2)
                clear
                if [ ! -f "$CONFIG_FILE" ]; then echo "[!] Link VIP belum diatur! Silakan isi di Menu Utama."; sleep 2; continue; fi
                VIP_LINK=$(cat "$CONFIG_FILE")
                
                echo "[*] Memulai Mesin Auto AFK..."
                PACKAGES=$(get_roblox_packages)
                if [ -z "$PACKAGES" ]; then echo "[!] Tidak ada aplikasi Roblox yang terdeteksi!"; sleep 2; continue; fi

                echo "[*] TAHAP 1: Menghentikan semua instance..."
                for pkg in $PACKAGES; do su -c "am force-stop $pkg"; done
                sleep 2

                deploy_lua_script

                echo "[*] TAHAP 2: Membuka aplikasi secara normal..."
                for pkg in $PACKAGES; do
                    su -c "monkey -p $pkg -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1"
                    sleep 3
                done

                echo "[*] TAHAP 3: Mengeksekusi Layout Grid dari GitHub..."
                execute_layout
                
                echo "    Menunggu 15 detik agar aplikasi me-reload di mode Grid..."
                sleep 15 

                echo "[*] TAHAP 4: Menembakkan Link VIP..."
                for pkg in $PACKAGES; do
                    echo " -> Injecting VIP ke $pkg..."
                    su -c "am start -a android.intent.action.VIEW -d \"$VIP_LINK\" $pkg > /dev/null 2>&1"
                    sleep 8 
                done

                echo "[*] Membawa Termux ke Background..."
                su -c "input keyevent 3"
                sleep 2

                drop_android_ram

                trap "echo -e '\n[!] Keluar dari Mode AFK...'; break" INT
                loop_count=1
                
                while true; do
                    sleep 300
                    drop_android_ram
                    ((loop_count++))
                done
                trap - INT
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
    if [ -f "$CONFIG_FILE" ]; then STATUS_LINK="[Terisi]"; fi
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
