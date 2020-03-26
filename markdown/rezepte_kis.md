\newcommand\mypicWidth{0.45}

# Allgemein

Um es dem Benutzer zu ermöglichen bestimmte Einkaufslisten schneller zu erstellen,
ohne jedes Mal die selben Produkte zu suchen, wurde die Rezepte Funktion entwickelt.
Mit dieser Funktion haben Benutzer die Möglichkeit Vorlagen für häufig verwendete 
Einkaufslisten, sogenannte Rezepte, zu erstellen.

In Firebase werden die Rezepte in der `recipes` Subcollection des Users gespeichert.
Recipes haben einen `name`, eine `description` und ein `items` Array. 

In der App werden Rezepte mithilfe von `Card` Widgets dargestellt. Um Platz zu sparen 
und möglichst viele Rezepte gleichzeitig anzuzeigen wurden `ExpansionTile`s innerhalb 
der `Card`s verwendet. Die `ExpansionTile`s zeigen am Anfang nur den Rezpetnamen an und 
lassen sich mit einem Klick aufklappen, um die alle Details der Rezepte anzuzeigen. Klickt
der Benutzer auf den "Liste erstellen" Button wird eine Einkaufsliste mit allen Produkten
des Rezepts erstellt. 

Für den Button wurde das `FloatingActionButton.extended` Widget verwendet.
Dieser ist außerdem nur aktiviert, falls der Benutzer zumindest ein Produkt zum Rezept hinzugefügt
hat. Deshalb wird die `onPressed` Variable auf `null` gesetzt und die Farbe des `FloatingActionButton.extended`
wird grau, wenn das Rezept noch keine Items besitzt.

\begin{lstlisting}[language=Dart]
FloatingActionButton.extended(
    icon: Icon(Icons.check),
    label: Text("Liste erstellen"),
    backgroundColor: recipes[index].items.length > 0 
        ? Colors.green 
        : Colors.grey,
    onPressed: recipes[index].items.length > 0
        ? () async {
            /* List gets created here */
        }
        : null,
),
\end{lstlisting}

\begin{figure}[H]
    \begin{minipage}{\mypicWidth\textwidth}
        \includegraphics[width=\textwidth, keepaspectratio]{images/kisi/RecipeView.jpg}
        \caption{Rezepte-View}
        \label{rezepte-view} 
	\end{minipage}
	\hfill
    \begin{minipage}{\mypicWidth\textwidth}
        \includegraphics[width=\textwidth, keepaspectratio]{images/kisi/RecipeView2.jpg}
        \caption{Rezepte-View2}
        \label{rezepte-view2} 
	\end{minipage}
\end{figure}

# Rezepte erstellen

Grundsätzlich werden Rezepte auf die selbe Art wie Einkaufslisten erstellt. Der einzige
Unterschied ist, dass man bei Rezepten eine Beschreibung hinzufügen kann. Für das Suchen und 
Hinzufügen von Produkten wurde deshalb auch das selbe Widget, das auch bei den Einkaufslisten
verwendet wird, eingesetzt.

\needspace{10cm}

# Rezepte bearbeiten

Rezepte lassen sich natürlich beliebig bearbeiten und löschen. Klickt der User auf das "Zutaten" `ListTile`, gelangt
er zum `SearchItemsView`, wo Produkte hinzugefügt und entfernt werden können. 

\begin{lstlisting}[language=Dart]
ListTile(
    title: Text(
        "Zutaten",
        style: TextStyle(
            color: recipes[index].items.length > 0 
            ? Colors.black 
            : Colors.red,
        ),
    ),
    subtitle: Text(
        recipes[index].items.length > 0 
            ? getItemsAsString(recipes[index].items) 
            : "Keine Zutaten hinzugefügt",
        style: TextStyle(
            color: recipes[index].items.length > 0 
                ? Colors.grey 
                : Colors.red,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
    ),
)
\end{lstlisting}