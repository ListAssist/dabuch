# Produkte suchen

Zum Suchen und Speichern, der von uns selbst erstellten Produkte, wird Algolia verwendet.
Der Free Plan von Algolia erlaubt es bis zu 10.000 Datensätze zu speichern, was mehr als ausreichend war.
Auch aufgrund der schnellen und anpassbaren Suche war Algolia eine gute Wahl. Die Produkte konnten effizient
mittels JSON in die Datenbank eingefügt werden.
Für die Algolia Suche in Flutter wurde das ```algolia``` Package verwendet, welches eine einfache 
Implementierung bereitstellt.

\begin{lstlisting}[language=Dart]
AlgoliaQuery query = algolia.instance.index('products')
    .search(searchText);
AlgoliaQuerySnapshot snap = await query.getObjects();
List<dynamic> hits = List<dynamic>();
snap.hits.forEach((h) => {hits.add(h.data)});
\end{lstlisting}

# Produkte zu Einkaufslisten hinzufügen

## Allgemein

Die Produktdatenbank beinhaltet essentielle Produkte, die häufig auf Einkaufslisten zu finden sind. Alle Produkte in
der Datenbank besitzen außerdem eine Kategorie, nach welcher sie ebenfalls gesucht werden können. Bei den erstellten
Produkten und Kategorien wurde sich vor allem auf Lebensmittel und Haushaltswaren fokusiert.
Benutzer haben mehrere Möglichkeiten, Produkte zu Einkaufslisten hinzuzufügen.
Eine Variante wäre es, in der Produktdatenbank mittels Algolia nach den gewünschten Artikeln zu suchen. Falls es das 
gewünschte Produkt nicht in der Datenbank gibt, hat der Benutzer selbstverständlich die Möglichkeit es selbst zu erstellen
und auf die Einkaufsliste zu schreiben. Weiters können Benutzer auch die vorhandenen Kategorien manuell nach Produkten 
durchsuchen und diese von dort aus hinzufügen.

\needspace{10cm}

Fügt ein Benutzer Produkte zu einer Einkaufsliste hinzu, wird das `Produkt` Model zu einem `Item` und in der `items` 
Subcollection der `lists` Collection eines `user`s gespeichert. Ein `Item` hat neben
dem `name` und der `category` auch einen `count`, wie oft sich das `Item` auf der Einakufsliste befindet. Ebenfalls haben `Item`s 
eine `price` Variable und eine boolean Variable `bought`, welche true ist, wenn der Benutzer das `Item` von der Einkaufsliste gestrichen hat.

Der `SearchItemsView` wird beim Hinzufügen von Produkten zu Einkaufslisten und ebenfalls bei Rezepten verwendet. Anfangs gab es dafür 2 eigene Widgets, jedoch 
gibt es einige Vorteile, die durch die Wiederverwendung des `SearchItemsView` Widgets erreicht werden konnten. Änderungen müssen 
dadurch nicht in beiden Widgets gemacht werden und es muss nicht auf das einheitliche Design in beiden Widgets geachtet werden. Um dies zu implementieren
wurde ein Parameter im `SearchItemsView` Widget erstellt, welcher angibt, ob es sich um eine Einkaufsliste oder ein Rezept handelt, das der Benutzer
gerade bearbeitet. Falls es sich um ein Rezept handelt werden kleine Veränderungen am `SearchItemsView` durchgeführt und bei Aktionen des
Benutzers wird die `updateRecipe` Methode statt der `updateList` Methode aufgerufen, um die Änderungen in der Datenbank zu speichern.

## Spracheingabe

Eine weitere Variante Produkte zu Einkaufslisten hinzuzufügen ist die Spracheingabe. Benutzer können mehrere Produkte per Sprachsteuerung durch
"und" getrennt auflisten und so hinzufügen. Für die Spracheingabe wurde das ```speech_recognition``` Package verwendet.
Im `AndroidManifest.xml` musste dafür Folgendes eingefügt werden.
\begin{lstlisting}[language=XML]
<uses-permission android:name="android.permission.RECORD_AUDIO" />
\end{lstlisting}

\needspace{10cm}

# Datenbankzugriffe

Um die Datenbankzugriffe zu verringern wurde eine debounce Funktion beim Suchen, Hinzufügen und Löschen der Produkte implementiert.
Jedes Mal, wenn der Benutzer Produkte sucht, hinzufügt oder von der Einkaufsliste entfernt, werden die Funktionen `_searchProducts` oder `_requestDatabaseUpdate`
aufgerufen, welche die Datenbankzugriffe erst durchführen, nachdem die jeweilige Funktion innerhalb der `_debounceTime` nicht erneut aufgerufen wurde.
Die `_debounceTime` wurde beim Suchen der Produkte auf 500 Millisekunden beschränkt um die User Experience nicht zu verringern. Beim 
Aktualisieren der Einkaufsliste, wenn Produkte hinzugefügt oder entfernt wurden, beträgt die `_debounceTime` 2 Sekunden, da sie sich hier
nicht auf die User Experience auswirkt.


\begin{lstlisting}[language=Dart]
_requestDatabaseUpdate() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: _debounceTime), () {
      if (_list != null && _user.uid != null) {
        databaseService.updateList(_list)
            .then((value) => {
                print("Liste wurde erfolgreich upgedated")
            })
            .catchError((_) => {
                print(_.toString())
            })
      }
    });
}
\end{lstlisting}


# Preise zu Produkten hinzufügen

Benutzer haben die Möglichkeit, den `Item`s einer Einkaufsliste, Preise zuzuteilen. Preise die der Camera Scanner erkennt werden ebenfalls automatisch
in den den `Item`s gespeichert.




