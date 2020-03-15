# Allgemein

Die Gruppen funktionieren wie alles andere auch in Echtzeit. Da die Firestore Security Rules
keine komplizierteren Sachen, wie zum Beispiel überprüfen, ob ein User in einem Array vorhanden
ist um die Gruppe zu bearbeiten, wurden Updates/Creates mit Cloud-Functions geregelt. Dadurch hat
man eine bessere Kontrolle. 

# Gruppen des Benutzers streamen

<!-- EVTL SIDEBAR AUCH SCHREIBEN -->
Die Gruppen des Benutzers werden als ein Stream vom Typ `List<Group>` bereitgestellt. Dafür ist es
notwendig, die Gruppen, in denen der Benutzer ist, aus `groups_user` auszulesen und die eingetragenen
GruppenIDs als Liste zu streamen. Dafür wurde folgender Code verwendet:

\begin{lstlisting}[language=Dart]
return Observable(_db
  .collection("groups_user")
  .document(uid)
  .snapshots()).switchMap((DocumentSnapshot snap) {
      //Sollte der User in keinen Gruppen
      //sein oder das Dokument nicht existieren
      //eine leere Liste zurückgegeben
      if(snap.data == null || 
          snap.data["groups"] == null || 
          snap.data["groups"].length == 0){
          return Stream.value(List<Group>.from([]));
      }
      return _db
          .collection("groups")
          .where(FieldPath.documentId, whereIn: snap.data["groups"])
          .snapshots()
          .map((snap) => 
            snap.documents.map((d) => 
                Group.fromFirestore(d)
            ).toList()
        );
      });
\end{lstlisting}

\needspace{5cm}
Wichtig ist dabei dieser Teil: `.where(FieldPath.documentId, whereIn: snap.data["groups"])`. Durch das
`whereIn` werden alle Dokumente geladen, die in dem Array von `snap.data["groups"]` vorhanden sind. Diese
Funktionalität wurde jedoch erst im Laufe der Durchführung hinzugefügt. Deswegen wurde zu Beginn nur eine 
Gruppe geladen, später als diese Funktionalität hinzugefügt wurde, wurde dann die Liste der Gruppen gestreamt.

Zudem wurde kein Dart-Stream verwendet, sondern ein Observable von `rxdart`. Das hat den Vorteil, dass
mit der `switchMap` Methode der Datentyp des Stream geändert werden kann, was mit einem normalen `map` vom
Dart-Stream nicht möglich ist.

# Einkaufslisten in Gruppen

Zuerst gab es für Gruppen eigene Widgets, die ähnlich aufgebaut waren wie die der einzelnen
Benutzer. Dadurch mussten aber Änderungen, die bei den Widgets des einzelnen Benutzers gemacht wurden,
auch in die Widgets der Gruppen kopiert werden. Deswegen, da es bereits die Widgets gab, wurden diese
einfach wiederverwendet. Das erspart sowohl die erneute Programmierung des Widgets
als auch Probleme mit der Einheitlichkeit, da man bei einer Änderung beide Widgets
wieder anpassen müsste. Die einzigen Änderungen waren ein Parameter, der angibt ob es sich um eine
Gruppe handelt und, falls es sich um eine Gruppe handelt, wurde die `uid` durch die Gruppen-ID ersetzt
und die Liste musste anders geladen bzw. weitergegeben werden. Das gleiche Prinzip wurde
auch für die erledigten Einkäufe verwendet. 

# Übersicht der Benutzer in einer Gruppe

Die Liste der Benutzer einer Gruppe ist ein Array von Maps, die den Namen, eine UID und eine 
URL für das Profilbild enthalten. Mit der "map" methode werden aus den einzelnen Maps Widgets
erstellt. Die Darstellung ist ein einfaches "Row" Widget mit einem Profilbild vorne, und dem Namen
nach dem Profilbild. Falls ein Benutzer keine URL für ein Profilbild besitzt oder während das Bild lädt,
wird ein selbst erstelltes Standard Profilbild angezeigt. Da der Besitzer der Gruppe ebenfalls in der Liste
der Mitglieder ist, wird der Besitzer vor dem "mappen" entfernt und er bekommt eine etwas andere Darstellung,
nämlich mit einem grünen "Gruppenersteller" nach seinem Namen. Sollte der Name zu lang sein um ihn richtig
darzustellen, wird mittels der Einstellung `overflow: TextOverflow.ellipsis` der Text gekürzt und mit ...
am Ende dargestellt.

# Gruppe bearbeiten

Der Ersteller der Gruppe kann diese auch bearbeiten. Das beinhaltet das Umbenennen der Gruppe, das
Entfernen von Benutzern aus der Gruppe und das Einstellen ob und wie oft eine automatische
Einkaufsliste erstellt werden soll. Das aktualisierte Gruppen-Objekt wird dann einer Cloud-Function
übergeben. Dort werden dann der Name, die Einstellungen und die aktualisierte Mitgliederliste
auf in die Gruppe hochgeladen. Die entfernten Benutzer werden im `members` Array entfernt und
die Gruppen-ID wird aus dem Dokument des Benutzers in `groups_user` entfernt.

# Gruppe löschen

Eine Gruppe kann nur vom Ersteller gelöscht werden. Wenn die Gruppe gelöscht wird, werden
auch die Subcollections der Gruppe, `lists` und `shopping_data`, gelöscht. Außerdem wird
die Gruppe bei jedem Benutzer der in der Gruppe war aus dem Dokument von `groups_user` gelöscht.

# Gruppe verlassen

Jedes Mitglied einer Gruppe kann diese natürlich auch verlassen. In diesem Fall wird der Benutzer aus
dem `members` Array entfernt und die Gruppen-ID aus dem `groups_user` Dokument des Users entfernt. Eine
Ausnahme ist der Ersteller der Gruppe. Wenn dieser die Gruppe verlässt, wird zusätzlich der nächste 
Benutzer im `members` Array als `creator` eingetragen. Sollte der Ersteller der Gruppe das letzte Mitglied
der Gruppe sein, wird die Gruppe inklusive Subcollections gelöscht.