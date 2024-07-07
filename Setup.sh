# Install packages
echo "Installing packages"
sudo pacman -S hyprland lightdm kitty fish waybar wofi firefox swww

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
sudo pacman -S ttf-3270-nerd ttf-hack ttf-font-awesome ttf-jetbrains-mono 

# Link configs
echo "Link configs"
ln -s "$PWD/hypr" "$HOME/.config/hypr"
ln -s "$PWD/waybar" "$HOME/.config/waybar"
ln -s "$PWD/fish" "$HOME/.config/fish"
ln -s "$PWD/wofi" "$HOME/.config/wofi"
ln -s "$PWD/kitty" "$HOME/.config/kitty"
