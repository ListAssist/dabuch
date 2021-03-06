# Allgemein
Um die Applikation auf mobilen Geräten zu installieren, müsste eigentlich nur die erstellte .apk installiert werden. Da Benutzer die App nicht von Webseiten, sondern von einer zentralen Quelle runterladen, muss die Applikation auf den jeweiligen App Store hochgeladen werden.

Entschieden wurde, die Applikation nur auf dem Android Play Store zu veröffentlichen, da Apple eine Developer Gebühr von 99€ pro Jahr verlangt und dies meiner Meinung nach zu viel ist.

# PlayStore
Um eine Applikation auf dem Google PlayStore zu veröffentlichen, muss zuerst ein Google Play Developer Account für 25$ erworben werden.
Dieser Betrag wird nur einmalig gezahlt. Danach kann man Apps auf dem PlayStore veröffentlichen.

Bei der Registrierung der Applikation müssen viele Informationen angegeben werden. Diese reichen von "Was macht die App?" bis zu "Warum speichert die App XYZ?". Weiters wird gefragt, für welche Zielgruppe die App gedacht ist. Natürlich muss auch bestätigt werden, dass die App den DSGVO Richtlinien entspricht.

# Deployment
Bevor in den PlayStore hochgeladen werden kann, muss die App zuerst kompiliert werden.

## Keystore
Um Apps sicher zu publizieren braucht man einen Keystore. Dieser ist verantwortlich für das Signieren der Applikation, um diese dann in den PlayStore hochzuladen. Wichtig ist, dass wenn eine App mit einem bestimmten Keystore veröffentlicht wurde, spätere Updates dann ebenfalls mit dem selben Keystore signiert werden müssen.

Dies soll verhindern, dass wenn der Google Account gehackt wurde, neue Updates mit Schadcode hochgeladen werden. Heißt wenn sich jemand Zugriff auf meinen Google Account verschafft, kann er keine neue Versionen meiner App veröffentlichen.

## Build Version
Um die App zu builden muss nur `flutter build run` in der Command Line eingegeben werden. Um aber die Applikation für Android speziell zu builden, wird 

`flutter build appbundle --target-platform android-arm,android-arm64,android-x64` 

verwendet. Dies bringt Optimierungen mit sich, welche zum Beispiel die Größe der App beinflussen. 

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
Nachdem ein App Bundle erstellt wurde, kann die App auf dem PlayStore hochgeladen werden. Es sind mehrere "Tracks" verfügbar.

* Alpha Track
* Beta Track
* Produktions Track

wobei der Alpha und Beta Track nur für bestimmte Tester, welche man selbst angeben muss, verfügbar ist. Diese Pre-release Tracks werden verwendet, um größere Fehler in der Applikation zu vermeiden, um Nutzern keine kaputte Applikation zu liefern. Hier ist es handlich, dass Google mit jedem Alpha bzw. Beta Release einen Pre-Release Bericht miterstellt. In diesem wird dann beschrieben, wie die App auf unterschiedlichen Geräten mit unterschiedlichen Android Versionen performt.


