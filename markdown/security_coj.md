# Allgemein
Firebase selbst kann als ein "Serverloses" System bezeichnet werden. Das Frontend (die App), kommuniziert direkt zu der Firestore Datenbank als auch zur Firebase Storage. Das heißt, dass jeder im Internet unseren Firestore Endpunkt erreichen kann als auch Daten hochladen und runterladen kann. Ohne Regeln geben wir dem Internet vollen Lese- als auch Schreibezugriff auf unsere Datenbank.

# Security Rules
Die Lösung seitens Firebase, sind Security Rules. Bevor eine Abfrage auf die Firestore Datenbank stattfindet, werden die Security Rules abgefragt, um zu prüfen ob diese Aktion auch wirklich zulässig ist. Die Authentizierung, falls eine vorhanden ist, kann unter dem Objekt `request.auth` gefunden werden.

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

Außerdem muss Zugriff auf die einzelnen Subcollections `lists`, `recipes` und `shopping_data` gewährt werden. Zu beachten ist hier auch noch, dass ein Nutzer in der `shopping_data` Subcollection nur Zugriff auf das Dokument `data` hat.

```java
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
```

## Group Collections
Die Gruppen Collection ist in zwei Teile getrennt worden, um die Komplexität im Frontend als auch bei den Security Rules zu mindern.

### Group Collection
Hier ist die Idee, dass nur User auf eine bestimmte Gruppe zugreifen dürfen, welche die ID der angeforderten Gruppe in ihrem `groups_user` Dokument stehen haben. 

```java
// Only allow user to read groups in which he is present
match /groups/{groupId}/{document=**} {
    allow read: if groupId in getDoc("groups_user", currentUser().uid).groups;
}

```

Weiters, soll nur der Ersteller der Gruppe Zugriff auf Aktionen wie Einstellungen oder die Löschung haben. Den Ersteller finden wir im `creator` Feld des Dokumentes. Außerdem muss geprüft werden, ob der `creator` als auch die `members` nach einem Update nicht geändert werden.
```java

match /groups/{groupId} {
    allow create: if isOwner(futureDocument().creator.uid)
    && futureDocument().members == null;
    allow update: if isOwner(currentDocuemnt().creator.uid) && same("creator") && same("members");
    allow delete: if isOwner(currentDocuemnt().creator.uid);
}

```

Zuletzt muss auf die Subcollections `lists` und `shopping_data` voller Zugriff gewährt werden, für Nutzer die sich in der Gruppe befinden. Zu beachten ist, dass ein Nutzer in der `shopping_data` Subcollection nur Zugriff auf das Dokument `data` hat.

```java
match /groups/{groupId}/lists/{document=**} {
    allow create, update, delete: if groupId in getDoc("groups_user", currentUser().uid).groups;
}

match /groups/{groupId}/shopping_data/data {
    allow create, update, delete: if groupId in getDoc("groups_user", currentUser().uid).groups;
}
```

### Group Lookup
Wie bereits erklärt \siehe{beziehung-der-benutzer-zu-den-gruppen}, gibt es eine Lookup-Collection für die User, in welcher gespeichert wird, in welcher Gruppe man sich befindet.

Hier ist es wichtig **nur** Lesezugriff zu vergeben, da ansonsten der User sich selbst in Gruppen hinzufügen kann.

```java
match /groups_user/{userId} {
    allow read: if isOwner(userId);
}
```

## Invites Collection
Da die Invites über eine Cloud Function gemanaged werden, und dort validiert werden, wird für die Invites Collection nur Lesezugriff für den eingeladenen Nutzer erlaubt.

```java
match /invites/{inviteId} {
    allow read: if isOwner(currentDocument().to);
}
```

## Popular Products Collection
Hier ist auch nur Lesezugriff verfügbar, da User hier keine Änderungen vornehmen dürfen.

```java
match /popular_products/{productId} {
    allow read;
}
```