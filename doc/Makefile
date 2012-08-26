# Makefile for Aymargeddon documentation
# TODO: BUG: macht immer alles (liegt an +* nicht im target)

LYX2HTML	= lyx --export html
LYX2PDF		= lyx --export pdf
FICK2DEATH	= fig2dev

INSTALL_SERVER	= aymargeddon.de
INSTALL_DIR	= /home/benni/aymargeddon_current/doc/

DIRS		=
FILES_BIN	=
FILES_LIB	= 
FILES_DOC	= Regeln.lyx Techdoc.lyx ay_ein_hex.fig
FILES_MISC	= 
FILES		= Makefile $(FILES_IN) $(FILES_DOC) $(FILES_MISC)
FILES_OUT	= ay_ein_hex.eps Regeln.pdf \
		  Regeln.html Techdoc.pdf Techdoc.html $(FILES_MISC)


all: $(FILES_OUT) 

#Regeln.html:	Regeln.tex
#	$(LATEX2HTML) $(LATEX2HTML_OPT) < Regeln.tex > Regeln.html
#
#Techdoc.html:	Techdoc.tex
#	$(LATEX2HTML) $(LATEX2HTML_OPT) < Techdoc.tex > Techdoc.html	

clean:
	rm -f $(FILES_OUT) 
	rm -rf Regeln
	rm -rf Techdoc
	rm -rf auto
	rm -f  *.aux
	rm -f  *.log
	rm -f  *.ps
	rm -f  *.dvi
	rm -f  *~
	rm -f  *.toc
	rm -f  *.png
	rm -f  *.ps.gz
	rm -f  *.tex
	rm -f  +*

realclean: clean



#release: clean have_to_make
#	@if [ -z "$(RELDIR)" ] ;  then \
#		echo "Sorry, release directory is not set!" 1>&2 ; \
#		exit 1 ; \
#        fi ;\
#	if [ ! -d $(RELDIR) ] ; then mkdir $(RELDIR) ; fi ; \
#	tar cf - $(FILES) | \
#		( cd $(RELDIR) ; tar xf - )
#	for i in $(DIRS) ; do \
#		( cd $$i ; \
#		  $(MAKE) RELDIR=../$(RELDIR)/$$i $@ ) ; \
#	done

install: all

# hier muss dann das angepasste push-script hin

#	@if [ "X$(RELEASE)" = "X" ] ; then \
#		echo "Sorry, this isn't released source" 1>&2 ; \
#		exit 1 ; \
#	fi ;\
#	for i in $(INSTALLDIRS) ; do \
#                if [ ! -d $$i ] ;  then mkdir -p $$i ; fi ; \
#	done ;\
#	for i in $(FILES_DOC) ; do \
#		cp $$i $(DOCDIR)/$$i ; \
#		chmod 555 $(DOCDIR)/$$i ; \
#		chown bin:bin $(DOCDIR)/$$i ; \
#		echo "Installed $(DOCDIR)/$$i" ; \
#	done
#	for i in $(DIRS) ; do \
#	  ( cd $$i ; ${MAKE} RELEASE=$$RELEASE PREFIX=$(PREFIX) install ) ; \
#	done

# have_to_make:

.SUFFIXES:
.SUFFIXES: .pdf .lyx .eps .fig .html

.fig.eps:
	$(FICK2DEATH) -L ps $(FICK2DEATH_OPT) $< +$@

# TeX to DVI
#.tex.dvi:
#	$(LATEX) $< < /dev/null > /dev/null 2>&1
#	$(LATEX) $< < /dev/null > /dev/null 2>&1

# DVI to PS
#.dvi.ps:
#	$(DVIPS) -o $@ $<

# PS to PDF
#.ps.pdf:
#	$(PS2PDF) $< $@ 

# LyX to TeX
#.lyx.tex:
#	$(LYX2LATEX) $< > /dev/null 2>&1 && mv -f $@ +$@

# LyX to PDF
.lyx.pdf:
	$(LYX2PDF) $< > /dev/null 2>&1 && mv -f $@ +$@

# LyX to HTML
.lyx.html:
	$(LYX2HTML) $< > /dev/null 2>&1 && mv -f $@ +$@


