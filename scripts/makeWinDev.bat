set LATEX=pdflatex

set PANDOCMODULES=markdown+auto_identifiers
set PANDOCMODULES=%PANDOCMODULES%+definition_lists
set PANDOCMODULES=%PANDOCMODULES%+fenced_code_attributes
set PANDOCMODULES=%PANDOCMODULES%+compact_definition_lists
set PANDOCMODULES=%PANDOCMODULES%+autolink_bare_uris
set PANDOCMODULES=%PANDOCMODULES%+pipe_tables+table_captions
set PANDOCMODULES=%PANDOCMODULES%+inline_notes+footnotes+link_attributes+smart


set PANDOCOPT=--listings -N -f %PANDOCMODULES%

cd markdown
for %%f in (*.md) do pandoc %PANDOCOPT% %%f -o "../tex/converted/%%~nf%.tex"
cd ..

%LATEX% diplomarbeit.tex --output-directory=build -aux-directory=build/tmp -halt-on-error

del build\tmp\diplomarbeit.aux
del build\tmp\diplomarbeit.lof
del build\tmp\diplomarbeit.lot
del build\tmp\diplomarbeit.idx
del build\tmp\diplomarbeit.out
del build\tmp\diplomarbeit.toc