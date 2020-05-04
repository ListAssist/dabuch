# Andere Benutzer einladen

Andere Benutzer können entweder direkt beim Erstellen der Gruppe oder nach dem Erstellen der Gruppe eingeladen
werden. Beide Methoden verwenden die gleiche Cloud-Function `inviteUsers`. Dieser Funktion wird beim Aufruf
eine GruppenID, Gruppenname, Name des Einladers und ein String-Array der Email-Adressen übergeben. Zu jeder 
Email-Adresse wird, sofern es eine gibt, die dazugehörige `uid` gesucht. Für jede `uid` wird dann ein Dokument
in der `invite`s-Collection erstellt. Dazu wird folgendes in der Cloud-Function verwendet:

\begin{lstlisting}[language=Dart]
targetemails.map((target: string) => db.collection("users")
    .where("email", "==", target)
    .get()
    .then((sn) => {
        // Email-Adresse nicht in der DB vorhanden
        if(!sn.docs && !sn.docs[0]) return null;
        // Falls der Benutzer versucht sich selbst einzuladen
        if(sn.docs[0].data()["uid"] === uid) return null;
        return db.collection("invites")
            .add({
                created: Timestamp.now(),
                from: from,
                groupid: groupid,
                groupname: groupname,
                to: sn.docs[0].data()["uid"]
            })
    }))
);
\end{lstlisting}

Der eingeladene Benutzer erhält dann in Echtzeit die Einladung in die Gruppe. Ihm bleiben die
Möglichkeiten, die Einladung abzulehnen oder anzunehmen. Wenn der Benutzer die Einladung annimmt,
wird er in das `members`-Array der entsprechenden Gruppe hinzugefügt und in seinem `groups_user`-Dokument
wird die GruppenID hinzugefügt. Beim Ablehnen wird dies nicht gemacht. Es wird nur das Dokument
der Einladung aus der Datenbank gelöscht, was auch nach dem Annehmen passiert. 

\needspace{5cm}
Zuerst gab es ein Feld `type`, das den Status der Einladung speicherte. Es wurde daher nach dem Ablehnen
das Feld von `pending` auf `declined` und nach dem Akzeptieren auf `accepted` gesetzt. Da die abgelehnten
bzw. angenommenen Einladungen aber sowieso nicht einsehbar sind, wurde dieses Feld weggelassen und stattdessen
werden die Einladungen einfach gelöscht.

In der Cloud-Function werden natürlich auch Sicherheitskontrollen durchgeführt. Unter anderem wird überprüft,
ob der Benutzer, der einen anderen Benutzer einladen möchte, sich auch selbst in der Gruppe, zu der er die
Einladung schickt, befindet. Sollte das nicht der Fall sein, wird die Funktion nicht ausgeführt und das Einladen
schlägt fehl.

# Auslesen aus der Datenbank

Wie alles andere funktionieren auch die Einladungen in Echtzeit. Anders als bei anderen Collections, die einfach
auslesbar sind, weil es Subcollections des Benutzers sind, oder die als DokumentID die `uid` verwenden, sind die
IDs der Einladungen zufällig generiert. Mithilfe des Felds `to` wird die `uid` des Eingeladenen gespeichert. Mit
Firestore ist auch ein Auslesen aller Dokumente, welche die gewünschte `uid` im Feld `to` stehen haben, leicht möglich.

\begin{lstlisting}[language=Dart]
Stream<List<Invite>> streamInvites(String uid) {
    print("----- READ INVITES -----");
    return _db
        .collection("invites")
        .where("to", isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.documents.map((d) => Invite.fromFirestore(d)).toList());
}
\end{lstlisting}