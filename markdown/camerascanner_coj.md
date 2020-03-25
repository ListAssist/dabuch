# Allgemein
Rechnungserkennung ist ein Problem, welches **bis heute** noch nicht perfekt gelöst ist. Das Ziel ist es mithilfe eines Fotos einer Rechnung folgende Informationen zu extrahieren:

* Produkte und ihre Preise
* Gesamtpreis

Die Extraktion dieser Informationen ist nicht trivial, vor allem, wenn man davon ausgeht, dass die Rechnung sich überall im Bild befinden kann.
Die Extraktion beinhaltet auch viele Zwischenschritte die wie folgt aussehen.

## Rechnungserkennung
Bei der Rechnungserkennung wird versucht, die Rechnung vom Hintergrund des Bildes zu extrahieren. Durch lösen dieses Problems, kommen wir zum nächsten Punkt.

Diese Erkennung kann mit vielen Methoden erzielt werden, die untereinander auskombiniert werden können.

Folgende Optionen liegen für das Thresholding vor:

* normale Thresholding Algorithmen
* Holistically Nested Edge Detection als Threshold

Zu notieren ist, dass hier ein Gausscher Blur noch angewendet werden muss um die Performance zu verbessern.

Das Ergebnis kann dann mit folgenden Edge Detections noch verbunden werden:

* Canny Edge Detection
* Dilation + Canny Edge Detection (nur für HED)
* Hough Transform

Daraufhin müssen wir wirklich die Bounding Box für die Rechnung erhalten:

* Rechteck aus Hough Transform
* `findContours()` mit `minAreaRect()`
* `findContours()` mit `approxPolyDP()`

Theoretisch können auch all diese Schritte auch übersprungen werden, indem der Text auf dem ganzen Bild erkannt wird. Die Idee ist es, die Bounding Box zu nehmen, welche alle Texte umfasst, und diese Box dann als Rechnung anzunehmen. Problem hier ist, dass auch oft im Hintergrund (z.B. bei komplexen Hintergründen) Text erkannt wird, welcher die Bounding Box wieder fälscht.

### Lösung
Es hat sich gezeigt, dass die beste Kombination folgende ist:

* Gausscher Blur (5x5 Kernel)
* Otsu Thresholding
* `findContours()` mit `approxPolyDP()` und als Fallback `minAreaRect()`
* Vier Punkt Transformation um erkannten Teil des Bildes auszuschneiden

Dies ist aber noch immer keine universelle Lösung für das Problem.

## Wichtige Teile erkennen
Bevor der Text extrahiert werden kann, muss der wichtige Teil der Rechnung gefunden werden, aus welchem der Text und die Preise erkannt werden. Dies kann aber nur mit Hilfslinien, welche zum Beispiel bei Billa Rechnungen vorhanden sind, funktionieren.

Diese Linien können mithilfe des Hough Transforms erkannt werden. Hier ergab sich folgende Konfiguration als gut:

```python
lines = cv2.HoughLinesP(b_w_edges, 1, np.pi / 180, threshold=150, minLineLength=10, maxLineGap=300)
```

Da man davon ausgehen kann, dass die Rechnung gerade ist, müssen wir nur horizontale Linien erkennen. Da es aber sehr unwarscheinlich ist das die erkannte Linie wirklich einen Winkel von 0° besitzt, werden nur Linien genommen, welche sich zwischen -20° und 20° befinden.

```python
bounding_lines = []
for line in lines:
    x1, y1, x2, y2 = line[0]
    # calculate angle to check if its a horizontal line https://i.imgur.com/fCw3PHC.png
    # tan a = GK / AK
    x_diff = abs(x2 - x1)

    # to stay on the save side in case x_diff is 0
    if x_diff == 0:
        x_diff = 1

    # get angle to check if it can go through as a horizontal line
    angle = atan(abs(y2 - y1) / x_diff) * 180.0 / np.pi

    if abs(angle) < 20:
        # add line to array with coords
        # [(x1, y1),(x2, y2)]
        # [(x1, y1), (x2, y2)]
        avg_y = (y1 + y2) / 2
        bounding_lines.append(((x1, y1, x2, y2), avg_y))
```
Danach wird die Durchschnittliche X-Koordinate der Linken und Rechten Seite berechnet um dann das Rechteck zu bestimmten, welches den wichtigen Teil beinhaltet. Der nächste Schritt wäre, eine Vier Punkt Transformation durchzuführen um den erkannten Teil rauszuschneiden.

