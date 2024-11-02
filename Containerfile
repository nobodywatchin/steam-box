# Use the SteamOS container as the base
FROM lscr.io/linuxserver/steamos:latest

# Install needed packages
RUN pacman -Sy \
        paru \
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
        glibc-locales \
        --noconfirm && \
# Install additional packages
    curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh \
    sh -c 'rm -f /tmp/user_install_script.sh; if curl -S -s -L -O --output-dir /tmp/ --connect-timeout 60 https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh; then bash /tmp/user_install_script.sh; else echo "Something went wrong, please report this if it is a bug"; read; fi' \
    pacman -S \
        lutris \
        mangohud \
        lib32-mangohud \
        --noconfirm && \
        wget https://raw.githubusercontent.com/Shringe/LatencyFleX-Installer/main/install.sh -O /usr/bin/latencyflex && \
        sed -i 's@"dxvk.conf"@"/usr/share/latencyflex/dxvk.conf"@g' /usr/bin/latencyflex && \
        chmod +x /usr/bin/latencyflex && \
    pacman -S --clean --clean && \
    rm -rf /var/cache/pacman/pkg/*
        # Steam/Lutris/Wine installed separately so they use the dependencies above and don't try to install their own.

# Create build user
#RUN useradd -m --shell=/bin/bash build && usermod -L build && \
#    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
#    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install AUR packages
USER build
WORKDIR /home/build
RUN paru -S \
        aur/protontricks \
        aur/vkbasalt \
        aur/lib32-vkbasalt \
        aur/obs-vkcapture-git \
        aur/lib32-obs-vkcapture-git \
        aur/lib32-gperftools \
        aur/steamcmd \
        --noconfirm
USER root
WORKDIR /

# Cleanup
# Native march & tune. This is a gaming image and not something a user is going to compile things in with the intent to share.
# We do this last because it'll only apply to updates the user makes going forward. We don't want to optimize for the build host's environment.
RUN sed -i 's@ (Runtime)@@g' /usr/share/applications/steam.desktop && \
    sed -i 's/-march=x86-64 -mtune=generic/-march=native -mtune=native/g' /etc/makepkg.conf && \
    userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf /home/build/.cache/* && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*
