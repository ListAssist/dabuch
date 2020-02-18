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

# Algorithmen
Die oben genannten Problemstellungen können mit vielen verschiedenen Algorithmen bis zu einem bestimmten Grad gelöst werden.
Hier werden mal die wichtigsten Algorithmen aufgelistet, als auch ihre Lösung für die Probleme.

## Threshold
Um die Kanten der Rechnungen zu erkennen, kann man sich den Kontrast zum Hintergrund zu Nutze machen. Threshold Algorithmen
analysieren die Helligkeit der Pixel und stufen es in Weiß (1) oder Schwarz (0) ein.

Thresholding Methoden können in drei folgende Gruppen unterteilt werden.

### Global Thresholding
Hier wird ein bestimmter Grauwert als Grenze
genommen und es wird geprüft, ob dieser überschritten wird.

Folgende Funktion beschreibt den Algorithmus:

$$  
f(G) =   
\begin{cases}  
       \text{255,} &\quad\text{if G} \ge T \\  
       \text{0,} &\quad\text{if G} \le T-1 \\  
\end{cases}  
$$

\begin{center}
\begin{tabular}{@{}>{$}l<{$}l@{}}
G & Grayscale Wert des Pixels\\
T & ausgesuchter Threshold Wert ($ 0 \le T \le 255 $)
\end{tabular}
\end{center}

### Local Adaptive Thresholding
Es kann oft dazu kommen, dass eine Rechnung an einigen Stellen mehr beleuchtet ist als andere Stellen, siehe Vergleich zwischen Simple Binary Thresholding und Adaptive Gauss \abb{Thresholding Vergleich}. Aus diesem Grund ist es unmöglich nur einen globalen Wert zu nehmen, welcher über das ganze Bild die erwarteten Ergebnisse liefert, da der Hintergrund unterschiedlich hell ist.

Der Trick ist es, verschiedene Thresholdwerte für bestimmte Bereiche des Bildes zu nehmen. Innerhalb dieses Bereiches (z.B. 11x11 Pixel) kann der normale oder gewichtete Mittelwert als Threshold genommen werden. Wobei die Gewichte für die Pixelwerte dann ein Gaussian Kernel ist. \cite{GaussianKernel}

Dies bringt den Vorteil mit sich, dass Pixel welche weiter entfernt sind vom derzeitigem Pixel weniger gewichtet werden. Aus diesem Grund schweift der Integral Bild Algorithmus vom orginalem ab, da hier die Summen anderes berechnet werden müssen.

Um die Pixelsumme effizient zu berechnen, wird ein Integral Bild erstellt. \cite{IntegralImages}. Damit wird ein Lookup Table erstellt, in welchem wir mit folgender Formel

$$
 
$$

### Otsu's Methode
\cite{Otsu} Otsu's Methode kann auch zu den Globalen Threshold Kategorien gezählt werden. Otsu versucht anhand eines Histogrammes, die gewichtete Intra-class Varianz zu minimieren. Die gesamte Varianz des Histogrammes sieht wie folgt aus
$$
    \sigma^2 = \sigma_{intra}^2 + \sigma_{inter}^2
$$
wobei gilt, dass sich die Intra-class Varianz durch die gewichtete Summe der Varianzen der zwei Klassen. Wobei die Gewichte die Eintrittswarscheinlichkeiten der Klasse selbst sind.
$$
    \sigma_{intra}^2 = q1*\sigma_1^2 + q2 * \sigma_2^2
$$

Die Inter-Klassen varianz ergibt sich wie folgt

$$
    \sigma_{inter}^2 = q1 * q2 (\mu1 - \mu2)
$$

wobei $q2 = (1 - q1)$ da jedem Pixel Wert von $0 - 255$ eine Eintrittswarscheinlichkeit, im Bezug auf die Anzahl des Pixels im Histogramm, hergegeben wurde.

Wie wir sehen, wenn wir $\sigma_{intra}^2$ minimieren, maximieren wir $\sigma_{inter}^2$. Das Maximieren wird hier bevorzugt, da diese perfomanter und leichter zu berechnen ist.

#### Algorithmus

\begin{center}
\begin{tabular}{@{}>{$}l<{$}l@{}}
\sigma_intra^2 & Intra-class Varianz \\
\sigma_{inter}^2 & Inter-Klassen Varianz \\
q1 & Eintrittswarscheinlichkeit der Klasse 1 \\
\mu1 & Durchschnitt Klasse 1 \\
\sigma_1^2 & Varianz der Klasse 1 \\
q2 & Eintrittswarscheinlichkeit der Klasse 2 \\
\mu2 & Durchschnitt Klasse 2 \\
\sigma_2^2 & Varianz der Klasse 2
\end{tabular}
\end{center}

 Interessant ist es, wie man den Threshold ermittelt. Der Algorithmus sieht wie folgt aus:

\cite{OtsuVideo} \cite{OtsuWiki}


