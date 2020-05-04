# Allgemein
Firebase selbst kann als ein "Serverloses" System bezeichnet werden. Das Frontend (die App), kommuniziert direkt zur Firestore Datenbank. Das heißt, dass jeder im Internet unseren Firestore Endpunkt erreichen als auch Daten hochladen und runterladen kann. Würden keine Regeln existieren, würden wir dem Internet vollen Lese- und auch Schreibezugriff auf unsere Datenbank ermöglichen.

# Security Rules
Die Lösung seitens Firebase sind Security Rules. Bevor eine Abfrage auf die Firestore Datenbank stattfindet, werden die Security Rules abgefragt, um zu prüfen ob diese Aktion auch wirklich zulässig ist. Die Authentizierung, falls vorhanden, kann unter dem Objekt `request.auth` gefunden werden.

## Funktionshilfen
Um den Code lesbarer, als auch schöner zu schreiben, wurden Funktionen erstellt, welche über den Namen schnell vermitteln sollen, was diese bewirken.

Folgende Funktionen wurden hinzugefügt:


\begin{lstlisting}[language=Dart]
// Check if user is an owner of the document
function isOwner(userId) {
    return request.auth.uid == userId && isSignedIn();
}
// Check if the user is even signed in
function isSignedIn() {
    return request.auth != null;
}
// Check if a property on a document has changed or stayed the same
function same(property) {
    return currentDocument()[property] == futureDocument()[property];
}
// Check if an user document already exists
function userDocExists() {
    return exists(/databases/$(database)/documents/users/$(currentUser().uid));
}
\end{lstlisting}

## User Collection
Als Beispiel kann die `users` Collection genommen werden. Folgende Regeln gelten:

* Als Grundregel gilt, dass ein Nutzer nur auf sein eigenes Dokument zugreifen darf.
* Änderungen sind nur erlaubt, wenn das `uid` Feld gleich bleibt.
* Das Dokument darf nur erstellt werden, wenn das Dokument nicht bereits existiert und das `uid` Feld dem derzeitigem Nutzer entspricht.

\begin{lstlisting}[language=Dart]
match /users/{userId} {
    allow update: if isOwner(userId) && same("uid");
    allow create: if isOwner(userId) && !userDocExists() 
                  && isOwner(futureDocument().uid);
    allow get: if isOwner(userId);
}
\end{lstlisting}

Außerdem muss Zugriff auf die einzelnen Subcollections `lists`, `recipes` und `shopping_data` gewährt werden. Zu beachten ist hier auch noch, dass ein Nutzer in der `shopping_data` Subcollection nur Zugriff auf das Dokument `data` hat.

\begin{lstlisting}[language=Dart]
match /users/{userId}/{document=**} {
    allow read: if isOwner(userId);
}

match /users/{userId}/lists/{listId} {
    allow create: if isOwner(userId);
    allow update, delete: if isOwner(userId);
}

match /users/{userId}/recipes/{recipeId} {
    allow create: if isOwner(userId);
    allow update, delete: if isOwner(userId);
}

match /users/{userId}/shopping_data/data {
    allow create: if isOwner(userId);
    allow update, delete: if isOwner(userId);
}
\end{lstlisting}

## Group Collections
Die Gruppen Collection ist in zwei Teile getrennt worden, um die Komplexität sowohl Frontend als auch bei den Security Rules zu mindern.

### Group Collection
Hier ist die Idee, dass nur User auf eine bestimmte Gruppe zugreifen dürfen, welche die ID der angeforderten Gruppe in ihrem `groups_user` Dokument stehen haben. 

\begin{lstlisting}[language=Dart]
// Only allow user to read groups in which he is present
match /groups/{groupId}/{document=**} {
    allow read: if groupId in getDoc("groups_user", currentUser().uid).groups;
}
\end{lstlisting}

Weiters soll nur der Ersteller der Gruppe Zugriff auf Aktionen wie Einstellungen oder die Löschung haben. Den Ersteller finden wir im `creator` Feld des Dokumentes. Außerdem muss geprüft werden, ob der `creator` und die `members` nach einem Update nicht geändert werden.

\begin{lstlisting}[language=Dart]
match /groups/{groupId} {
    allow create: if isOwner(futureDocument().creator.uid)
    && futureDocument().members == null;
    allow update: if isOwner(currentDocument().creator.uid) && same("creator") && same("members");
    allow delete: if isOwner(currentDocument().creator.uid);
}
\end{lstlisting}


Zuletzt muss auf die Subcollections `lists` und `shopping_data` voller Zugriff gewährt werden, für Nutzer die sich in der Gruppe befinden. Zu beachten ist, dass ein Nutzer in der `shopping_data` Subcollection nur Zugriff auf das Dokument `data` hat.

\begin{lstlisting}[language=Dart]
match /groups/{groupId}/lists/{document=**} {
    allow create, update, delete: if groupId in getDoc("groups_user", currentUser().uid).groups;
}

match /groups/{groupId}/shopping_data/data {
    allow create, update, delete: if groupId in getDoc("groups_user", currentUser().uid).groups;
}
\end{lstlisting}

### Group Lookup
Wie später noch erklärt wird (\siehe{beziehung-der-benutzer-zu-den-gruppen}), existiert eine Lookup-Collection für User, in welcher gespeichert wird, in welcher Gruppe man sich befindet.

Hier ist es wichtig, **nur** Lesezugriff zu vergeben, da sich ansonsten der User selbst in Gruppen hinzufügen kann.

\begin{lstlisting}[language=Dart]
match /groups_user/{userId} {
    allow read: if isOwner(userId);
}
\end{lstlisting}

## Invites Collection
Da die Invites über eine Cloud Function verwaltet und dort validiert werden, wird für die Invites Collection nur Lesezugriff für den eingeladenen Nutzer erlaubt.

\begin{lstlisting}[language=Dart]
match /invites/{inviteId} {
    allow read: if isOwner(currentDocument().to);
}
\end{lstlisting}

## Popular Products Collection
Hier ist auch nur Lesezugriff verfügbar, da User hier keine Änderungen vornehmen dürfen.

\begin{lstlisting}[language=Dart]
match /popular_products/{productId} {
    allow read;
}
\end{lstlisting}
