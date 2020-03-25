# Allgemein
Um die Applikation auf Mobilen Geräten zu installieren, müsste eigentlich die erstellte .apk installiert werden. Da Benutzer die App nicht von Websiten, sondern von einer zentralen Quelle runterladen, muss die Applikation auf den jeweiligen App Store hochgeladen werden.

Ich habe mich entschieden unsere Applikation nur auf dem Android Play Store zu veröffentlichen, da Apple eine Developer Gebühr von 99€ pro Jahr verlangt und dies meines Erachtens viel zu viel ist.

# PlayStore
Um eine Applikation auf PlayStore zu veröffentlichen, muss zuerst ein Google Play Developer Account für 25$ erworben werden.
Dieser Betrag wird nur einmalig gezahlt. Danach kann man Apps auf dem PlayStore veröffentlichen.

Am PlayStore müssen viele Informationen angegeben. Diese reichen von "Was macht die App?" bis zu "Warum speichert die App XY?". Weiters wird gefragt, für welche Zielgruppe die App gedacht ist. Natürlich muss auch bestätigt werden, dass die App der DSGVO Richtlinien entspricht.

# Deployment
Bevor in den PlayStore hochgeladen werden kann, muss die App zuerst gebuildet werden.

## Keystore
Um Apps sicher zu publizieren braucht man einen Keystore. \cite{keystore} Dieser ist verantwortlich für das Signieren der Applikation, um diese dann in den PlayStore hochzuladen. Wichtig ist, dass wenn eine App mit einem Keystore gepublished wurde, müssen updates mit dem selben Keystore wieder signiert werden.

 Dies soll verhindern, dass wenn der Google Account gehacket wurde, neue Updates mit Schadcode für die Apps des Google Accounts veröffentlicht werden. Heißt wenn sich jemand Zugriff auf meinen Google Account verschafft, kann er keine Versionen meiner App veröffentlichen

## Build Version
Um die App zu builden muss nur `flutter build run` in der command line eingegeben werden. Um aber die App für Android speziell zu builden, wird 

`flutter build appbundle --target-platform android-arm,android-arm64,android-x64` 

verwendet. Dies brinngt Optimierungen mit sich, welche zum Beispiel die App Größe beinflussen. 

\begin{longtable}[]{@{}ll@{}}
\toprule
Build Methode & Größe\tabularnewline
\midrule
\endhead
Standard & 27.6 Mb\tabularnewline
Für Android & 11.8 Mb\tabularnewline
\bottomrule
\caption{Vergleich zwischen nicht optimiertem Build und Android Build}
\end{longtable}

## Veröffentlichung
Nachdem ein App Bundle erstellt wurde, kann, nachdem ein Google Developer Account erstellt wurde, die App auf dem PlayStore hochgeladen werden. Es sind mehrere "Tracks" verfügbar.

* Alpha Track
* Beta Track
* Produktions Track

wobei der Alpha und Beta Track nur für bestimmte Tester, welche man selbst angeben muss, verfügbar ist. Diese Pre-release Tracks werden verwendet, um größere Fehler in der Applikation vorzubeugen, da Google mit jedem Alpha bzw. Beta Release, einen Pre-Release Bericht miterstellt. In diesem wird dann beschrieben, wie die App auf unterschiedlichen Geräte mit unterschiedlichen Android Versionen performt.


