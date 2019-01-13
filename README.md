# dkDockerFHEM
Docker Environment for FHEM based on Hypriot

Weitere Infos findest Du hier:
https://blog.krannich.de/fhem-auf-rpi-mit-docker-und-hypriot/

## Docker Container
- Portainer auf Port 9000
- Adminer auf Port 8080
- Reverse-Proxy
- FHEM über Port 80 und 8088
- MariaDB
- Alexa-FHEM

## Was muss ich machen?

### FHEM
Da ich FHEM komplett lokal ausgelagert habe, musst Du noch Deinen FHEM-Ordner nach *fhem/core* kopieren.
Bitte darauf achten, dass die Datei *start-fhem.sh* noch erhalten bleibt.

### Alexa-FHEM
Wenn Du Alexa FHEM nutzen möchtest, musst Du noch Dein *Zertifikat (cert.pem)* und Deinen *Public-Key (key.pem)* im Ordner *alexa/config* hinterlegen.
Dort musst Du auch die Konfiguration *config.json* anpassen.
Weitere Infos zu Alexa-FHEM findest Du hier:
https://blog.krannich.de/fhem-hoert-jetzt-auf-alexa-amazon-echo/

### MariaDB
Es wird auch ein Container mit MariaDB gestartet. Wenn Du diesen nicht benötigst, kannst Du ihn in der docker-compose.yml auskommentieren oder löschen.
