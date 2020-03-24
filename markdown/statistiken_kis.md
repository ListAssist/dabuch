# Allgemein

Benutzer haben die Möglichkeit Statistiken über ihre Einkäufe, wie zum Beispiel
die meistgekauften Produkte oder die Ausgaben pro Produktkategorie, anzusehen. Hierbei 
werden logischerweise nur alle abgehakten `Item`s aller offenen und abgeschlossenen Einkaufslisten
berücksichtigt. Die Statistiken werden dank Firebase, bei Änderungen in der Datenbank, in Echtzeit 
aktualisiert.

# Diagramme

Um die benötigten Diagramme darzustellen wurde das Package `charts_flutter`\footnote{\url{https://pub.dev/packages/charts_flutter}} verwendet.
Das Package wurde von Google entwickelt und ermöglicht es die Daten im Material Design zu visualisieren.
Für die Statistik der am meisten gekauften Produkte wurde ein simples Balkendiagramm verwendet. Die maximale Anzahl
der Balken wurde auf 3 festgelegt um sicherzustellen, dass auch längere Produktnamen genügend Platz unter 
den Balken haben. Dies wurde mit der `sublist` Methode gelöst.

\begin{lstlisting}[language=Dart]
    /*  Falls die Liste der meistgekauften Produkte mehr 
        als 3 Items beinhaltet wird sie gekürzt */
    if (items.length > 3) items = items.sublist(0, 3);
\end{lstlisting}

\needspace{10cm}


\begin{figure}[H]
\centering
\includegraphics[height=0.5\textheight, keepaspectratio]{images/kisi/StatisticsView.jpg}
\caption{Statistiken}
\label{statistiken}
\end{figure}


Die Skalierung der Balken wird automatisch von `charts_flutter` gemacht. Da es bei schlechter Internetverbindung zu
Verzögerungen beim Laden der Daten kommen kann, wird, bei fehlenden Daten, ein Shimmer anstelle eines leeren Diagramms angezeigt.
Die `animate` Variable bewirkt bei `true`, dass das Diagramm beim Eintritt in das UI animiert wird.

\begin{lstlisting}[language=Dart]
    Column(
        children: <Widget>[
            Text(
                "Meistgekaufte Produkte",
                style: TextStyle(fontSize: 18),
            ),
            lists != null
                ? Container(
                    height: 250,
                    padding: EdgeInsets.all(20),
                    child: BarChart(
                        _getMostBoughtProductData(lists, completedLists),
                        animate: true,
                    ),
                )
                : ShoppyShimmer(),
        ]
    )
\end
