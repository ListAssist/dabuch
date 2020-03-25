# Andere Benutzer einladen

Andere Benutzer können entweder direkt beim Erstellen der Gruppe oder nach dem Erstellen der Gruppe eingeladen
werden. Beide Methoden verwenden die gleiche Cloud-Function `inviteUsers.ts`. Dieser Funktion wird beim Aufruf
eine GruppenID, Gruppenname, Name des Einladers und ein String-Array der Email-Adressen übergeben. Zu jeder 
Email-Adresse wird, sofern es eine gibt, die dazugehörige `uid` gesucht. Für jede `uid` wird dann ein Dokument
in der `invite`s-Collection erstellt.

\begin{lstlisting}[language=Dart]
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Timestamp = admin.firestore.Timestamp;

const db = admin.firestore();

export const inviteUsers = functions.region("europe-west1").https.onCall(async (data, context) => {
    const targetemails = data.targetemails;
    const groupid = data.groupid;
    const groupname = data.groupname;
    const from = data.from;
    const uid = context.auth.uid;

    if (!targetemails) {
        throw new functions.https.HttpsError("invalid-argument", "Emails are required");
    }

    if (!groupid) {
        throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
    }

    console.log(targetemails);

    return db.collection("groups_user")
        .doc(uid)
        .get()
        .then((snap) => {
            if(!snap.exists){
                return { status: "Failed no doc" };
            }
            if(!snap.data()["groups"].includes(groupid)) {
                return { status: "Failed not in group" };
            }
            //TODO: If User already has an invitation or is in group dont send another one
            return Promise.all(
                    targetemails.map((target: string) => db.collection("users")
                        .where("email", "==", target)
                        .get()
                        .then((sn) => {
                            if(!sn.docs && !sn.docs[0]) return null;
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
                )
                .then(() => {
                    return { status: "Successful" };
                })
                .catch(() => {
                    return { status: "Failed" };
                });
        })
        .catch((e) => {
            return { status: "Failed" };
        });

});
\end{lstlisting}

# Auslesen aus der Datenbank

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