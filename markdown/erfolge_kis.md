# Allgemein

Benutzer können Erfolge sammeln, indem sie die verschiedenen Funktionen der App benutzen. 
Ein Erfolg wäre zum Beispiel das Erstellen von 50 Einkaufslisten.

\begin{figure}[H]
\centering
\includegraphics[height=0.5\textheight, keepaspectratio]{images/kisi/AchievementsView.jpg}
\caption{Erfolge}
\label{erfolge}
\end{figure}

# Listenansicht der freigeschalteten Erfolge

Alle vom Benutzer freigeschalteten Erfolge werden in einer Listenansicht dargestellt.
Jeder einzelne Erfolg ist ein `ListTile`, welches sich in einer `Card` befindet.
Die Liste wird mit dem `ListView.builder` Widget umgesetzt. Direkt unter der `AppBar` 
wird dem Benutzer, mithilfe des `percent_indicator`\footnote{\url{https://pub.dev/packages/percent_indicator}} 
Packages angezeigt, wie viele Erfolge schon freigeschaltet wurden. Diese 
Fortschrittsanzeige und der `ListView` befinden sich in einem `Column` Widget, wobei 
das `ListView` Widget noch zusätzlich von einem `Expanded` Widget umschlossen werden muss,
da es sonst zu einer Viewport Exception kommt.

\begin{lstlisting}[language=Dart]
/* Fortschrittsanzeige der Erfolge */
Text(
    _achievements.length.toString() + " / 20 Erfolge freigeschaltet"),
),
LinearPercentIndicator(
    padding: EdgeInsets.only(top: 20, left: 50, right: 50),
    lineHeight: 8.0,
    percent: _achievements.length/20,
    progressColor: Colors.blueAccent,
),
\end{lstlisting}

\begin{lstlisting}[language=Dart]
/* Liste der freigeschalteten Erfolge */
Expanded(
    child: ListView.builder(
        itemCount: _achievements.length,
        itemBuilder: (BuildContext context, int index) {
            return Card(
                color: Colors.green,
                child: ListTile(
                    title: Text(_achievements[index].name),
                    subtitle: Text(_achievements[index].description),
                    trailing: Text(_achievements[index].points),
                ),
            );
        },
    ),
),
\end{lstlisting}

# Datenbank

In Firebase werden die Erfolge im `achievements` Array im User Dokument gespeichert.
Ein `Achievement` besitzt einen Namen, eine Beschreibung, wie der Erfolg freischaltet wird
und eine Punkteanzahl, die den Schwierigkeitsgrad des Erfolgs angibt und 10 bis 100 Punkte betragen 
kann. Insgesamt gibt es 20 Erfolge, die freigeschaltet werden können. 

Da bei manchen Erfolgen, zum Beispiel die Anzahl der vom Benutzer erstellten Einkaufslisten, 
mitgezählt werden muss gibt es in Firebase die `stats` Map, in welcher alle benötigten Werte 
gespeichert werden. 

Das `AchievementsService` beinhaltet alle Methoden, mit denen die `stats` mitgezählt werden. Falls der 
Benutzer einen Erfolg freischaltet wird die `addAchievement` Funktion aufgerufen, welche die Änderung in der 
Datenbank erledigt und zusätzlich den Benutzer per `SnackbarWidget` auf den freigeschalteten Erfolg aufmerksam macht.

Im `AchievementsService`:
\begin{lstlisting}[language=Dart]
groupCreated(User user) {
    if (user.stats["groups_created"] != null) {
      user.stats["groups_created"] += 1;
    } else {
      /* User hat zum ersten Mal eine Gruppe erstellt */
      user.stats["groups_created"] = 1;
      databaseService.addAchievement(user.uid, achievements["gruppenersteller"]);
    }
    databaseService.updateUserStats(user.uid, user.stats);
}
\end{lstlisting}

\needspace{10cm}

