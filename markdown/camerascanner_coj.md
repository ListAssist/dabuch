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
* findContours mit minAreaRect
* findContours mit approxPolyDP

Theoretisch können auch all diese Schritte auch übersprungen werden, indem der Text auf dem ganzen Bild erkannt wird. Die Idee ist es die Bounding Box zu nehmen, welche alle Texte umfasst, und diese Box dann als Rechnung anzunehmen. Problem hier ist, dass auch oft im Hintergrund (z.B. bei komplexen Hintergründen) Text erkannt wird, welcher die Bounding Box wieder fälscht.

### Lösung
Es hat sich gezeigt, dass die beste Kombination folgende ist:

* Gausscher Blur (5x5 Kernel)
* Otsu Thresholding
* findContours() mit approxPolyDP() und als Fallback minAreaRect()
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

| Methode | Endpunkt    | Parameter          | Modus     |
|---------|-------------|--------------------|-----------|
| POST    | /detect     | Bild               | Editor    |
| POST    | /trainable  | Bild + Koordinaten | Trainer   |
| POST    | /prediction | Bild               | Automatic |

Flasks Development Server ist nicht für Produktionsumgebung geeignet. Aus diesem Grund muss Flask mit einem gunicorn WSGI HTTP Server kombiniert werden. \cite{flask_gunicorn} Wobei ein nginx Server auf diesen zeigt, da gunicorn dies empfiehlt. \cite{gunicorn_nginx} Dieser PC Server ist nur lokal erreichbar. Aus diesem Grund muss von einem Raspberry Pi, welcher Apache2 laufen hat, auf diesen nginx Server geproxied werden. Dieser Apache Server hostet die Projektwebsite. \abb{backend}

![Backend Flow\label{backend}](images/coja/backend.png)

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
Hier werden unsinnige erkannte Wörter und Symbole mithilfe Regulären Audrücken entfernt. Folgender Regex wird verwendet:


%|§|\?|\^|°|_|²|³|#|€|EUR|kassa|bon-nr|bonnr|filiale 

Ein weiterer Regex wird verwendet, um bei Produktnamen Nummern, Punkte oder Gewichtseinheiten zu entfernen.


\.|[0-9]|kg|g|-


Weiters werden erkannte Preise über 1000€ nicht angenommen und Produktnamen ohne Preise entfernt. Ein Produkt wird ebenfalls entfernt wenn die Namenslänge < 3 ist.

Falls der Camera Scanner für das Abhaken der Produkte verantwortlich ist, wird zu jedem P

Je nach Anwendungsfall des Camera Scanners, wird jetzt entweder ein modifiziertes Stable Marriage Problem gelöst, falls eine Einkaufsliste abgehackt werden soll, oder die erkannten Preise mit Produktnamen zurückgeliefert.

![CameraScanner Widget Klassenstruktur \label{camerascanner_struct}](images/coja/camera_scanner.png)

----------- AB HIER WEGSCHNEIDEN --------------------

# Algorithmen
Die oben genannten Problemstellungen können mit vielen verschiedenen Algorithmen bis zu einem bestimmten Grad gelöst werden.
Hier werden mal die wichtigsten Algorithmen aufgelistet, als auch ihre Lösung für die Probleme.

## Threshold
Um die Kanten der Rechnungen hervorzuheben, kann man sich den Kontrast zum Hintergrund zu Nutze machen. Threshold Algorithmen
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

In Python ist dieser Algorithmus ganz einfach implementiert.
```python
import cv2

img = cv2.imread("images/rechnung.jpeg", cv2.IMREAD_GRAYSCALE)
thresholded_image = (img > thresh) * 255
```

### Local Adaptive Thresholding
Es kann oft dazu kommen, dass eine Rechnung an einigen Stellen mehr beleuchtet ist als andere Stellen, siehe Vergleich zwischen Simple Binary Thresholding und Adaptive Gauss \abb{Thresholding Vergleich}. Aus diesem Grund ist es unmöglich nur einen globalen Wert zu nehmen, welcher über das ganze Bild die erwarteten Ergebnisse liefert, da der Hintergrund unterschiedlich hell ist.

