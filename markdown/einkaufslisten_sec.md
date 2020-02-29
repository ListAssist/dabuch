# Offene Einkaufslisten

Nach abschließen einer Einkaufsliste wird diese in dem "Erledigt" Bereich angezeigt. Die
eingescannten Rechnungen können dann inkl. ihrer erkannten Produkte und Preise angezeigt werden.

# Abgeschlossene Einkaufslisten

In den abgeschlossenen Einkaufslisten werden die sowohl die Produkte, die gekauft wurden, als auch
die Produkte, die nicht gekauft wurden, seperat angezeigt. Ebenso werden die Anzahl der gekauften
Produkte und der Preis, den der Benutzer eingestellt hat bzw. ein Preis von 0,\- € falls
kein Preis eingestellt wurde angezeigt. Ganz oben steht ein Text, wann der Einkauf abgeschlossen
wurde. 

Die abgeschlossenen Einkaufslisten können, wie die offenen Einkaufslisten, ebenfalls gelöscht werden.
Es ist auch möglich, eine bereits abgeschlossene Einkaufsliste als neue Einkaufsliste zu kopieren.
Dabei kann der Benutzer einen neuen Namen eingeben und auswählen, ob nur gekaufte, nur nicht gekaufte oder gekaufte und nicht gekaufte Produkte kopiert werden sollen. Lässt der Benutzer das
Feld für den Namen leer, wird der Name der abgeschlossenen Einkaufsliste verwendet.

Um all dies zu realisieren, werden die Produkte in gekaufte und nicht gekaufte Produkte eingeteilt.
Eine Liste von `Item` `allItems` wird aus der Datenbank geladen, falls der User sowohl gekaufte als
nicht gekaufte Produkte kopieren will. Zwei weitere Listen, `completedItems` und `uncompletedItems`
werden erstellt, indem zuerst alle Items in diese Listen kopiert werden und dann mit
`removeWhere((item) => !item.bought)` die nicht gekauften bzw. mit `removeWhere((item) => item.bought)`
die gekauften Produkte entfernt werden. 

## Eingescannte Rechnungen
# Einkaufslisten bearbeiten