# Allgemein
Firebase selbst kann als ein "Serverloses" System bezeichnet werden. Das Frontend (die App), kommuniziert direkt zu der Firestore Datenbank als auch zur Firebase Storage. Das heißt, dass jeder im Internet unseren Firestore Endpunkt erreichen kann als auch Daten hochladen und runterladen kann.

# Security Rules
Die Lösung seitens Firebase, sind Security Rules. Bevor eine Abfrage oder Anfrage auf die Firestore Datenbank ausgeführt wird, werden die Security Rules abgefragt, ob diese Aktion auch wirklich zulässig ist. Die Authentizierung, falls eine vorhanden ist, kann unter dem Objekt `request.auth` gefunden werden.

## Funktionshilfen
Um den Code lesbarer, als auch schöner zu schreiben, wurden Funktionen erstellt, welche über den Namen schnell vermitteln sollen, was diese bewirken.

Folgende Funktionen wurden hinzugefügt:

```java
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
```

## User Collection
Als Beispiel kann die `users` Collection genommen werden. Folgende Regeln gelten:

* Als Grundregel gilt, dass ein Nutzer nur auf sein eigenes Dokument zugreifen darf.
* Änderungen sind nur erlaubt, wenn das `uid` Feld gleich bleibt.
* Das Dokument darf nur erstellt werden, wenn das Dokument nicht bereits existiert und wenn das `uid` Feld das vom derzeitigem Nutzer entspricht.

```java
match /users/{userId} {
    allow update: if isOwner(userId) && same("uid");
    allow create: if isOwner(userId) && !userDocExists() 
                  && isOwner(futureDocument().uid);
    allow get: if isOwner(userId);
}
```

## Group Collections
Die Gruppen Collection ist in zwei Teile getrennt worden, um die Komplexität im Frontend als auch bei den Security Rules zu mindern.

### Group Collection
```java
match /groups/{groupId}/{document=**} {
        allow read: if groupId in getDoc("groups_user", currentUser().uid).groups;
}

// Alle Dokumente in subcollection, welche in Gruppe ist
match /groups/{groupId}/lists/{document=**} {
    allow create, update, delete: if groupId in getDoc("groups_user", currentUser().uid).groups && hasEmailVerified()
}

// Alle Dokumente in subcollection, welche in Gruppe ist
match /groups/{groupId}/shopping_data/data {
    allow create, update, delete: if groupId in getDoc("groups_user", currentUser().uid).groups && hasEmailVerified()
}
```

### Group Lookup


