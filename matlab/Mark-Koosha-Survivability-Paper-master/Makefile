all: main.pdf

main.aux:
	pdflatex main.tex

main.bbl:
	bibtex main

main.pdf: main.aux main.bbl
	pdflatex main.tex
	pdflatex main.tex
	pdflatex main.tex

clean:
	-rm main.aux
	-rm main.bbl
	-rm main.blg
	-rm main.glg
	-rm main.glo
	-rm main.gls
	-rm main.ist
	-rm main.log
	-rm main.toc
	-rm main.spl
	-rm main.out
	-rm main.aux

cleanall: clean
	-rm main.pdf

