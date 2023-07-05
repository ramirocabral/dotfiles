#! /bin/zsh

#make zsh default shell

chsh -s $(which zsh) 

#install packages from my-packages

filename='packages'
while read p; do 
    sudo pacman -S $p --noconfirm
    echo "$p"
done < "$filename"

pip install psutils
sudo systemctl enable lightdm


echo "Packages installed"

#create symbolic links for each .config file

echo Start
for file in .config/*
do
	echo $file
	ln -s $PWD/$file $HOME/$file
done

echo "Config files linked"

#create symbolic links for other files

ln -s $PWD/.zshrc $HOME/.zshrc
ln -s $PWD/.gitconfig $HOME/.gitconfig
ln -s $PWD/.bashrc $HOME/.bashrc
ln -s $PWD/.p10k.zsh $HOME/.p10k.zsh
ln -s $PWD/.xprofile $HOME/.xprofile


echo "Home files linked"



echo "Moving fonts"

sudo mv ./fonts.* /usr/local/share/fonts

#installing paru

cd $HOME
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si


#installing aur packages

cd $HOME/dotfiles

aur_filename="aur_packages"
while read p; do
    yay -S --noconfirm $p
    echo $p
done < "$aur_filename"
    

##addd picom config

echo "Done!"
