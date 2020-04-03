# Grundidee des Animationsvideos

Die Idee ein Animationsvideo zu machen wurde deshalb getroffen, um die App sowohl zu präsentieren, als auch die Funktionalität zu veranschaulichen. Es soll also ein Erklärvideo sein.

# Story

Zu den Hauptkomponenten eines Erklärvideos gehört die Story. Sie muss schlüssig und für jeden verständlich vermittelt werden. Es muss genau überlegt werden, was ins Video passt und was eher überflüssig ist. Das Video soll zwar nicht zu lang sein, allerdings sollen alle wichtigen Informationen erwähnt werden, damit der Kunde nach dem Anschauen des Videos weiß, wie die App funktioniert. Daher habe ich mir überlegt am Anfang ein kleines Intro einzufügen. Anschließend werden die einzelnen Seiten bzw. Funktionen der App dargestellt. Zum Schluss erfolgt noch ein kurzes Outro, um das Video formgemäß zu beenden.

# Workflow

## Vorarbeit

Im Unterricht haben wir das Programm After Effects relativ selten verwendet. Aus diesem Grund musste zuerst eine Recherche durchgeführt werden. In dieser habe ich mich intensiv mit der Funktionsweise des Programms beschäftigt. Um alle Aspekte, die notwendig zur Erstellung des Animationsvideos waren, abzudecken, habe ich viele verschiedene Tutorials angeschaut. 

## Intro

Nachdem ich die notwendigen Informationen hatte, habe ich mit dem Intro begonnen. Die Idee war es, das Logo, den Namen und den Slogan der Diplomarbeit zu präsentieren. Um das Ganze anschaulicher zu machen, wurden verschiedene Animationen angewendet. Anfangs rotiert das Logo in die Bildfläche und bewegt sich darauf auf die Seite. Danach erscheint der Name und der Slogan neben dem Logo. Um die Animationen besser darzustellen, stellt das Programm die Funktion "Ease Ease" zur Verfügung. Mithilfe dieses Effekts wirkt das Video viel flüssiger und natürlicher. Die Bewegungen sind, im Gegensatz zu einer linearen Bewegungen, für die Zuschauer viel angenehmer zu betrachten. Nach wenigen Sekunden verschwinden die einzelnen Komponenten von der Bildfläche und das Video fließt zum Hauptteil über.

Am Anfang bemerkte ich auch, dass das Timing eine große Rolle spielt. Die einzelnen Grafiken müssen aufeinander abgestimmt reagieren. Das Video muss so getimed werden, dass der Name und der Solgan erst in Erscheinung treten, nachdem das Logo sich vollständig zur Seite bewegt hat. Beim Verschwinden gilt genau das Selbe. Erst nachdem der Name und der Slogan nicht mehr zu sehen sind, soll das Logo wieder aus dem Bild rotieren.

Weiters ist noch zu erwähnen, dass die einzelnen Komponenten des Videos in Unterkompositionen unterteilt werden können. Somit kann jede Komponente einzeln bearbeitet werden, damit die anderen Inhalte nicht beeinflusst werden.

Die verschiedenen Animationen können auf jede Komposition angewendet werden. Die wichtigsten Funktionen für dieses Intro sind die Rotation, die Skalierung und die Drehung. Um ein Bild oder ein Text beispielsweise zu drehen, müssen Keyframes gesetzt werden. Jeder Keyframe beschreibt eine Art "Zustand". Bei der ersten Sekunde kann die Skalierung auf 0 % gesetzt werden und bei der zweiten Sekunde dann auf 100 %. Dies bewirkt, dass das Logo, aber auch die Schrift innerhalb von einer Sekunde, immer größer werdend, im Bild erscheinen. After Effects kümmert sich in der Zeit zwischen den Keyframes darum, die Transformation von einem Zustand, in den anderen zu machen.

\begin{figure}[H]
\centering
\includegraphics[width=0.4\textwidth, keepaspectratio]{images/doja/Logo_Schrift.png}
\caption{Logo und Schrift nach dem Abschluss der Animation}
\label{listAssistLogoUndSchrift}
\end{figure}

## Hauptteil

Im Hauptteil geht es ausschließlich darum, die vollständige App und ihre Funktionalität zu zeigen. Es müssen also alle Seiten, vom Screen beim Einloggen, bis zum Verlassen der App, gezeigt und erklärt werden. Einige Ansichten, wie zum Beispiel die Liste der Einkaufslisten, sind selbsterklärend. Allerdings beinhalten viele Seiten noch zusätzliche Icons, deren Funktionen näher beschrieben werden müssen. Zum Beginn des Hauptteils wird ein Smartphone angezeigt, auf dem die ListAssist-App geöffnet dargestellt wird. Empfangen wird man mit der Authentifizierungs-Ansicht, wo der User aufgefordert wird, sich entweder neu zu registrieren oder, bei einem bereits vorhandenem Account, sich anzumelden.

Nachdem sich der User erfolgreich angemeldet oder registriert hat, startet die App mit der Übersicht der Liste der Einkaufslisten. Für jede einzelne Seite, die im Animationsvideo zu sehen ist, wurde das Design, welches im Programm Adobe XD gestaltet wurde, exportiert und in After Effects als neue einzelne Komposition eingefügt. Bis auf die ersten zwei Ansichten, ist die Reihenfolge, in der die Seiten nach und nach präsentiert werden, in keiner bestimmten Form gewählt. Es geht bei dem Hauptteil nur um das veranschaulichen der App. Daher ist es relativ egal, in welche Ansicht der User zuerst wechselt. 

