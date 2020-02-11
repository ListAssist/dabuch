# Allgemein

# Problemstellungen

Das einscannen

# Camera Scanner Modis

Wie in der Problemstellung bereits erwähnt, ist das Auslesen der Rechnung
sehr schwer zu generalisieren. Das heißt eine Lösung zu finden, welche für
egal welche Art von Foto funktioniert, ist kaum realisierbar.

Aus diesem Grund wurde der Camera Scanner in drei Modis unterteilt:

* Editor
* Selector
* Trainer

wobei der **Editor** auch als Hilfe für die anderen zwei Editoren verwendet
werden kann.

# Rechnungserkennung

## Threshold Algorithmen

## Holistically-Nested Edge Detection

\cite{HED} Holistically-Nested Edge Detection (auch HED genannt), ist ein Deep Learning Ansatz, um
Kanten in einem Bild hervorzuheben. Das Netzwerk basiert auv einer \cite{VGGNet} VGGNet Architektur und beinhaltet auch
Residual Connections