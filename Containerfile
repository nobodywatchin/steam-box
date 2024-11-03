# Use the SteamOS container as the base
FROM lscr.io/linuxserver/steamos:latest

# Install core packages without paru
RUN pacman -Sy --noconfirm \
        lib32-vulkan-radeon \
        libva-mesa-driver \
        intel-media-driver \
        vulkan-mesa-layers \
        lib32-vulkan-mesa-layers \
        lib32-libnm \
        openal \
        pipewire \
        pipewire-pulse \
        pipewire-alsa \
        pipewire-jack \
        wireplumber \
        lib32-pipewire \
        lib32-pipewire-jack \
        lib32-libpulse \
        lib32-openal \
        xdg-desktop-portal-kde \
        vim \
        nano \
        hyfetch \
        fish \
        yad \
        xdg-user-dirs \
        xdotool \
        xorg-xwininfo \
        wmctrl \
        wxwidgets-gtk3 \
        rocm-opencl-runtime \
        rocm-hip-runtime \
        libbsd \
        noto-fonts-cjk \
        glibc-locales && \
    pacman -S --noconfirm \
        lutris \
        mangohud \
        lib32-mangohud

# Install paru manually
RUN pacman -Sy --noconfirm git base-devel && \
    git clone https://aur.archlinux.org/paru.git /tmp/paru && \
    cd /tmp/paru && \
    makepkg -si --noconfirm && \
    rm -rf /tmp/paru

# Install EmuDeck
RUN curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash

# Install Decky Launcher
RUN curl -S -s -L -O --output-dir /tmp/ --connect-timeout 60 https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh && \
    bash /tmp/user_install_script.sh || echo "Something went wrong, please report this if it is a bug"

# Install LatencyFlex
RUN wget https://raw.githubusercontent.com/Shringe/LatencyFleX-Installer/main/install.sh -O /usr/bin/latencyflex && \
    sed -i 's@"dxvk.conf"@"/usr/share/latencyflex/dxvk.conf"@g' /usr/bin/latencyflex && \
    chmod +x /usr/bin/latencyflex

# Install AUR packages as build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER build
WORKDIR /home/build
RUN paru -S --noconfirm \
        aur/protontricks \
        aur/vkbasalt \
        aur/lib32-vkbasalt \
        aur/obs-vkcapture-git \
        aur/lib32-obs-vkcapture-git \
        aur/lib32-gperftools \
        aur/steamcmd

# Switch back to root and clean up
USER root
WORKDIR /
RUN userdel -r build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf /home/build && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /tmp/*
