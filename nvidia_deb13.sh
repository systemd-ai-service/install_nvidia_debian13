cat << 'EOF' > nvidia_deb13.sh
#!/bin/bash

echo "=== 1. Habilitando repositorios y actualizando ==="
sudo sed -i '/^deb.*trixie / { /contrib/! s/$/ contrib non-free non-free-firmware/ }' /etc/apt/sources.list
sudo apt update

echo "=== 2. Instalando cabeceras del kernel ==="
sudo apt install -y linux-headers-amd64

echo "=== 3. Instalando driver de NVIDIA ==="
sudo apt install -y nvidia-driver nvidia-settings dkms nvidia-detect

echo "=== 4. Configurando Blacklist para Nouveau ==="
sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveau.conf << "EOF_BLACKLIST"
blacklist nouveau
options nouveau modeset=0
EOF_BLACKLIST'

echo "=== 5. Configurando GRUB (Modesetting) ==="
# Añade nvidia-drm.modeset=1 automáticamente si no está presente
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /' /etc/default/grub

echo "=== 6. Actualizando initramfs y GRUB ==="
sudo update-initramfs -u
sudo update-grub

echo "=== 7. Proceso finalizado ==="
read -p "¿Deseas reiniciar el sistema ahora para aplicar los cambios? (s/n): " opcion
if [ "$opcion" = "s" ] || [ "$opcion" = "S" ]; then
    sudo reboot
else
    echo "Recuerda reiniciar manualmente y ejecutar 'nvidia-smi' después para verificar."
fi
EOF
