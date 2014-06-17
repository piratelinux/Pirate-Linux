cd
if [ ! -d .config ]
then
    export XFCE_PANEL_MIGRATE_DEFAULT=1
fi
exec startxfce4 --with-ck-launch
