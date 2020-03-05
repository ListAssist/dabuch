# Allgemein
Um die Applikation auf Mobilen Geräten zu installieren, müsste eigentlich die erstellte .apk installiert werden. Da Benutzer die App nicht von Websiten, sondern von einer zentralen Quelle runterladen, muss die Applikation auf den jeweiligen App Store hochgeladen werden.

Ich habe mich entschieden unsere Applikation nur auf dem Android Play Store zu veröffentlichen, da Apple eine Developer Gebühr von 99€ pro Jahr verlangt und dies meines Erachtens viel zu viel ist.

# PlayStore
Um eine Applikation auf PlayStore zu veröffentlichen, muss zuerst ein Google Play Developer Account für 25$ erworben werden.
Dieser Betrag wird nur einmalig gezahlt. Danach kann man Apps auf dem PlayStore veröffentlichen.

Am PlayStore müssen viele Informationen angegeben. Diese reichen von "Was macht die App?" bis zu "Warum speichert die App XY?".

# Deployment
Bevor in den PlayStore hochgeladen werden kann, muss die App erstmal gebuildet werden. 

## Keystore
Um Apps sicher zu publizieren braucht man einen Keystore. \cite{keystore} Dieser ist verantwortlich für das Signieren der Applikation, um diese dann in den PlayStore hochzuladen.

