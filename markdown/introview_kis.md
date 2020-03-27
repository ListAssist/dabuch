\newcommand\mypicWidtha{0.45}

# Allgemein 

Um dem Benutzer einen Überblick über die wichtigsten Funktionen 
der App zu geben, wurde ein Intro-View entwickelt. Dieser wird nach dem ersten Login
auf dem jeweiligen Gerät angezeigt. 

Das `shared_preferences`\footnote{\url{https://pub.dev/packages/shared_preferences}} Package wurde verwendet,
um eine persistente `boolean` Variable (`firstLaunch`), lokal am Gerät, zu speichern, die nach dem ersten
Login `false` gesetzt wird.

Die `SharedPreferences` müssen zuerst initialisiert werden:
\begin{lstlisting}[language=Dart]
@override
void initState() {
    super.initState();
    initSharedPreferences();
}

initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
    firstLaunch = prefs.getBool("firstLaunch");
    if(firstLaunch == null) firstLaunch = true;
}
\end{lstlisting}

Wenn der `IntroView` verlassen wird, wird die `firstLaunch` Variable `false` gesetzt.
\begin{lstlisting}[language=Dart]
onIntroSliderExit() {
    setState(() {
        firstLaunch = false;
    });
    prefs.setBool("firstLaunch", false);
}
\end{lstlisting}

\needspace{10cm}

Im `body` des `MainScaffold` der App wird je nachdem der IntroSlider angezeigt.
\begin{lstlisting}[language=Dart]
Scaffold(
    key: mainScaffoldKey,
    body: docUser != null ? firstLaunch ? IntroSliderView(onExit: onIntroSliderExit,) : Body() : null,
    drawer: docUser != null ? Sidebar() : null,
)
\end{lstlisting}

Für die Implementation wurde das `intro_slider`\footnote{\url{https://pub.dev/packages/intro_slider}} Package 
verwendet. Zuerst werden die `slides` erstellt und in eine Liste gegeben.
\begin{lstlisting}[language=Dart]
slides.add(
    new Slide(
    title: "GRUPPEN ERSTELLEN",
    description: 
      "Erstelle Gruppen und teile deine Einkaufslisten mit Freunden",
    pathImage: "assets/images/group.png",
    backgroundColor: Color(0xff6a1b9a),
    heightImage: 200,
    widthImage: 200,
    marginDescription: EdgeInsets.only(top: 50, left: 22, right: 22),
    ),
);
\end{lstlisting}

\begin{lstlisting}[language=Dart]
void onDonePress() {
    widget.onExit();
}

void onSkipPress() {
    widget.onExit();
}

@override
Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onSkipPress,
      nameNextBtn: "WEITER",
      namePrevBtn: "ZURÜCK",
      nameDoneBtn: "FERTIG",
    );
}
\end{lstlisting}

\begin{figure}[H]
    \begin{minipage}{\mypicWidtha\textwidth}
        \includegraphics[width=\textwidth, keepaspectratio]{images/kisi/IntroView1.jpg}
        \caption{Intro-View 1}
        \label{intro-view1} 
	\end{minipage}
	\hfill
    \begin{minipage}{\mypicWidtha\textwidth}
        \includegraphics[width=\textwidth, keepaspectratio]{images/kisi/IntroView2.jpg}
        \caption{Intro-View 2}
        \label{Intro-View 2} 
	\end{minipage}
\end{figure}

\begin{figure}[H]
    \begin{minipage}{\mypicWidtha\textwidth}
        \includegraphics[width=\textwidth, keepaspectratio]{images/kisi/IntroView3.jpg}
        \caption{Intro-View 3}
        \label{Intro-View 3} 
	\end{minipage}
	\hfill
    \begin{minipage}{\mypicWidtha\textwidth}
        \includegraphics[width=\textwidth, keepaspectratio]{images/kisi/IntroView4.jpg}
        \caption{Intro-View 4}
        \label{Intro-View 4} 
	\end{minipage}
\end{figure}