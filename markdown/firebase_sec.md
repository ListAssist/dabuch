\newcommand\picWidth{0.33}

# Allgemein

Zum Speichern der Daten wird Cloud Firestore \cite{firestore} verwendet.
Zusätzlich werden für das Speichern der Profilbilder und eingescannten Rechnungen
Cloud Storage \cite{storage} und für einige Funktionen, die serverseitig ausgeführt
werden müssen, Cloud Functions \cite{cloudFunctions} verwendet. 

Um zu bewerkstelligen, dass die Daten auf der Clientseite in echtzeit
aktualisiert werden, war Firebase die leichteste Variante. Mit Firebase ist
es mithilfe von Streams leicht möglich, Updates in der Datenbank in echtzeit
auf der Clientseite zu registrieren. Um Gebrauch von den Echtzeit-Updates zu
machen werden einige von Google zur Verfügung gestellte Bibliotheken benutzt.

# Firestore Datenstruktur

## Benutzer

Die `users` Collection verwendet als Dokument-ID einen zufällig generierten String, 
der 28 Zeichen lang ist. Zusätzlich wird dieser generierte String auch in das Feld `uid`
eingetragen. <!--Die uid wird auch für die Gruppen und Einladungen verwendet.--> Das Feld
`displayName` speichert den Anzeigenamen des Benutzers. <!--Meldet sich der Benutzer via
eine Social Media Plattform so wird der Anzeigename der Social Media Plattform verwendet.-->
Das Feld `photoURL` speichert die URL zu dem Profilbild des Benutzers. In `settings`
werden alle Einstellungen gespeichert. Das Feld `last_automatically_generated` ist für die
automatische Einkaufsliste wichtig, um das vom Benutzer eingestellte Intervall einzuhalten.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/users.png}
\caption{Users Collection}
\label{usersCollection}
\end{figure}

## Gruppen

Auch die `groups` Collection verwendet als Dokument-ID einen zufällig generierten String, 
der 28 Zeichen lang ist. Anders als bei den Benutzern wird dieser nicht zusätzlich in einem Feld
gespeichert. Die Maps von den Feldern `members` und `creator` sind leicht abgeänderte Benutzer-Elemente.
Es werden nur `displayName`, `photoURL` und `uid` gespeichert.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/groups.png}
\caption{Groups Collection}
\label{groupsCollection}
\end{figure}

### Beziehung zum Benutzer

Welcher Benutzer in welchen Gruppen ist wird in der ``groups_user` Collection gespeichert.Als Dokument-ID
verwendet sie die `uid` des Benutzers. In den jeweiligen Dokumenten gibt es nur ein `groups` Feld, welches
die IDs der Gruppen beinhaltet, denen der Benutzer angehört. Die ID der Gruppe ist die zufällig generierte
Dokument-ID der Gruppe.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/groups_user.png}
\caption{Groups\_user Collection}
\label{groupsUserCollection}
\end{figure}

## Einladungen

Die `invites` Collection verwendet als Dokument-ID ebenfalls einen zufällig generierten String, 
der 28 Zeichen lang ist. Das Feld `groupid` beinhaltet die ID der Gruppe, in die der Benutzer eingeladen
wurde. Passend zu der `groupid` wird auch der Name der Gruppe in `groupname` gespeichert.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/invites.png}
\caption{Invites Collection}
\label{invitesCollection}
\end{figure}

\needspace{10cm}
## Beliebte Produkte

Die `popular_products` Collection hat als nur ein Dokument namens `products`. Dieses Dokument enthält
ein Feld `products`, das mehrere Maps beinhaltet. Diese Maps speichern sowohl die Kategorie als auch
den Namen des Produktes. 

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/popular_products.png}
\caption{Popular\_products Collection}
\label{popularProductsCollection}
\end{figure}

# Storage Datenstruktur

Die Struktur der Storage ist sehr simpel aufgebaut. Für Benutzer müssen nur Profilbilder und eingescannte
Rechnungen abgespeichert werden und für Gruppen nur die eingescannten Rechnungen. Es gibt zwei Ordner, `users` und
`groups`. Jeder dieser Ordner hat als Unterordner Ordner, die nach den IDs der Benutzer \todo{Darf man bzw. schreiben?}
bzw. der Gruppen benannt sind. Diese Ordner beinhalten noch einen Unterordner namens `lists`. Zusätzlich zu dem `lists`
Ordner wird bei den Benutzern auch noch das Profilbild `profile-picture.png` gespeichert. Der Ordner `lists`
enthält wiederum Ordner die nach den IDs der Listen benannt sind. Darin befinden sich die eingescannten Rechnungen
im Format `YYYY-MM-DD HH:MM:SS.MS.png` bzw. `DateTime.now()` mit der Endung png.