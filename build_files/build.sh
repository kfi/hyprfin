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

cat <<EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

### /opt directory fix

OPTFIX_PKGS="google-chrome-stable"

echo "Creating symlinks to fix packages that install to /opt"
# Create symlink for /opt to /var/opt since it is not created in the image yet
mkdir -p "/var/opt"
ln -s "/var/opt"  "/opt"
# Create symlinks for each directory specified in recipe.yml
for OPTPKG in "${OPTFIX_PKGS[@]}"; do
    OPTPKG="${OPTPKG%\"}"
    OPTPKG="${OPTPKG#\"}"
    OPTPKG=$(printf "$OPTPKG")
    mkdir -p "/usr/lib/opt/${OPTPKG}"
    ln -s "../../usr/lib/opt/${OPTPKG}" "/var/opt/${OPTPKG}"
    echo "Created symlinks for ${OPTPKG}"
done

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
    thunar \
    google-chrome-stable

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
rm -f /etc/yum.repos.d/google-chrome.repo

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl disable gdm
systemctl enable sddm
