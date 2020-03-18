# Algorithmus

Als Grundlage für die automatisch generierten Einkaufslisten wird das `last` Array,
das die letzten 10 abgeschlossenen Einkaufslisten enthält, verwendet. Die Einkaufslisten
sind nach Datum des Abschließens sortiert. Zu Beginn wird überprüft, ob die vom Benutzer eingestellte
Zeitspanne seit dem letzten mal erstellen bereits vergangen ist. Dafür sind die Felder
`settings.ai_interval` sowie `last_automatically_generated` der User-Collection verantwortlich. 
Sollte dies nicht der Fall sein, wird das Erstellen der Einkaufsliste abgebrochen.

Der Erstellungsprozess läuft wie folgendermaßen ab. Zuerst wird die Zeitspanne in Tagen zwischen
dem neuesten und dem ältersten Einkauf ausgerechnet. Danach wird für jedes Produkt, welches 
zumindest einmal auf einer Einkaufsliste vorkommt, ausgerechnet, wie oft es gekauft wurde. 
Damit wird mit hilfe der Zeitspanne, die oben erwähnt wurde, ausgerechnet, in welchem Zeitabstand
eines des entsprechenden Produktes gekauft wurde. Dies wurde wie folgt umgesetzt:

\begin{lstlisting}[language=JavaScript]
function calculateFrequency(lastLists: object[], days: number) {
    const itemFrequency: object = {};

    for (const list of lastLists) {
        for (const item of list["items"]) {
            itemFrequency[item["name"]] = itemFrequency[item["name"]]
                ? itemFrequency[item["name"]] + item["count"]
                : item["count"];
        }
    }

    for (const key in itemFrequency) {
        itemFrequency[key] = Math.round(days / itemFrequency[key]);
    }

    return itemFrequency;
}
\end{lstlisting}

\needspace{9\baselineskip}
Nachdem die Zeitspanne der Produkte berechnet wurde, wird für jedes Produkt das vorkommt
das Datum des letzten Einkaufs dieses Produktes gesucht. Danach wird überprüft, ob das Produkt
demnächst gekauft werden muss bzw. ob es unmittelbar vor heute gekauft werden hätte sollen.
Um die Anzahl der Produkte miteinzubeziehen wird der Zeitabstand zwischen dem nächsten Einkauf
des Produktes und dem heutigen Datum durch die häufigkeit des Produktes gerechnet. Beispielsweise,
wenn das Produkt das nächste mal in 5 Tagen gekauft werden soll, es in die Kriterien für den
Vorschlag fällt, aber das Produkt alle 2 Tage gekauft wurde, wird das Produkt mit einer Stückzahl
von 2 vorgeschlagen.

\begin{lstlisting}[language=JavaScript]
const timeSpan = Math.ceil(Math.abs(lastDay - firstDay) / (1000 * 60 * 60 * 24));
const itemFrequency: object = calculateFrequency(lists, timeSpan);

Object.keys(itemFrequency).forEach(i => {
    const next: Date = getLastDateWithItem(lists, i);
    next.setDate(next.getDate() + itemFrequency[i]);
    const timeDiffToToday = Math.ceil(Math.floor(today - next) / (1000 * 60 * 60 * 24));

    // (itemFrequency[i] <= timeSpan/2) damit zu selten gekaufte Produkte nicht vorgeschlagen werden
    // timeDiffToToday + 5 <= 2 damit ein kleiner Puffer für die Tage davor gegeben ist 
    if ((timeDiffToToday >= 0 || timeDiffToToday + 5 <= 2) 
            && (itemFrequency[i] <= timeSpan/2)) {
        recommendation.push(
            {
                count: timeDiffToToday === 0 
                    ? 1 
                    : Math.round(timeDiffToToday / itemFrequency[i]),
                name: i,
                bought: false,
                price: 0,
                category: "Generated"
            }
        );
    }
});

function getLastDateWithItem(lastLists: object[], name: string) {
    const lastPossibilities: Date[] = [];

    lastLists.forEach((el, index) => {
        if (el["items"].map(i => i["name"]).includes(name)) {
            lastPossibilities.push(lastLists[index]["completed"].toDate());
        }
    });

    return new Date(Math.max(...lastPossibilities));
}
\end{lstlisting}