Um einen Mausklick darzustellen, nutze ich drei Keyframes, bei denen die Skalierung unterschiedlich ist. Gewählt wurde ein Kreis, welcher beim Klicken kurz wellenförmig und immer größer werdend erscheint und anschließend immer kleiner wird, bis er nicht mehr sichtbar ist. Der erste und letzte Keyframe hat eine Skalierung von 0 %. Der Keyframe in der Mitte besitzt eine Skalierung von 100 %. Somit kann das Erscheinen und Verschwinden, in Kombination mit der "Ease Ease" Funktion, des Kreises sehr flüssig dargestellt werden. Wie bei einem echten Mausklick erfolgt darauf eine gewisse Reaktion der Seite bzw. der App. Daher muss sobald der Kreis verschwindet die Ansicht gewechselt werden.

\needspace{15cm}
\begin{figure}[H]
\centering
\includegraphics[width=0.5\textwidth, keepaspectratio]{images/doja/Kreis2.png}
\caption{Animation des Kreises}
\label{animationKreis}
\end{figure}

Im Hauptteil war wieder das Timing wichtig. Sobald eine Ansicht gewechselt wurde, musste die Länge der Sichtbarkeit der zwei Ansichten angepasst werden. Wenn die Seite verschwinden soll, muss die Dauer verkürzt werden und die neue Seite, die als nächstes erscheint, beginnt sobald die vorherige nicht mehr zu sehen ist. Daher ist das Einsetzen des animierten Mausklicks und der Ansichten-Wechsel eine Präzisionsarbeit. 

Weiters wurden in vielen verschiedenen Ansichten auch Listen oder Produkte hinzugefügt, durchgestrichen oder abgehackt. Der Vorgang bleibt immer der Selbe. Auf eine Aktion muss eine Reaktion folgen und jede dieser Aktionen und Reaktionen muss einzeln animiert werden. Daher ist der Zeitaufwand, zur Erstellung eines Erklärvideos, sehr hoch.

## Outro 

Nachdem die App vollständig erklärt und präsentiert wird, folgt zum Schluss des Videos noch ein Outro. Hierbei wird den Zuschauern geraten die Diplomarbeits-Website bzw. die Instagram-Seite der Diplomarbeit ListAssist zu besuchen. Genau wie beim Intro erscheinen die Schriften und Bilder nicht einfach, sondern werden mit Animationen "geschmückt". Durch das Besuchen der Website und der Instagram-Seite können sich die Kunden noch weiter über die Diplomarbeit bzw. deren Teammitglieder informieren.

Die Outro-Sequenz ist wichtig, um das Produkt zu vermarkten. Heutzutage ist es üblich sein Video mit einer Aufforderung zu beenden. Daher ist es für mich wichtig die Kunden zu informieren, dass wir auch auf Social-Media vertreten sind und das wir eine Diplomarbeits-Website besitzen. Die Umsetzung des Outros war die selbe, wie beim Intro.

# Nachbearbeitung

## Ton 

Natürlich kann man ein Produkt sehr gut erklären, wenn eine Stimme im Hintergrund den Ablauf schildert. Daher muss man sich, bevor man mit dem Video startet, einen Text überlegen, welcher während des Videos gesprochen wird. Nachdem der Text aufgenommen und nachbearbeitet wird, fügt man die Audio-Datei zu dem Projekt in After Effects hinzu. Hierbei ist es wichtig, dass das Video und das Gesprochene synchron ablaufen. Es ist jedoch leichter die Animation an die Audio-Datei anzupassen, als umgekehrt. Je nachdem wie schnell ein Satz ausgesprochen wurde, kann die dazugehörige Animation darauf abgestimmt werden.

## Anpassung von Unstimmigkeiten

Bevor das Video zum Rendern freigegeben wird, erfolgt üblicherweise eine Kontrolle. Hierbei geht man jede Szene noch einmal durch, um zu schauen, ob sich irgendwelche Fehler eingeschlichen haben. Es ist mir öfters passiert, dass die Übergänge nicht sauber waren. Beispielsweise hat der Wechsel zwischen zwei Ansichten einige Sekunden gedauert. Diese Fehler müssen in der sogenannten "Post-Production" korrigiert werden. Natürlich kann das Video auch davor gerendert werden, um einen Eindruck vom Endprodukt zu bekommen.

## Rendern

Zum Abschluss des Animationsvideos muss dieses gerendert werden, um aus einer After-Effects-Datei eine Video-Datei zu machen. Der Vorgang ist relativ simpel. Die gewünschte Komposition wird ausgewählt und anschließend zur Renderliste hinzugefügt. Darauf werden die notwendigen Einstellungen getroffen. Bei diesem Schritt habe ich mehrere unterschiedliche Einstellungen ausprobiert, um das beste Ergebnis zu finden. Bei den Rendereinstellungen wird als Ausgabemodul der Punkt "Verlustfrei" ausgewählt, um die beste Qualität zu liefern. Nachdem alle Einstellungen getroffen wurden, muss noch ein Speicherort gewählt werden. Die Renderdauer variiert, weil natürlich nicht jedes Video gleich lang ist. Mit dem Abschließen des Renders ist das Video fertig und kann präsentiert werden.
