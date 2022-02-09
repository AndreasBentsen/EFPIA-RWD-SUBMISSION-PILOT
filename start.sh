#!/usr/bin/env bash

### Colors ##
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m" GREENFILLED="${ESC}[42m"

GREYFILLED="${ESC}[100m"
EXITRED="${ESC}[91m"

### Color Functions ##
print_GREYFILLED() { printf "${GREYFILLED}%s${RESET}\n" "$1"; }
print_EXITRED() { printf "${EXITRED}%s${RESET}\n" "$1"; }
bye() { echo "Closing..."; exit 0; }
fail() { echo "You have selected a wrong option..." exit 1; }

### SUB-MENUS
# 1
submenu_1() {
    echo -ne "
$(print_GREYFILLED 'Download & ETL')
1 Build & Run Container
2 Export Container to .tar.gz
$(print_EXITRED '0 Return to Main Menu')
Choose an option:  "
    read -r ans
    case $ans in
    1)
        sub-submenu
        submenu
        ;;
    2)
        mainmenu
        ;;
    0)
        mainmenu
        ;;
    *)
        fail
        ;;
    esac
}

### MENU
mainmenu() {
    echo -ne "
$(print_GREYFILLED 'EFPIA RWE SUBMISSION PILOT')
1 Download & ETL
2 PostgreSQL
3 Upload to PostgreSQL
4 Data Quality Dashboard
5 Analysis
$(print_EXITRED '0 Exit')
Choose an option:  "
    read -r ans
    case $ans in
    1)
        submenu_1
        ;;
    2)
        submenu_2
        ;;
    3)
        submenu_3
        ;;
    4)
        submenu_4
        ;;
    5)
        submenu_5
        ;;
    0)
        bye
        ;;
    *)
        fail
        ;;
    esac
}

mainmenu