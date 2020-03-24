#   Allgemein

Die Einstellungen bestehen aus fünf Hauptkategorien, nämlich den Konto Einstellungen, den App Einstellungen, dem 
Datenschutz Bereich, dem "Fehler melden" Bereich und dem Info Bereich. Anfangs gab es noch eine sechste Kategorie,
die Benachrichtigungseinstellungen, da jedoch die Implementierung von App Benachrichtigungen (z.B. bei Einaldungen in
eine Gruppe) sehr zeitaufwendig gewesen wäre und diese kein Hauptziel darstellte, wurde sie nicht umgesetzt.

Die Buttons "Datenschutz" und "Info" führen auf die Projektwebseite und der "Fehler melden" Button führt auf das Git Repository.
Das `url_launcher`\footnote{\url{https://pub.dev/packages/url_launcher}} Package wurde zum Öffnen der Webseiten im Browser verwendet.

\begin{lstlisting}[language=Dart]
ListTile(
    leading: Icon(Icons.info),
    title: Text('Info'),
    trailing: Icon(Icons.keyboard_arrow_right),
    onTap: () => {
        _launchURL("https://listassist.gq")
    },
),
\end{lstlisting}

In der rechten oberen Ecke befindet sich außerdem, genau wie in der Sidebar, ein Abmeldebutton.

\needspace{10cm}

#	Konto Einstellungen

Alle Benutzer können ihren Anzeigenamen ändern. Weiters können Benutzer, die sich mit Email und Passwort registriert
haben, ihre Email, ihr Passwort und ihr Profilbild ändern. Um die Email oder das Passwort eines Benutzers zu ändern,
muss dieser sich vor Kurzem eingeloggt haben. Deshalb wird der Benutzer aufgefordert sein Passwort einzugeben.

\begin{lstlisting}[language=Dart]
var user = firebase.auth().currentUser;
var credential;

// Prompt the user to re-provide their sign-in credentials

user.reauthenticateWithCredential(credential).then(function() {
  // User re-authenticated.
}).catch(function(error) {
  // An error happened.
});
\end{lstlisting}

Um das `AuthCredential` zu bekommen wird folgendes verwendet:
\begin{lstlisting}[language=Dart]
AuthCredential credential = EmailAuthProvider.getCredential(email: currentEmail, password: password);
\end{lstlisting}


#	App Einstellungen

In den App Einstellungen hat der Benutzer die Möglichkeit den Camera Scanner auf den manuellen oder den automatischen
Modus zu stellen. Der manuelle Modus lässt den Benutzer nach erfolgreichem Scan aus allen erkannten Produkten, die 
richtigen herausfiltern. Der automatische Modus vergleicht alle erkannten Produkte mit den Produkten auf der Einkaufsliste.

Ebenfalls lässt sich in den App Einstellungen die Automatische Einkaufsliste aktivieren und deaktivieren. Weiters kann man auch
das Intervall der automatischen Einkaufsliste festlegen.

#   Hero Animation

Um die App lebhafter zu gestalten und den Übergang von der Sidebar zum `SettingsView` geschmeidiger zu machen wurde beim 
Navigieren eine Hero Animation eingefügt. Eine Hero Animation oder auch "shared element transition" genannt, animiert ein 
Element beim Viewwechsel von der alten zur neuen Position.

Die Implementation war simpel. Es mussten nur die `CircleAvatar` Widgets in der `Sidebar` und im `SettingsView` mit dem 
`Hero` Widget umschlossen werden. Außerdem musste beiden `Hero` Widgets der selbe Tag zugeordnet werden.


Anwendung in der `Sidebar` und im `SettingsView`:
\begin{lstlisting}[language=Dart]
Hero(
    tag: "profilePicture",
    child: CircleAvatar(
        backgroundImage: NetworkImage(user.photoUrl),
    ),
)
\end{lstlisting}



