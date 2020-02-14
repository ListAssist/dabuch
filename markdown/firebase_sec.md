\newcommand\outerWidth{0.35}
\newcommand\innerWidth{0.28}

# Allgemein

Um zu bewerkstelligen, dass die Daten auf der Clientseite in echtzeit
aktualisiert werden, was Firebase die leichteste Variante. Mit Firebase ist
es mithilfe von Streams leicht möglich, Updates in der Datenbank in echtzeit
auf der Clientseite zu registrieren. Um Gebrauch von den Echtzeit-Updates zu
machen werden einige von Google zur Verfügung gestellte Bibliotheken benutzt.

# Datenstruktur

## Benutzer

\begin{wrapfigure}{O}{\outerWidth\textwidth}
\begin{center}
\includegraphics[width=\innerWidth\textwidth, keepaspectratio]{images/seczer/users.png}
\end{center}
\caption{Users Collection\label{usersCollection}}
\end{wrapfigure}

Die `users` Collection verwendet als Dokument-ID einen zufällig generierten String, 
der 28 Zeichen lang ist. Zusätzlich wird dieser generierte String auch in das Feld `uid`
eingetragen. Die uid wird auch für die Gruppen und Einladungen verwendet. Das Feld
`displayName` speichert den Anzeigenamen des Benutzers. Meldet sich der Benutzer via
eine Social Media Plattform so wird der Anzeigename der Social Media Plattform verwendet.
Das gleiche gilt für das Feld `photoURL`, das die URL zu dem Profilbild angibt. In `settings`
werden alle Einstellungen gespeichert. Das Feld `last_automatically_generated` ist für die
automatische Einkaufsliste wichtig, um das vom Benutzer eingestellte Intervall einzuhalten.

\needspace{10cm}
## Gruppen

\begin{wrapfigure}{O}{\outerWidth\textwidth}
\begin{center}
\includegraphics[width=\innerWidth\textwidth, keepaspectratio]{images/seczer/groups.png}
\end{center}
\caption{Groups Collection\label{groupsCollection}}
\end{wrapfigure}

Auch die `groups` Collection verwendet als Dokument-ID einen zufällig generierten String, 
der 28 Zeichen lang ist. Anders als bei den Benutzern wird dieser nicht zusätzlich in einem Feld
gespeichert. Die Maps von den Feldern `members` und `creator` sind leicht abgeänderte Benutzer-Elemente.
Es werden nur `displayName`, `photoURL` und `uid` gespeichert.


## Einladungen

\begin{wrapfigure}{O}{\outerWidth\textwidth}
\begin{center}
\includegraphics[width=\innerWidth\textwidth, keepaspectratio]{images/seczer/invites.png}
\end{center}
\caption{Invites Collection\label{invitesCollection}}
\end{wrapfigure}

Die `invites` Collection verwendet als Dokument-ID ebenfalls einen zufällig generierten String, 
der 28 Zeichen lang ist. Das Feld `groupid` beinhaltet die ID der Gruppe, in die der Benutzer eingeladen
wurde. Passend zu der `groupid` wird auch der Name der Gruppe in `groupname` gespeichert.

<!-- \blindtext[2] -->