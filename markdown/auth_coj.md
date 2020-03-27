# Allgemein
Die Authentizierung ist ein sehr wichtiger Teil der Applikation, da sie die zwei größten Blöcke, die Authentizierung und die App selbst, von einander trennt. Um das Problem des Authentizierens zu lösen, wurde die `AuthService` Klasse erstellt.

\begin{figure}[H]
\centering
\includegraphics{images/coja/auth_puml.png}
\caption{Klassendiagramm der AuthService und ResultHandler Klasse.}
\label{diagram_auth}
\end{figure}

# Firebase
Firebase bietet viele verschiedene Möglichkeiten an, einen User zu authentifizieren, welche auch für dart mit dem ```firebase_auth``` Paket verfügbar sind.
 
Folgende Authentizierungen werden schon von Haus aus angeboten, wobei die fett markierten wirklich in Verwendung sind.

* **Email und Passwort**
* Telefon
* **Google**
* Google Play
* Apple Game Center
* **Facebook**
* Twitter
* GitHub
* Yahoo
* Microsoft
* Apple

## OAUTH
Mithilfe OAUTH ist es überhaupt erst möglich, User sicher über eine dritte App einzuloggen. (vgl. \cite{oauth}) Die Implementierung von OAuth mit den einzelnen Social Media Plattformen wurde von schon dem `firebase_auth` Paket gemacht und zur Verfügung gestellt.

# Realtime Authentication
Um die Echtzeit Authentizierung zu verwenden, war es essentiell einen `StreamProvider` aus dem `provider` Paket zu verwenden. Es existieren drei Streams dieses Stream-typen, einen für den `StreamProvider<User>`, welche in Echtzeit die Userdaten aus der Datenbank liest. Der zweite ist für den `StreamProvider<FirebaseUser>` verantwortlich und der dritte vom Typen `StreamProvider<bool>` dafür, ob derzeit eine Authentizierung im Gange ist.

Diese Streams können von allen Kindern im Widget Baum in Echtzeit gelesen werden. Aus diesem Grund musste die Authentizierung selbst auch ein Kind des `MaterialApp` Widgets sein. (siehe Code Snippet am Ende des Kapitels)

\begin{lstlisting}[language=Dart]
/* Wie man die Echtzeitdaten des Streams auslesen kann. */
FirebaseUser user = Provider.of<FirebaseUser>(context);
User docUser = Provider.of<User>(context);
bool loading = Provider.of<bool>(context);
\end{lstlisting}
    
# Probleme
Es gab zwei größere Probleme, welche etwas Zeit gekostet haben, da diese nicht sehr offensichtlich während der Programmierung waren.

## Twitter Login
Ein Problem, welches gleich am Anfang aufgetreten ist war, dass die Twitter Integration von dem `firebase_auth` Paket die neue Twitter API Version nicht unterstüzt. Aus diesem Grund ist kein Login mit Twitter möglich.

## State Handling
Hier war das Problem, den Unterschied zwischen einem `FirebaseUser` User und einem selbst erstellten `User` zu handlen. Dies ist sehr wichtig, da der `User` erst geladen wird, nachdem der `FirebaseUser` nicht `null` ist. Wenn aber das UI  sofort geändert wird, nachdem der `FirebaseUser` existiert, wird eben ein Fehler geworfen, da der `User` nicht existiert. Dies konnte mit einer einfachen Abfrage gelöst werden.

\begin{lstlisting}[language=Dart]
return AnimatedSwitcher(
    duration: Duration(milliseconds: 600),
    child: user != null
        ? Scaffold(
            key: mainScaffoldKey,
            body: docUser != null ? Body() : null,
            drawer: docUser != null ? Sidebar() : null,
          )
        : Scaffold(
            key: authScaffoldKey,
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 600),
              child: loading != null && loading ? SpinKitDoubleBounce(color: Colors.blueAccent) : AuthenticationPage(),
            ),
            resizeToAvoidBottomInset: false,
    ));
\end{lstlisting}