Der Trick ist es, verschiedene Thresholdwerte für bestimmte Bereiche des Bildes zu nehmen. Innerhalb dieses Bereiches (z.B. 11x11 Pixel) kann dann ein bestimmter Wert als Threshold genommen werden. Um diesen Wert zu bestimmten, gibt es verschiedenste Methoden. 

* Mittelwert des Blockes als Threshold Wert
* Gewichteter Mittelwert des Blockes, wobei die Gewichte durch einen Gausschen Filter gegeben werden, wobei die Summe aller Gewichtungen = 1 sein müssen.
    $$
        \sum_{row = 0}^{blockSize} \sum_{col = 0}^{blockSize} G_w = 1
    $$
    Der Vorteil hierbei ist, dass Pixel die weiter entfernt sind im Block, weniger Einfluss auf den Mittelwert haben.

    Beispiel Gewichte für ein 3x3 Block \cite{GausscherKernelRechner}
    $$
    \begin{bmatrix}
    0.102059 & 0.115349 & 0.102059 \\
    0.115349 & 0.130371 & 0.115349 \\
    0.102059 & 0.115349 & 0.102059
    \end{bmatrix}
    $$

    Die Gewichte werden von der Funktion eines 2D Gausschen Filters entnommen \cite{GausscherFilterFormel}, welcher mithilfe nummerischer Integration diskrete Werte erhält.
    $$
        g(x, y) = e^{\frac{-(x^2 + y^2)}{2\sigma^2}}
    $$

    In OpenCV wird das sigma als $\sigma = 0.3 * (blockSize / n - 1) + 0.8$ definiert. \cite{OpenCVSigma}
    ![2D Gausscher Filter mit $\sigma = 1$ \label{2D Gauss}](images/coja/2d_gauss.PNG)
* Median des Blockes

Adaptive Methoden haben das Problem, dass oft ein Block nur aus zum Beispiel schwarzen Pixel besteht. (Vielleicht ein Hintergrund?). Hier würde es keinen Sinn machen einen Threshold zu nehmen, da die Pixel nur minimal abweichen. Aus diesem Grund verwenden wir noch eine Konstante $C$ welche vom ermittelten Threshold abgezogen wird.

**Integral Images**

Um die Pixelsumme effizient zu berechnen, wird ein Integral Bild, auch Summed-Area-Table genannt, erstellt. \cite{IntegralImages}. Ziel ist es für ein Rechteck in einem Bild die Pixelsumme zu ermitteln.

Um die Summed-Area-Table schnell in einem Durchlauf zu berechnen, können wir folgende Formel verwenden.
$$
    I(x, y) = i(x, y) + I(x, y - 1) + I(x - 1, y) - I(x - 1, y - 1)
$$

\begin{center}
\begin{tabular}{@{}>{$}l<{$}l@{}}
I(x,y) & Summe der Pixel bis zu Pixel Position (x, y) \\
i(x,y) & Pixelintensität bei Position (x, y)
\end{tabular}
\end{center}

Die Implementierung sieht wie folgt aus.
```python
def gen_integral_img(image):
    height, width = image.shape

    integral = np.zeros_like(image, dtype=int)
    # create first x and y row so faster algorithm can come to use
    for col in range(width):
        integral[0, col] = image[0, 0:col].sum()
    for row in range(height):
        integral[row, 0] = image[0:row, 0].sum()

    # use fast formula: I(x,y) = i(x,y) + I(x, y-1) + I(x-1, y) - I(x-1, y-1)
    for col in range(1, width):
        for row in range(1, height):
            integral[row, col] = image[row, col] + integral[row - 1, col] + integral[row, col - 1] - integral[row - 1, col - 1]

    return integral
```

![Integral Bild visualisiert. Die Pixelsumme steigt, da immer weiter aufsummiert wird. \label{Integral Bild visualisiert}](images/coja/integral_vis.PNG)

Mit den vorgerechneten Summen im Integral Bild, kann man schnell für eine bestimmte Fläche im Bild die Pixelsumme errechnen. Mit folgender Formel kann dies erreicht werden.

