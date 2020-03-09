# Allgemein
Firebase selbst kann als ein "Serverloses" System bezeichnet werden. Das Frontend (die App), kommuniziert direkt zu der Firestore Datenbank als auch zur Firebase Storage. Das heißt, dass jeder im Internet unseren Firestore Endpunkt erreichen kann als auch Daten hochladen und runterladen kann.

# Security Rules
Die Lösung seitens Firebase, sind Security Rules. Bevor eine Abfrage oder Anfrage auf die Firestore Datenbank ausgeführt wird, werden die Security Rules abgefragt, ob diese Aktion auch wirklich zulässig ist. Die Authentizierung, falls eine vorhanden ist, kann unter dem Objekt `request.auth` gefunden werden.

Um zum Beispiel nur dem eigenem User Zugriff auf sein Profil zu geben, kann folgende Regel verwendet werden

```java
match /users/{userId} {
    allow update: if isOwner(userId) && same("uid");
    allow create: if isOwner(userId) && !userDocExists() && isOwner(futureDocument().uid);
    allow get: if isOwner(userId);
}

function isOwner(userId) {
    return request.auth.uid == userId && isSignedIn();
}
```
