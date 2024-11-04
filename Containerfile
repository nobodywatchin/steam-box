# Use the SteamOS container as the base
FROM lscr.io/linuxserver/steamos:latest

# Update and install additional packages
RUN pacman -Syu --noconfirm && \
    echo "1" | pacman -S --noconfirm \
        lib32-vulkan-radeon \
        libva-mesa-driver \
        intel-media-driver && \
    echo "1" | pacman -S --noconfirm \
        vulkan-mesa-layers \
        lib32-vulkan-mesa-layers \
        lib32-libnm \
        openal && \
    pacman -S --noconfirm \
        lib32-openal && \
    pacman -S --noconfirm \
        xdg-desktop-portal-kde \
        vim \
        nano \
        hyfetch \
        fish \
        yad \
        xdg-user-dirs && \
    pacman -S --noconfirm \
        xdotool \
        xorg-xwininfo \
        wmctrl \
        wxwidgets-gtk3 \
        rocm-opencl-runtime \
        rocm-hip-runtime \
        libbsd \
        noto-fonts-cjk \
        glibc-locales

# Install additional packages that may have dependencies on the core libraries
RUN pacman -S --noconfirm \
        lutris \
        mangohud \
        lib32-mangohud

# Clean up after install
RUN pacman -Sc --noconfirm && rm -rf /var/cache/pacman/pkg/*

# Set any necessary environment variables or startup commands
CMD ["bash", "-c", "echo 'Customized SteamOS container started' && /bin/bash"]


# Install paru manually (for AUR support)
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
