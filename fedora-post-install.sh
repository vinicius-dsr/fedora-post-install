#!/bin/bash

# Script de pós-instalação para Fedora 40
# Certifique-se de executá-lo com privilégios de superusuário: sudo ./fedora-post-install.sh

echo "Iniciando script de pós-instalação para Fedora 40."

# Passo 1: Configuração do DNF para downloads mais rápidos
echo "Configurando o DNF para downloads mais rápidos."
if grep -q "^max_parallel_downloads" /etc/dnf/dnf.conf; then
    echo "Parâmetro max_parallel_downloads já configurado."
else
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
    echo "max_parallel_downloads configurado para 10."
fi

read -p "Deseja ativar os espelhos mais rápidos e o deltarpm? (s/n): " use_mirrors
if [[ "$use_mirrors" == "s" ]]; then
    echo "fastestmirror=true" | sudo tee -a /etc/dnf/dnf.conf
    echo "deltarpm=true" | sudo tee -a /etc/dnf/dnf.conf
    echo "Configuração de espelhos rápidos e deltarpm ativada."
fi

# Passo 2: Atualizar o sistema
echo "Atualizando o sistema."
sudo dnf upgrade -y

# Passo 3: Adicionar Repositórios RPM Fusion
echo "Adicionando repositórios RPM Fusion."
sudo dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-40.noarch.rpm
sudo dnf install -y http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-40.noarch.rpm

# Passo 4: Instalar Codecs Multimídia
echo "Instalando codecs multimídia."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video

# Passo 5: Instalar VLC
echo "Instalando VLC."
sudo dnf install -y vlc

# Passo 6: Alterar o nome do host
read -p "Deseja alterar o nome do host? (s/n): " change_hostname
if [[ "$change_hostname" == "s" ]]; then
    read -p "Digite o novo nome do host: " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo "Nome do host alterado para $new_hostname."
fi

# Passo 7: Gnome Over Amplification
read -p "Deseja permitir aumento de volume acima de 100% no GNOME? (s/n): " over_amp
if [[ "$over_amp" == "s" ]]; then
    gsettings set org.gnome.desktop.sound allow-volume-above-100-percent 'true'
    echo "Amplificação de volume acima de 100% habilitada."
fi

echo "Script de pós-instalação concluído com sucesso!"