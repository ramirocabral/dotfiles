#! /bin/zsh

#make zsh default shell

chsh -s $(which zsh) 

#install packages from my-packages

filename='my-packages'
while read p; do 
    sudo pacman -S $p
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
    ln -s $file $HOME/.config
done

echo "Config files linked"

#create symbolic links for other files

ln -s .zshrc $HOME/.zshrc
ln -s .gitconfig $HOME/.gitconfig
ln -s .bashrc $HOME/.bashrc
ln -s .p10k.zsh $HOME/.p10k.zsh
ln -s .xprofile $HOME/.xprofile

echo "Home files linked"

echo "Done!"