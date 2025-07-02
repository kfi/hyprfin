#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

enable_copr() {
    repo="$1"
    repo_with_dash="${repo/\//-}"
    wget "https://copr.fedorainfracloud.org/coprs/${repo}/repo/fedora-${RELEASE}/${repo_with_dash}-fedora-${RELEASE}.repo" \
        -O "/etc/yum.repos.d/_copr_${repo_with_dash}.repo"
}

### Enable COPRs
# enable_copr solopasha/hyprland
# enable_copr erikreider/SwayNotificationCenter
# enable_copr pgdev/ghostty
# enable_copr wezfurlong/wezterm-nightly

dnf5 copr -y enable solopasha/hyprland
dnf5 copr -y enable erikreider/SwayNotificationCenter
dnf5 copr -y enable pgdev/ghostty
dnf5 copr -y enable wezfurlong/wezterm-nightly
dnf5 copr -y enable tofik/nwg-shell

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# ncurses-term dependency is in conflict with ghostty so I'm getting rid of fish here
dnf5 remove -y fish

dnf5 install -y --setopt=install_weak_deps=False \
    xdg-desktop-portal-hyprland \
    hyprland \
    hyprlock \
    hypridle \
    hyprpicker \
    hyprsysteminfo \
    hyprsunset \
    hyprpaper \
    hyprcursor \
    hyprgraphics \
    hyprpolkitagent \
    hyprland-qtutils \
    hyprland-qt-support \
    hyprland-uwsm \
    uwsm \
    pyprland \
    waybar \
    wofi \
    rofi \
    swaync \
    wl-clipboard \
    grim \
    slurp \
    pngquant \
    swappy \
    cliphist \
    clipman \
    brightnessctl \
    pavucontrol \
    network-manager-applet \
    nwg-drawer \
    nwg-displays \
    nwg-look \
    wdisplays \
    pavucontrol \
    SwayNotificationCenter \
    NetworkManager-tui \
    tmux \
    kitty \
    ghostty \
    wezterm \
    blueman \
    qt5-qtwayland \
    qt6-qtwayland \
    mpv \
    mpv-mpris \
    wlogout \
    yad \
    yubikey-manager \
    wlogout \
    swww \
    firefox \
    sddm \
    sddm-themes \
    qt5-qtgraphicaleffects \
    qt5-qtquickcontrols2 \
    qt5-qtsvg \
    kwallet \
    pam-kwallet \
    thunar

### Install Google Chrome - Workaround

mv /opt{,.bak}
mkdir /opt
dnf install -y --enablerepo="google-chrome" google-chrome-stable
mv /opt/google/chrome /usr/lib/google-chrome
ln -sf /usr/lib/google-chrome/google-chrome /usr/bin/google-chrome-stable
mkdir -p usr/share/icons/hicolor/{16x16/apps,24x24/apps,32x32/apps,48x48/apps,64x64/apps,128x128/apps,256x256/apps}
for i in "16" "24" "32" "48" "64" "128" "256"; do
    ln -sf /usr/lib/google-chrome/product_logo_$i.png /usr/share/icons/hicolor/${i}x${i}/apps/google-chrome.png
done
rm -rf /etc/cron.daily
rmdir /opt/{google,}
mv /opt{.bak,}

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable solopasha/hyprland
dnf5 -y copr disable erikreider/SwayNotificationCenter
dnf5 -y copr disable pgdev/ghostty
dnf5 -y copr disable wezfurlong/wezterm-nightly

dnf clean all

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl disable gdm
systemctl enable sddm
