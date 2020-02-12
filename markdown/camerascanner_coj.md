# Allgemein
Rechnungserkennung ist ein Problem, welches **bis heute** noch nicht perfekt gelöst ist. Das Ziel ist es
mithilfe eines Fotos einer Rechnung folgende Informationen zu extrahieren:

* Produkte und ihre Preise
* Gesamtpreis

Die Extraktion dieser Informationen ist nicht trivial, vor allem wenn man davon ausgeht, dass die Rechnung irgendwo im Bild sein kann.
Die Extraktion beinhaltet auch viele Zwischenschritte die wie folgt aussehen.

## Rechnungserkennung
Bei der Rechnungserkennung wird versucht die Rechnung vom Hintergrund des Bildes zu extrahieren.
Durch lösen des Subproblems kommen wir zum nächsten Punkt.

## Wichtige Teile erkennen
Bevor wir den Text extrahieren, müssen wir den wichtigen Teil der Rechnung finden aus welchem
der Text erkannt werden soll.

## Texterkennung
Texterkennung oder auch "Optical character recognition" genannt (OCR)

## Produkte und Preise erkennen
Matching mit Produkten

# Flutter Widget
Widget bla bla api call je nach Modi siehe unten hochladne firestore

# Camera Scanner Modi
Wie in der Problemstellung bereits erwähnt, ist das Auslesen der Rechnung
sehr schwer zu generalisieren. Das heißt eine Lösung zu finden, welche für
egal welche Art von Foto funktioniert, ist kaum realisierbar.

Aus diesem Grund wurde der Camera Scanner in drei Modi unterteilt:

* Editor
* Automatic
* Trainer (Default)

wobei der **Editor** Modus auch in Kombination mit den anderen zwei Modi verwendet werden kann.

## Editor

Dem User wird ein Crop, Zoom und Rotate Editor am Handy zur Verfügung gestellt. Um ein perfomanten und flüssigen
Editor zur Verfügung zu stellen, wurde das `image_cropper` verwendet, welche das Foto nativ
auf Android als auch auf iOS transformiert. Der Nutzer muss daraufhin
den wichtigen Teil der Rechnung selbst auswählen und bestätigen.

### Anforderungen
* Wichtiger Inhalt ausgewählt
* Text erkennbar

## Automatic
Der "Automatic" Modus ist ein sehr instabiler Modus und hat hohe Anforderungen an das Bild.

### Anforderungen
* hoher Rechnungs zu Hintergrund Kontrast
* Billa Rechnung oder Linien, welche die Produkte vom Rest der Rechnung trennen
* Rechnungsecken sind zu sehen
* Text erkennbar

## Trainer
Der Trainer Modus stellt dem User ein eine Quadliteral zur Verfügung, welcher sich bis zu bestimmten Grenzen verformen
und bewegen lässt. Weiters, können einzelne Eckpunkte oder zwei Eckpunkte gleichzeitig verschoben werden.

Da hier ein eigener Editor programmiert wurde, existiert voller Zugriff auf alle verwendeten Variablen
wie Raw Pixel Werte als auch Koordinaten uvm.!

Um einen Canvas zu erstellen wurde das ``Custom Paint`` Widget verwendet, welches den `PolygonPainter` verwendet.
Dieser ist für das ganze Rendering des Bildes als auch für das Quadliteral verantwortlich. Wichtig zu notieren ist
das dies ein convex Quadliteral ist.

### Anforderungen
* Wichtiger Inhalt ausgewählt
* Text erkennbar

Da hier nicht nur das Bild, sondern auch die Koordinaten des wichtigen Teils an den Server gesendet werden,
wäre es theoretisch möglich ein DCNN im Hintergrund zu trainieren, welches das erkennen des wichtigen Teiles perfektioniert.

# Rechnungserkennung
Um überhaupt mit der Erkennung des "wichtigen Teiles" oder überhaupt Text zu beginnen, muss erstmal die Rechnung
selbst lokalisiert werden. Um dies zu realisieren, müssen wir die Kanten des Rechnungzettels erkennen.
Hierfür stehen vier größere Ansätze zur Verfügung.

## Threshold Algorithmen
Um die Kanten der Rechnungen zu erkennen, kann man sich den Kontrast zum Hintergrund zu Nutze machen.
Es existieren viele verschiedene Threshold Algorithmen, der einfachste wäre einen bestimmten Grauwert als Grenze
zu nehmen und schauen, ob dieser überschritten

## Holistically-Nested Edge Detection
\cite{HED} Holistically-Nested Edge Detection (auch HED genannt), ist ein Deep Learning Ansatz, um
Kanten in einem Bild hervorzuheben. Das Netzwerk basiert auf einer \cite{VGGNet} VGGNet Architektur und beinhaltet auch
Residual Connections.

Der Vorteil hierbei ist, dass das Netz nicht zu sehr vom Kontrast abhängt - ein klarer Vorteil gegenüber herkömmlichen Threshold Algorithmen.

## Hough Lines
Hough space bla bla polare darstellung

# Wichtige Teile extrahieren
Dieser Algorithmus funktioniert nur für **Billa** Rechnungen, da diese eine markable Linie zwischen
den Produkten zur Verfügung stellen.


**Bild für Billa Rechnung einfügen**

Diese Linien werden dann mit der oben erklärten "_Hough Lines Methode_" versucht zu erkennen. Jedoch werden auch viele andere
Linien, wie z.B. die Kanten der Rechnung, miterkannt. Um die zwei richtigen Linien zu finden, wird davon ausgegangen, dass
die Linie mit dem kleinsten Y-Achsen Wert, die obere Rechnungskante ist.

# Texterkennung
Zuletzt



\abb{King Bild}
