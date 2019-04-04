#!/bin/bash

#######################################################################
## Configuration
#######################################################################
mountIp="x.x.x.x"
mountDir="backup"
mountUser="fhem"
mountPass="GEHEIM"
mountSubDir="rpi/fhem"
localMountPoint="/Q/backup"

####################################################################### 
## optional
#######################################################################
backupsMax="20"
localBackupDir="/backup"
###################################
 
perl /opt/fhem/fhem.pl 7072 "setreading system_backup info backup starting now"
 
if [ ! -e "$localBackupDir" ]; then
	echo "$localBackupDir wird erstellt"
	mkdir -p "$localBackupDir"
else
	echo "$localBackupDir bereits vorhanden"
fi
 
tar --exclude=backup -cvzf "/$localBackupDir/$(date +%y%m%d_%H%M%S)_fhem_backup.tar.gz" "/opt/fhem" &>/dev/null
 
if ! ping -c 1 $mountIp
then
	echo "$mountIp nicht erreichbar, stop"
	perl /opt/fhem/fhem.pl 7072 "set system_backup error"
	perl /opt/fhem/fhem.pl 7072 "setreading system_backup info $mountIp not found"
	exit
else
	echo "$mountIp erreichbar"
fi
 
localIp=$(hostname -i|sed 's/\([0-9.]*\).*/\1/')
 
if [ ! -e "$localMountPoint" ]
then
	echo "$localMountPoint wird erstellt"
	mkdir -p "$localMountPoint"
else
	echo "$localMountPoint bereits vorhanden"
fi

if [ "$(ls -A $localMountPoint)" ]
then
	echo "$localMountPoint nicht leer, kein Mounten notwendig"
else
	echo "$localMountPoint leer, Mounten starten"
	sudo mount -t cifs -o username=$mountUser,password=$mountPass //$mountIp/$mountDir $localMountPoint
fi
 
if [ "$(ls -A $localMountPoint)" ]
then
if [ ! -e "$localMountPoint/$mountSubDir/$localIp" ]
then
mkdir -p "$localMountPoint/$mountSubDir/$localIp"
else
echo "$localMountPoint/$mountSubDir/$localIp existiert bereits"
fi
find "$localBackupDir" -name '*fhem_backup.tar.gz' | while read file
do
fileSize="0"
fileSizeMB=$(du -h $file)
fileSizeMB=${fileSizeMB%%M*}
filename=${file##*/}
echo "$filename ($fileSizeMB MB) wird in den Backupordner verschoben"
cp "$file" "$localMountPoint/$mountSubDir/$localIp/$filename"
rm "$file"
perl /opt/fhem/fhem.pl 7072 "set system_backup off"
perl /opt/fhem/fhem.pl 7072 "setreading system_backup backup $filename"
perl /opt/fhem/fhem.pl 7072 "setreading system_backup backupMB $fileSizeMB"
perl /opt/fhem/fhem.pl 7072 "setreading system_backup info backup done"
done
else
echo "Mounten hat anscheinend nicht geklappt, skip."
exit
fi
 
#Löschen alter Backups
if [[ "$backupsMax" != "" && "$backupsMax" != "0" ]]
then
perl /opt/fhem/fhem.pl 7072 "setreading system_backup backupFilesMax $backupsMax"
backupsCurrent=`ls -A "$localMountPoint/$mountSubDir/$localIp" | grep -c "_fhem_backup.tar.gz"`
backupsDelete=$(($backupsCurrent-$backupsMax))
if [ "$backupsDelete" -gt "0" ]
then
echo "$backupsCurrent Backups vorhanden - nur $backupsMax aktuelle Backups werden vorgehalten - $backupsDelete Backups werden gelöscht"
ls -d "/$localMountPoint/$mountSubDir/$localIp/"* | grep "_fhem_backup.tar.gz" | head -$backupsDelete | xargs rm
else
echo "$backupsCurrent Backups vorhanden - bis $backupsMax aktuelle Backups werden vorgehalten"
fi
else
perl /opt/fhem/fhem.pl 7072 "setreading system_backup backupFilesMax no limit"
fi
 
backupsCurrent=`ls -A "$localMountPoint/$mountSubDir/$localIp" | grep -c "_fhem_backup.tar.gz"`
perl /opt/fhem/fhem.pl 7072 "setreading system_backup backupFiles $backupsCurrent"
 
 
echo "Mount wieder unmounten"
umount -l $localMountPoint