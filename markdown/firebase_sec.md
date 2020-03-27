\newcommand\picWidth{0.33}

# Allgemein

Zum Speichern der Daten wird Cloud-Firestore verwendet.
Zusätzlich werden für das Speichern der Profilbilder und eingescannten Rechnungen
Cloud-Storage und für einige Funktionen, die serverseitig ausgeführt
werden müssen, Cloud-Functions verwendet. 

Um zu bewerkstelligen, dass die Daten auf der Clientseite in Echtzeit
aktualisiert werden, war Firebase die leichteste Variante. Mit Firebase ist
es mithilfe von Streams leicht möglich, Updates in der Datenbank in Echtzeit
auf der Clientseite zu registrieren. Um Gebrauch von den Echtzeit-Updates zu
machen werden einige von Google zur Verfügung gestellte Bibliotheken benutzt.

Bei den Cloud-Functions gibt es ein kleines Problem. Um Ressourcen zu schonen werden
die Cloud-Functions "heruntergefahren". Das bedeutet, wenn die Funktion nach einiger Zeit
aufgerufen wird, wird ein "cold start" durchgeführt. Dieser benötigt eine gewissen Zeit,
wodurch der Benutzer beim ersten Ausführen der Cloud-Function ein paar Sekunden warten muss.
Wird die Cloud-Function jedoch regelmäßig benutzt, sollte dies nicht mehr der Fall sein (\vgl\cite{cloud-function-slow}).

Um die Daten in Flutter auszulesen wird die `cloud_firestore`\footnote{\url{https://pub.dev/packages/cloud_firestore}}
Bibliothek benutzt. Dadurch können sehr leicht Daten aus Firestore ausgelesen bzw. dort gespeichert werden. Um
diese Funktionalitäten in der App verwenden zu können, wurde ein Service, `services/db.dart`, dafür erstellt. Generell
kann mit `.collection(COLLECTION)` die Collection COLLECTION ausgelesen und mit `.document(DOCUMENTID)` das Dokument
DOCUMENTID dieser Collection ausgelesen werden.

\needspace{0.5\textheight}
# Firestore Datenstruktur

## Benutzer

Die `users` Collection verwendet als Dokument-ID einen zufällig generierten String, 
der 28 Zeichen lang ist. Zusätzlich wird dieser generierte String auch in das Feld `uid`
eingetragen. Das Feld `displayName` speichert den Anzeigenamen des Benutzers. Das Feld 
`photoURL` speichert die URL zu dem Profilbild des Benutzers. In `settings` werden alle 
Einstellungen gespeichert. Das Feld `last_automatically_generated` ist für die automatische
Einkaufsliste wichtig, um das vom Benutzer eingestellte Intervall einzuhalten.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/users.png}
\caption{Users Collection}
\label{usersCollection}
\end{figure}

\needspace{0.3\textheight}
### Lists-Subcollection

Die `lists` Subcollection beinhaltet Informationen wie das Datum der Erstellung, den Namen,
den Typ, ob es sich um eine abgeschlossene (completed) oder offene (pending) handelt, und
ein Array der Produkte. Pro Produkt werden Name, Preis, Kategorie, Anzahl und der Status.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/lists.png}
\caption{Lists Collection}
\label{listsCollection}
\end{figure}

\needspace{0.3\textheight}
### Shopping_data-Subcollection 

Die `shopping_data` Subcollection hat nur ein Dokument namens `data`. Dieses Dokument enthält
ein Feld `last`, das mehrere Maps beinhaltet. Diese Maps sind eine reduzierte Version einer
`list`, wie oben beschrieben, und beinhalten nur den Zeitpunk des Abschließens und die Produkte
als Array. Bei den Produkten wird das Feld `bought` nicht mitgespeichert, da sowieso nur gekaufte
Produkte gespeichert werden.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/shopping_data.png}
\caption{Shopping\_data Collection}
\label{shoppingDataCollection}
\end{figure}

\needspace{0.3\textheight}
### Recipe-Subcollection 

Die `recipe` Subcollection ist ähnlich aufgebaut wie die `lists` Subcollection, mit dem Unterschied,
dass keine Typ und Erstelldatum, dafür aber eine Beschreibung, gespeichert werden. Die Produkte im
`products` Array sind gleich Aufgebaut wie bei der `lists` Subcollection.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/recipes.png}
\caption{Recipes Collection}
\label{recipesCollection}
\end{figure}

\needspace{0.3\textheight}
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

\needspace{0.3\textheight}
## Beziehung der Benutzer zu den Gruppen

Welcher Benutzer in welchen Gruppen ist wird in der `groups_user` Collection gespeichert. Als Dokument-ID
verwendet sie die `uid` des Benutzers. In den jeweiligen Dokumenten gibt es nur ein `groups` Feld, welches
die IDs der Gruppen beinhaltet, denen der Benutzer angehört. Die ID der Gruppe ist die zufällig generierte
Dokument-ID der Gruppe.

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/groups_user.png}
\caption{Groups\_user Collection}
\label{groupsUserCollection}
\end{figure}

\needspace{0.3\textheight}
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

\needspace{0.3\textheight}
## Beliebte Produkte

Die `popular_products` Collection hat nur ein Dokument namens `products`. Dieses Dokument enthält
ein Feld `products`, das mehrere Maps beinhaltet. Diese Maps speichern sowohl die Kategorie als auch
den Namen des Produktes. 

\begin{figure}[H]
\centering
\includegraphics[width=\picWidth\textwidth, keepaspectratio]{images/seczer/popular_products.png}
\caption{Popular\_products Collection}
\label{popularProductsCollection}
\end{figure}

\needspace{0.3\textheight}
# Storage Datenstruktur

Die Struktur der Storage ist sehr simpel aufgebaut. Für Benutzer müssen nur Profilbilder und eingescannte
Rechnungen abgespeichert werden und für Gruppen nur die eingescannten Rechnungen. Es gibt zwei Ordner, `users` und
`groups`. Jeder dieser Ordner hat als Unterordner Ordner, die nach den IDs der Benutzer bzw. der Gruppen benannt 
sind. Diese Ordner beinhalten noch einen Unterordner namens `lists`. Zusätzlich zu dem `lists` Ordner wird bei den
Benutzern auch noch das Profilbild `profile-picture.png` gespeichert. Der Ordner `lists` enthält wiederum Ordner 
die nach den IDs der Listen benannt sind. Darin befinden sich die eingescannten Rechnungen im Format 
`YYYY-MM-DD HH:MM:SS.MS.png` bzw. `DateTime.now()` mit der Endung png.