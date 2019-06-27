rcprofile="$HOME/.$(basename $SHELL)rc"
echo -n "Adding variables to $rcprofile ... "
if [ -z "$(grep REDCAN $rcprofile)" ]; then
    echo -e "\n\n#>>>>> REDCAN configuration <<<<<" >> $rcprofile
    if [ "$(echo $HOME | grep csh)" ]; then
        echo "setenv REDCANDIR /location/CANARICAM/PIPELINE" >> $rcprofile
    else
        echo "export REDCANDIR=$(pwd)/CANARICAM/PIPELINE" >> $rcprofile
    fi
    echo "alias redcan='csh \$REDCANDIR/CSHELL/RedCan.csh'" >> $rcprofile
    echo -e "#>>>>> REDCAN configuration <<<<<\n\n" >> $rcprofile
fi
echo "OK"
source $rcprofile
