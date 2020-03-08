# Listenansicht der Einkaufslisten

Die Einkaufslisten, egal ob abgeschlossen oder nicht, werden in Form einer Liste dargestellt.
Bei beiden Listenarten gelangt man über einen Klick auf einen Eintrag in die Detailansicht der jeweiligen
Liste. Die Inhalte dieser Detailansichten werden in den nachfolgenden Unterkapiteln beschrieben.

Bei den offenen Einkaufslisten stehen als Listeneinträge der Name der Einkaufsliste und darunter,
in der Form "X/Y eingekauft", wie viele Produkte bereits von den insgesamten Produkten gekauft wurden.
Dabei wird die Stückzahl der Produkte nicht beachtet, sprich, wenn auf der Einkaufsliste "4x Milch" steht,
zählt dieser Eintrag nur als 1 Produkt. Bei langem gedrückt halten auf einen Eintrag wird ein Popup-Menü mit
den Optionen zum Bearbeiten und Löschen der Liste angezeigt. 

Bei den abgeschlossenen Einkaufslisten stehen als Listeneinträge der Name der Einkaufsliste und darunter,
in der Form "Erledigt am DD.MM.YYYY", wann der Einkauf abgeschlossen wurde. Bei langem gedrückt halten auf
einen Eintrag wird ein Popup-Menü mit den Optionen zum Kopieren\todo{Noch programmieren} und Löschen der Liste angezeigt. 

# Offene Einkaufslisten

Bei den offenen Einkaufslisten werden der Text, wie viele Produkte bereits gekauft wurden (\siehe{listenansicht-der-einkaufslisten})
und die Liste der zu kaufenden Produkte angezeigt. Die Liste der Produkte ist eine `ListView`, die `CheckboxListTile`s beinhaltet.
Die `CheckboxListTile`s sind wie folgt aufgebaut: An erster Stelle ist die Checkbox, danach kommen der Produktname und darunter die Anzahl der
Produkte, die zu kaufen sind. An letzter Stelle ist ein Feld, in das der Preis des Produktes eingetragen werden kann.

Nach abschließen einer Einkaufsliste wird diese in dem "Erledigt" Bereich angezeigt. Die
eingescannten Rechnungen können dann inkl. ihrer erkannten Produkte und Preise angezeigt werden.

\needspace{4cm}
# Abgeschlossene Einkaufslisten

Bei den abgeschlossenen Einkaufslisten werden die sowohl die Produkte, die gekauft wurden, als auch
die Produkte, die nicht gekauft wurden, separat angezeigt. Ebenso werden die Anzahl der gekauften
Produkte und der Preis, den der Benutzer eingestellt hat bzw. ein Preis von 0,- € falls
kein Preis eingestellt wurde angezeigt. Ganz oben steht ein Text, wann der Einkauf abgeschlossen
wurde. 

Die abgeschlossenen Einkaufslisten können, wie die offenen Einkaufslisten, ebenfalls gelöscht werden.
Es ist auch möglich, eine bereits abgeschlossene Einkaufsliste als neue Einkaufsliste zu kopieren.
Dabei kann der Benutzer einen neuen Namen eingeben und auswählen, ob nur gekaufte, nur nicht gekaufte
oder gekaufte und nicht gekaufte Produkte kopiert werden sollen. Lässt der Benutzer das
Feld für den Namen leer, wird der Name der abgeschlossenen Einkaufsliste verwendet.

Um all dies zu realisieren, werden die Produkte in gekaufte und nicht gekaufte Produkte eingeteilt.
Eine Liste von `Item` `allItems` wird aus der Datenbank geladen, falls der User sowohl gekaufte als
nicht gekaufte Produkte kopieren will. Zwei weitere Listen, `completedItems` und `uncompletedItems`
werden erstellt, indem zuerst alle Items in diese Listen kopiert werden und dann mit
`removeWhere((item) => !item.bought)` die nicht gekauften bzw. mit `removeWhere((item) => item.bought)`
die gekauften Produkte entfernt werden. 

## Eingescannte Rechnungen

Die eingescannten Rechnungen können in der Detailansicht der abgeschlossenen Einkaufsliste angesehen werden, sofern
Rechnungen für eine Einkaufsliste eingescannt wurden. Die Rechnungen werden dann als Carousel dargestellt. Dafür
wurde die Bibliothek `carousel_slider`\footnote{\url{https://pub.dev/packages/carousel_slider}} verwendet. Sobald
auf eines der Bilder geklickt wird gelangt der Benutzer in die Detailansicht für diese Rechnung. In dieser Ansicht
gibt es zwei Reiter, zum einen wird noch einmal das Bild gezeigt, diesmal aber mit der Funktionalität zu zoomen, und
zum anderen wird die Liste der erkannten Produkte, inklusive deren Preisen, angezeigt.

# Einkaufslisten bearbeiten