Falls keine Linien erkannt werden, wird einfach das Input Bild weiterverwendet. Aus diesem wird dann der Text erkannt.

## Texterkennung
Texterkennung oder auch "Optical character recognition" (OCR) ist das grundlegende Problem in dieser Aufgabenstellung. Die Preise als auch die Namen der Produkte müssen ausgelesen werden. Um dies zu realisieren, wurde \cite{tesseract} Googles Tesseract Engine verwendet. Die Engine ist open source und wird von Google weiterentwickelt. Diese besteht aus mehreren \cite{lstm} LSTM Netzwerken, welche für verschiedene Aufgaben zuständig sind.

Um die Daten aus der Engine schön formatiert zu erhalten, wird die `pytesseract` Bibliothek verwendet, welche eine Abstraktion der Tesseract Engine ist.

## Produkte und Preise erkennen
Nachdem der Text erkannt wurde, müssen Texte und Preise zusammengeführt werden. Hier trennen sich die Pfade je nach Anwendung. 

Falls der Camera Scanner für das Abhaken der Einkaufsliste verwendet wird, muss eine veränderte Variante des Stable Marriage Problems verwendet werden, welche die erkannten Produkte mit den vorhandenen vereinigt.

Falls der Camera Scanner für das Erstellen einer neuen Einkaufsliste verwendet wird, werden einfach die Items hinzugefügt.

# Backend
Um die ganze Pipeline von Transformationen der Bilder mit der App zu verbinden, wird eine REST API benötigt. Um dies zu realisieren, wurde eine Flask REST API gebaut. 