* Erstelle eine Eintrittswarscheinlichkeit für jeden Grauwert aus dem Histogramm 
```python
    histogram, _ = np.histogram(img, bins=256)
    histogram = histogram / histogram.sum()
    # histogram.sum() = 1 jetzt
```
* Iteriere durch alle möglichen Thresholds $1 \le t \le 255$
  
    ```python
    for t in range(1, 255):
    ```
    * Berechne $q1$ und $q2$ mit
    $$
        q1 = \sum_{i=1}^{t}P(i)
    $$
    $$
        q2 = \sum_{i=t+1}^{256}P(i)
    $$
    ```python
    q1 = histogram[:t].sum()
    q2 = histogram[t:].sum()
    ```
    * Berechne $\mu1$ und $\mu2$
    $$
        \mu1 = \frac{1}{q1} * \sum_{i=1}^{t}i * P(i)
    $$
    $$
        \mu2 = \frac{1}{q2} * \sum_{i=t+1}^{256}i * P(i)
    $$
    ```python
    u1 = np.arange(0, t) * histogram[:t]
    u1 = u1.sum() / q1
    
    u2 = np.arange(t, 256) * histogram[t:]
    u2 = u2.sum() / q2
    ```
    * Berechne die Inter-Klassen Varianz
    $$
        variance = q1 * (1 - q1) * (\mu1 - \mu2)^2 
    $$
    ```python
        variance = q1 * (1 - q1) * (u1 - u2)**2
    ```
    * Prüfe ob $v_{neu} > v_{alt}$, wenn ja, setze neuen threshold $t$ und setze $v_{alt} = v_{neu}$
* Threshold nehmen, welcher die höchste Inter-Klassen Varianz hat
```python
otsu_output = (img > thresh) * 255
```

\begin{center}
\begin{tabular}{@{}>{$}l<{$}l@{}}
P(i) & Eintrittswarscheinlichkeit der Pixelintensität an Stelle $i$ \\
t & derzeitiger getesteter Threshold \\
i & Position im Histogramm \\
v_{neu} & neu berechnete Inter-Klassen Varianz \\
v_{alt} & höchst aufgetretende Varianz bis zum jetzigem Zeitpunkt
\end{tabular}
\end{center}

Im Bild kann man schön den Verlauf der Inter-Klassen Varianz sehen. Der grüne Strich kennzeichnet den ermittelten Threshold. Man erkennt, dass dieser sich genau bei der Maxima der Inter-Klassen Varianz befindet. \abb{Otsu Graph}

[Verlauf der Inter-Klassen Varianz \label{Otsu Graph}](images/coja/otsu_graph.PNG)

### Der Vergleich
Um die Thresholding Algorithmen zu vergleichen, wurde dieser folgende Code Snippet erstellt.
```python
import cv2
import matplotlib.pyplot as plt

# Load image from disk
img = cv2.imread("images/rechnung.jpeg", cv2.IMREAD_GRAYSCALE)

# simple thresholding
_, simple = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY)
# adaptive gauss thresholding (blockSize=11, C=2)
adaptive_gauss = cv2.adaptiveThreshold(img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)
# otsu's method
_, otsu = cv2.threshold(img, 0, 255, cv2.THRESH_OTSU)

# create mappings
headlines = ["Grayscale Bild", 'Simple Binary Threshold (T=128)',
            'Adaptive Gauss Threshold', 'Otsu Threshold']
images = [img, simple, adaptive_gauss, otsu]

# plot images using matplotlib
for i in range(len(headlines)):
    plt.subplot(2, 2, i + 1), plt.imshow(images[i], 'gray')
    plt.title(headlines[i])
plt.show()
```

Generell kann gesagt werden, dass Adaptive Methoden als auch Otsus Thresholding Methode, einfache Thresholding
Algorithmen deutlich übertrifft in der Aufgabe Kanten hervorzuheben. In dem im Beispiel gezeigten Bild erkennt man, dass
das der Boden das Licht reflektiert und daher der Kontrast nicht mehr so gegeben ist wie in anderen Teilen des Bildes.
\abb{Thresholding Vergleich}

![Histogramm des Bildes\label{Bild Histogramm}](images/coja/threshold_histogram.png){width=8cm}


![Endergebniss der verschiedenen Thresholding Algorithmen\label{Thresholding Vergleich}](images/coja/threshold_comparison.PNG)



## Holistically-Nested Edge Detection
\cite{HED} Holistically-Nested Edge Detection (auch HED genannt), ist ein Deep Learning Ansatz, um
Kanten in einem Bild hervorzuheben. Das Netzwerk basiert auf einer \cite{VGGNet} VGGNet Architektur und beinhaltet auch
Residual Connections.

Der Vorteil hierbei ist, dass das Netz nicht zu sehr vom Kontrast abhängt - ein klarer Vorteil gegenüber herkömmlichen Threshold Algorithmen.

## Hough Lines
Hough space bla bla polare darstellungs

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