\needspace{6\baselineskip}
Nachdem ein Array von vorgeschlagenen Produkten erstellt wurde, wird dieses in eine neue Einkaufsliste
eingefügt. Die Einkaufsliste bekommt den Namen "Autogeneriert List DD.MM.YY". Zusätzlich wird bei dem Benutzer
bzw. bei der Gruppe, für den/die die Einkaufsliste generiert wird, das Feld `last_automatically_generated` auf
den jetzigen Zeitpunkt gesetzt. Damit der folgende Code besser lesbar ist, wird die Funktion nur für Benutzer dargestellt.

\begin{lstlisting}[language=JavaScript]
const newList = {
    created: Timestamp.now(),
    name: `Autogenerierte Liste $\$${("00" + today.getDate()).substr(-2)}.$\$${("00" + (today.getMonth() + 1)).substr(-2)}.$\$${today.getFullYear()}`,
    type: "pending",
    items: recommendedItems
};

if(recommendedItems.length === 0){
    return { status: "Failed" };
}

return Promise.all([
    db.collection("users").doc(uid).collection("lists").add(newList),
    db.collection("users").doc(uid).set(
        {
            last_automatically_generated: Timestamp.now()
        }, { merge: true })
]).catch(() => {
    return { status: "Failed" };
}).then(() => {
    return { status: "Successful" };
});
\end{lstlisting}

# Implementierung in die App

Die Überprüfung, ob bereits die vom Benutzer eingestellte Dauer vergangen ist, erfolgt nicht nur in der
Cloud-Function, sondern auch auf der Clientseite, in der App, selbst. Dazu wird der folgende Code in der
Einkaufslisten-View verwendet:

\needspace{10cm}
\begin{lstlisting}[language=Dart]
User user = Provider.of<User>(context);
if(user.settings != null) {
    if (user.settings["ai_enabled"]) {
        if (user.settings["ai_interval"] != null) {
            if (user.lastAutomaticallyGenerated == null) {
                _createAutomaticList();
            } else {
                DateTime nextList = user.lastAutomaticallyGenerated
                    .toDate().add(
                        Duration(
                            days: user.settings["ai_interval"]
                        )
                    );
                if (DateTime.now().isAfter(nextList)) {
                    _createAutomaticList();
                }
            }
        }
    }
}

_createAutomaticList() async {
    final HttpsCallable autoList = cloudFunctionInstance.getHttpsCallable(
        functionName: "createAutomaticList"
    );
    try {
        dynamic resp = await autoList.call({
            "groupid": null
        });
        if (resp.data["status"] != "Successful") {
            //Fehler in der Cloud-Function
            // z.B.: Nicht genug Einkäufe abgeschlossen
        } else {
            InfoOverlay.showInfoSnackBar(
                "Automatische Einkaufsliste wurde erstellt"
            );
        }
    }catch(e) {
        //Fehler beim Aufrufen der Cloud-Function
    }
}
\end{lstlisting}

Der gleiche Code wird auch für Gruppen verwendet, mit dem Unterschied, dass anstelle der Benutzereinstellungen
die Gruppeneinstellungen geladen werden und die Cloud-Function mit der GruppenID aufgerufen wird.

\needspace{12cm}
# Vorschläge mit AI

Beim Überlegen, wie die AI aussehen sollte, gab es einige Schwierigkeiten mit der AI. Mit einem Convolutional Neural Network
(CNN) ist diese Art von AI nicht möglich. Im Unterricht wurden CNN Grundlagen beigebracht, jedoch nur im Zusammenhang
mit Bildklassifizierung und nicht als eine Art "Vorschlags-AI". Später im Unterricht wurde das sogenannte Recurrent 
Neural Network (RNN) durchgemacht. Diese Art von neuronalen Netzwerken wird vorallem bei Aktienkursvorhersagen verwendet.
Anstelle der für CNNs benutzen Dense- und Conv2D-Layern, verwendet ein RNN sogenannte Long short-term memory (LSTM) Layer.
Da ein RNN Aktienpreise vorhersagen kann, wäre es auch möglich, dieses für Produktvorhersagen zu trainieren.

# Warum Algorithmus nicht AI

Da eine AI auch sehr viele Trainingsdaten benötigt, um gut zu funktionieren, wurde anstelle einer AI ein Algorithmus verwendet.
Außerdem ist eine AI in diesem Umfang gar nicht nötig. Der Algorithmus ist für diese Aufgabe besser geeignet, da man keine Trainingsdaten
benötigt und er zudem schneller funktioniert.