Folgende Endpunkte sind verfügbar, wobei die Basis URL [api.listassist.gq](https://api.listassist.gq/ "ListAssist Backend") ist.

\begin{longtable}[]{@{}llll@{}}
\toprule
Methode & Endpunkt & Parameter & Modus\tabularnewline
\midrule
\endhead
POST & /detect & Bild & Editor\tabularnewline
POST & /trainable & Bild + Koordinaten & Trainer\tabularnewline
POST & /prediction & Bild & Automatic\tabularnewline
\bottomrule
\caption{Endpunkt Struktur der REST API}
\end{longtable}

Flasks Development Server ist nicht für Produktionsumgebung geeignet. Aus diesem Grund muss Flask mit einem gunicorn WSGI HTTP Server kombiniert werden. \cite{flask_gunicorn} Wobei ein nginx Server auf diesen zeigt, da gunicorn dies empfiehlt. \cite{gunicorn_nginx} Dieser PC Server ist nur lokal erreichbar. Aus diesem Grund muss von einem Raspberry Pi, welcher Apache2 laufen hat, auf diesen nginx Server geproxied werden. Dieser Apache Server hostet die Projektwebsite. \abb{backend} Diese ganze Umgebung ist mit Docker Containern realisiert.

![Backend Flow\label{backend}](images/coja/backend.png)
\cite{backend_handy}
\cite{backend_cloudflare}
\cite{backend_arrow}
\cite{backend_rbpi}
\cite{backend_server}
\cite{backend_apache}
\cite{backend_nginx}
\cite{backend_gunicorn}
\cite{backend_python}


# Flutter Widget
Die ganze Logik steckt im größten Widget `CameraScanner`, welche alle Variablen und States speichern und kontrollieren muss. Dieses Widget kann in mehrere Abschnitte unterteilt werden.

## Camera Scanner Modi
Wie in der Problemstellung bereits erwähnt, ist das Auslesen der Rechnung
sehr schwer zu generalisieren. Das heißt eine Lösung zu finden, welche für
egal welche Art von Foto funktioniert, ist kaum realisierbar.

Aus diesem Grund wurde der Camera Scanner in drei Modi unterteilt:

* Editor
* Automatic
* Trainer (Default)

wobei der **Editor** Modus auch in Kombination mit den anderen zwei Modi verwendet werden kann.

### Editor
Dem User wird ein Crop, Zoom und Rotate Editor am Handy zur Verfügung gestellt. Um ein perfomanten und flüssigen
Editor zur Verfügung zu stellen, wurde das `image_cropper` Paket verwendet, welche das Foto nativ
auf Android als auch auf iOS transformiert. Der Nutzer muss daraufhin
den wichtigen Teil der Rechnung selbst auswählen und bestätigen.

#### Anforderungen
* Wichtiger Inhalt ausgewählt
* Text erkennbar

### Automatic
Der "Automatic" Modus ist ein sehr instabiler Modus und hat hohe Anforderungen an das Bild. Ziel ist es die Informationen aus der Rechnung auszulesen, ohne weitere Informationen, wie Koordinaten der Polygone etc., zu verwenden.

#### Anforderungen
* hoher Rechnungs zu Hintergrund Kontrast
* Billa Rechnung oder Linien, welche die Produkte vom Rest der Rechnung trennen
* Text erkennbar

### Trainer
Der Trainer Modus stellt dem User ein Quadliteral zur Verfügung, welcher sich bis zu bestimmten Grenzen verformen und bewegen lässt. Da der Canvas nur über den ganzen Bildschirm geht, müssen folgende Sachen selbst programmiert werden für das Selection Werkzeug:

* Collision Detection => Kollision mit Ende des Bildes?
* Angle Detection => Winkel des Quadliterals zu groß oder zu klein?
* Size Detection => Selection zu groß oder zu klein?

Wobei diese Detections die Selektion Rot aufleuchten lassen, um dem User zu zeigen, dass hier eine Grenze gesetzt ist.

Da hier ein eigener Editor programmiert wurde, existiert voller Zugriff auf alle verwendeten Variablen wie Pixel Werte, Koordinaten uvm.! Um einen Canvas zu erstellen wurde das `PolygonPainter` Widget ausprogrammiert, welches vom `CustomPainter` ableitet. \abb{polypainter} Dieser ist für das ganze Rendering des Bildes als auch für das Quadliteral verantwortlich. Wichtig zu notieren ist, dass das Quadliteral convex ist. (Jeder Winkel ist kleiner als 180°) \cite{convex}

![PolygonPainter Klassenstruktur \label{polypainter}](images/coja/polygonpainter.png)


#### Anforderungen
* Wichtiger Inhalt ausgewählt
* Text erkennbar

Da hier nicht nur das Bild, sondern auch die Koordinaten des wichtigen Teils an den Server gesendet werden,
wäre es theoretisch möglich ein Convolutional Neural Network im Hintergrund zu trainieren, welches das erkennen des wichtigen Teiles perfektioniert.

## API Calls
Wenn der User auf den "Check" Knopf drückt, wird je nach State ein API Call an die oben erwähnten Endpunkte abgesendet. Wenn dieser erfolgreich war, wird das Bild in Firestore hochgeladen.

### String Filterung
Hier in der Datei `mappings.dart` werden bedeutungslose erkannte Wörter und Symbole mithilfe Regulären Audrücken entfernt. Folgender Regex wird verwendet:


%|§|\?|\^|°|_|²|³|#|€|EUR|kassa|bon-nr|bonnr|filiale 

Ein weiterer Regex wird verwendet, um bei Produktnamen Nummern, Punkte oder Gewichtseinheiten zu entfernen.


\.|[0-9]|kg|g|-


Weiters werden erkannte Preise über 1000€ nicht angenommen und Produktnamen ohne Preise entfernt. Ein Produkt wird ebenfalls entfernt wenn die Namenslänge < 3 ist.

**Abhaken der Produkte**

Falls der Camera Scanner für das Abhaken der Produkte verantwortlich ist, wird zwischen jedem Erkannten und Existierendem Produkt eine **String Distanz** berechnet. Hier wurde der *Sorensen-Dice* Algorithmus verwendet, welcher im Vergleich zu *Distanz* basierten Algorithmen, wie der *Levensthein Distanz*, das Auftreten von Charactersequenzen mit der Länge von 2 als Metrik nimmt. \cite{string_algs} Diese Formel beschreibt diesen Algorithmus.

$$
    D = \frac{2 * \abs{X \cap Y}}{\abs{X} + \abs{Y}}
$$

\begin{center}
\begin{tabular}{@{}>{$}l<{$}l@{}}
X & Erstes Set\\
Y & Zweites Set\\
D & Resultierende Distanz
\end{tabular}
\end{center}

Diese Methode hat sich in der Praxis als gut erwiesen und erzielte bessere Ergebnisse als die Levensthein Distanz. Wichtig ist, dass die zu vergleichenden Strings in Kleinbuchstaben umgewandelt werden, da hier Groß und Kleinschreibung irrelevant ist und das Resulatat nur verschlechtert.

Um nur gute Übereinstimmungen dieses Algorithmuses zu verwenden, wurde ein Threshold von *0.55* verwendet. Nachdem die Distanz zwischen den Produkten berechnet wurde, wird eine modifizierte Variante des Stable Marriage Problems benutzt. Dieser Algorithmus soll enden, wenn folgendes eintrifft:

* Alle erkannten Produkte sind gematched.
* Alle Produkte in der Einkaufsliste besitzen schon die beste Übereinstimmung.

\begin{lstlisting}[language=Dart]
Map<Item, PossibleItem> findMappings({List<PossibleItem> possibleItems, List<Item> shoppingItems}) {
  Map<Item, List<PossibleItem>> shoppingToDetected = getShoppingToDetectedSorted(detectedItems: possibleItems, shoppingItems: shoppingItems);
  Map<PossibleItem, List<Item>> detectedToShopping = getDetectedToShoppingSorted(detectedItems: possibleItems, shoppingItems: shoppingItems);
  Map<Item, PossibleItem> finalMappings = {};

  /// Mapping Detected Items to ShoppingList items
  int cycleTimeout = 0;
  while (possibleItems.isNotEmpty && cycleTimeout < shoppingItems.length * 2) {
    /// Get Mappings for item
    PossibleItem currentPossibleItem = possibleItems.removeAt(0);
    List<Item> prefsForItem = detectedToShopping[currentPossibleItem];

    for (Item item in prefsForItem) {
      if (!finalMappings.containsKey(item)) {
        /// Stur einfügen
        finalMappings[item] = currentPossibleItem;
        cycleTimeout = 0;
        break;
      } else {
        /// check if mapped item on object has bigger index than current item
        PossibleItem mappedItem = finalMappings[item];
        List<PossibleItem> prefsForShoppingItem = shoppingToDetected[item];
        if (prefsForShoppingItem.indexOf(currentPossibleItem) < prefsForShoppingItem.indexOf(mappedItem)) {
          finalMappings[item] = currentPossibleItem;
          possibleItems.add(mappedItem);
          cycleTimeout = 0;
          break;
        }
      }
    }
    cycleTimeout++;
  }
  return finalMappings;
}
\end{lstlisting}

**Einkaufsliste aus Foto erstellen**

Da hier keine Referenzprodukte verwendet werden können, da die Billa Datenbank leider nicht zur Verfügung steht, muss hier nur der erkannte Preis samt Name zurückgeliefert werden.

**Verbesserungen**

Eine mögliche Verbesserung wäre es, mehrere String Distanzen (günstig wären 3) zu verwenden. Damit hätte man eine aussagekräftigere Metrik als mit nur einer Distanz.

Weiters, wäre eine Produktdatenbank von Billa zur Verfügung gestellt worden, könnte man den oben genannten Algorithmus ebenfalls verwenden. Jedoch müsste man hier sehr auf die Rechenleistung achten, da diese Methode viel Rechenaufwand beansprucht.

Zuletzt wäre es möglich, ein Long-Short-Term-Memory (LSTM) Netzwerk zu trainieren, welches ein Klassifizierungsproblem, wie die Kategorisierung der einzelnen Produkkte, löst.

\begin{figure}[H]
\centering
\includegraphics{images/coja/camera_scanner.png}
\caption{CameraScanner Widget Klassenstruktur}
\label{camerascanner_struct}
\end{figure}