Informations for installing :

curl -o ~/Downloads/uhd51-master.zip https://codeload.github.com/Flobul/uhd51/zip/master
unzip -j ~/Downloads/uhd51-master.zip -d ~/Applications/uhd51-master
chmod a+x ~/Applications/uhd51-master/uhd51.sh
~/Applications/uhd51-master/uhd51.sh information 192.168.1.30

Use echo -e "$(~/Applications/telnoptoma/uhd51.sh status)" to print all output at once
