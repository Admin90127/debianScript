#!/bin/bash

# Функция для запроса да/нет
ask_yes_no() {
    while true; do
        read -p "$1 (да/нет): " yn
        case $yn in
            [Дд]* ) return 0;;
            [Нн]* ) return 1;;
            * ) echo "Пожалуйста, ответьте да или нет.";;
        esac
    done
}

# 1. Обновление системы
if ask_yes_no "1. Хотите обновить систему?"; then
    sudo apt update && sudo apt upgrade -y
fi

# 2. Установка основных инструментов разработки
if ask_yes_no "2. Установить основные инструменты разработки (build-essential)?"; then
    sudo apt install build-essential -y
fi

# 3. Установка SSH сервера
if ask_yes_no "3. Установить SSH сервер?"; then
    sudo apt install openssh-server -y
    sudo systemctl enable ssh
    sudo systemctl start ssh
fi

# 4. Настройка файрвола
if ask_yes_no "4. Настроить файрвол (ufw)?"; then
    sudo apt install ufw -y
    sudo ufw enable
    sudo ufw allow ssh
fi

# 5. Установка и настройка веб-сервера
if ask_yes_no "5. Установить веб-сервер (Apache или Nginx)?"; then
    echo "1) Apache"
    echo "2) Nginx"
    read -p "Выберите вариант (1 или 2): " web_server
    case $web_server in
        1) 
            sudo apt install apache2 -y
            sudo systemctl enable apache2
            sudo systemctl start apache2
            ;;
        2) 
            sudo apt install nginx -y
            sudo systemctl enable nginx
            sudo systemctl start nginx
            ;;
        *) echo "Неверный выбор. Пропускаем установку веб-сервера.";;
    esac
fi

# 6. Установка и настройка СУБД
if ask_yes_no "6. Установить СУБД (MySQL или PostgreSQL)?"; then
    echo "1) MySQL"
    echo "2) PostgreSQL"
    read -p "Выберите вариант (1 или 2): " db_choice
    case $db_choice in
        1) 
            sudo apt install mysql-server -y
            sudo systemctl enable mysql
            sudo systemctl start mysql
            sudo mysql_secure_installation
            ;;
        2) 
            sudo apt install postgresql postgresql-contrib -y
            sudo systemctl enable postgresql
            sudo systemctl start postgresql
            ;;
        *) echo "Неверный выбор. Пропускаем установку СУБД.";;
    esac
fi

# 7. Установка Python и pip
if ask_yes_no "7. Установить Python и pip?"; then
    sudo apt install python3 python3-pip -y
fi

# 8. Установка Git
if ask_yes_no "8. Установить Git?"; then
    sudo apt install git -y
    read -p "Введите ваше имя для настройки Git: " git_name
    read -p "Введите ваш email для настройки Git: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
fi

# 9. Настройка часового пояса
if ask_yes_no "9. Настроить часовой пояс?"; then
    sudo dpkg-reconfigure tzdata
fi

# 10. Создание нового пользователя
if ask_yes_no "10. Создать нового пользователя?"; then
    read -p "Введите имя нового пользователя: " new_user
    sudo adduser $new_user
    sudo usermod -aG sudo $new_user
fi

# 11. Установка и настройка файлового менеджера MC
if ask_yes_no "11. Установить файловый менеджер Midnight Commander?"; then
    sudo apt install mc -y
fi

# 12. Установка текстового редактора
if ask_yes_no "12. Установить текстовый редактор (Vim или Nano)?"; then
    echo "1) Vim"
    echo "2) Nano"
    read -p "Выберите вариант (1 или 2): " editor_choice
    case $editor_choice in
        1) sudo apt install vim -y;;
        2) sudo apt install nano -y;;
        *) echo "Неверный выбор. Пропускаем установку редактора.";;
    esac
fi

# 13. Настройка автоматических обновлений
if ask_yes_no "13. Настроить автоматические обновления безопасности?"; then
    sudo apt install unattended-upgrades -y
    sudo dpkg-reconfigure -plow unattended-upgrades
fi

# 14. Установка антивируса ClamAV
if ask_yes_no "14. Установить антивирус ClamAV?"; then
    sudo apt install clamav clamav-daemon -y
    sudo systemctl enable clamav-daemon
    sudo systemctl start clamav-daemon
fi

# 15. Настройка резервного копирования
if ask_yes_no "15. Настроить простое резервное копирование (rsync)?"; then
    sudo apt install rsync -y
    read -p "Введите путь для резервных копий: " backup_path
    echo "0 1 * * * rsync -av /home /etc $backup_path" | sudo tee -a /etc/crontab
fi

# 16. Установка системы мониторинга
if ask_yes_no "16. Установить систему мониторинга (Glances)?"; then
    sudo apt install glances -y
fi

# 17. Настройка swap-файла
if ask_yes_no "17. Настроить swap-файл?"; then
    read -p "Введите размер swap-файла в ГБ: " swap_size
    sudo fallocate -l ${swap_size}G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# 18. Установка и настройка fail2ban
if ask_yes_no "18. Установить и настроить fail2ban для защиты от брутфорс-атак?"; then
    sudo apt install fail2ban -y
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
fi

# 19. Настройка IPv6
if ask_yes_no "19. Отключить IPv6?"; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

# 20. Установка и настройка Docker
if ask_yes_no "20. Установить Docker?"; then
    sudo apt install docker.io -y
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
fi

echo "Первоначальная настройка завершена!"
echo "Рекомендуется перезагрузить систему для применения всех изменений."
if ask_yes_no "Хотите перезагрузить систему сейчас?"; then
    sudo reboot
fi
