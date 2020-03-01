# Allgemein

Die Gruppen funktionieren wie alles andere auch in Echtzeit. Da die Firestore Security Rules
keine komplizierteren Sachen, wie zum Beispiel überprüfen, ob ein User in einem Array vorhanden
ist um die Gruppe zu bearbeiten, wurden Updates/Creates mit Cloud-Functions geregelt. Dadurch hat
man eine bessere Kontrolle. 

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