$$
    sum(A, B, C, D) = I(D) - I(B) - I(C) + I(A)
$$

\begin{center}
\begin{tabular}{@{}>{$}l<{$}l@{}}
A, B, C, D & Koordinaten des Rechtecks, wessen Summe berechnet werden soll
\end{tabular}
\end{center}

![Die größte Summe $D$ wird von den kleineren Rechtecken $B$ und $C$ abgezogen. Da das kleine Rechteck links oben zwei mal abgezogen wird, müssen wir noch $A$ addieren. \label{Summed Area Final Calc}](images/coja/integral_calc.png)

Jetzt müssen wir für jeden Pixel im Bild, die Pixelsumme innerhalb des Pixel holen. Mit dieser Summe dann mit $\frac{Wert}{blockSize^2}$ den Mittelwert oder Median ermittelt. Bei der gausschen Methode müssen wir nicht nochmal dividieren, da die Gewichtungen sich alle schon auf 1 summieren.

Wenn wir den Threshold dann haben, fragen wir ab, ob der derzeitige Pixel über oder unter dem Threshold ist. Je nach dem welche Bedingung übereinstimmt, wird dann Schwarz (0) oder Weiß (1) für den Pixel gesetzt.

Hier wurde in python mal der Algorithmus mit dem Mittelwert implementiert.
```python
def adaptive_mean_thresh(input_img, blockSize, C):
    height, width = input_img.shape
    integral = gen_integral_img(input_img)

    # calculate boxes
    output_image = np.zeros_like(input_img)
    margin = int((blockSize - 1) / 2)
    for x in range(margin, width-margin):
        for y in range(margin, height-margin):
            pixel = input_img[y, x]
            thresh = get_threshold_for_area(input_img, integral, (x, y), blockSize)
            thresh -= C
            if pixel >= thresh:
                output_image[y, x] = 255
            else:
                output_image[y, x] = 0

    return output_image

def get_threshold_for_area(image, I, pos: tuple, b: int):
    h, w = image.shape
    x, y = pos
    db = int((b - 1) / 2)

    if 0 + db <= x <= w - db or 0 + db <= y <= h - db:
        #                  I(D)       +        I(A)     +     I(B)        -       I(C)
        pixel_sum = I[y + db, x + db] + I[y - db, x - db] - I[y - db, x + db] - I[y + db, x - db]
        return pixel_sum / b**2
```


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
\sigma_{intra}^2 & Intra-class Varianz \\
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

Im Bild kann man schön den Verlauf der Inter-Klassen Varianz sehen. Der grüne Strich kennzeichnet den ermittelten Threshold. Man erkennt, dass dieser sich genau bei der Maxima der Inter-Klassen Varianz befindet. \abb{Inter Klassen Varianz}

![Verlauf der Inter-Klassen Varianz \label{Inter Klassen Varianz}](images/coja/otsu_graph.PNG)

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
Kanten in einem Bild hervorzuheben. Das Neuronale Netzwerk basiert auf einer \cite{VGGNet} VGGNet Architektur und beinhaltet auch
Residual Connections.

Der Vorteil hierbei ist, dass das Neuronale Netzwerk nicht zu sehr vom Kontrast abhängt - ein klarer Vorteil gegenüber herkömmlichen Threshold Algorithmen.

## Hough Lines
Hough Space => wie funktioniert es?

# Wichtige Teile extrahieren
Dieser Algorithmus funktioniert nur für **Billa** Rechnungen, da diese eine markable Linie zwischen
den Produkten zur Verfügung stellen.


**Bild für Billa Rechnung einfügen**

Diese Linien werden dann mit der oben erklärten "_Hough Lines Methode_" zu erkennen versucht. Jedoch werden auch viele andere
Linien, wie z.B. die Kanten der Rechnung, miterkannt. Um die zwei richtigen Linien zu finden, wird davon ausgegangen, dass
die Linie mit dem kleinsten Y-Achsen Wert, die obere Rechnungskante ist.

# Texterkennung
Zuletzt

----------- BIS HIER WEGSCHNEIDEN --------------------

