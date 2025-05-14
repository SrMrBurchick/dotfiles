# Install packages
echo "Installing packages"
sudo pacman -S hyprland lightdm kitty fish waybar wofi firefox swww secrets nautilus hyprlock pavucontrol wl-clipboard cliphist pamixer

# Terminal tools
echo "Install starship"
curl -sS https://starship.rs/install.sh | sh

# Bluetooth
echo "Setup bluetooth"
sudo pacman -S blueman bluez-utils

sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Fonts
echo "Setup fonts"
sudo pacman -S ttf-3270-nerd ttf-hack ttf-font-awesome ttf-jetbrains-mono ttf-jetbrains-mono-nerd

# Neovim
echo "Neovin setup"
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# YAY
echo "YaY setup"
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# Link configs
echo "Link configs"
# ln -s "$PWD/hypr" "$HOME/.config/hypr"
# ln -s "$PWD/waybar" "$HOME/.config/waybar"
# ln -s "$PWD/fish" "$HOME/.config/fish"
# ln -s "$PWD/wofi" "$HOME/.config/wofi"
# ln -s "$PWD/kitty" "$HOME/.config/kitty"
# ln -s "$PWD/nvim" "$HOME/.config/nvim


# Dark themes
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
