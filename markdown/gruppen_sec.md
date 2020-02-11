# Allgemein

# Einkaufslisten in Gruppen

Da bereits für die Einkaufslisten Widgets erstellt wurden, wurden diese
einfach wiederverwendet. Das erspart sowohl die erneute Programmierung des Widgets
als auch Probleme mit der Einheitlichkeit, da man bei einer Änderung beide Widgets
wieder anpassen müsste.

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

# Probleme

