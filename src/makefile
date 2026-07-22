FBC := $(CURDIR)/../Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc

MFF := ../Controls/MyFbFramework
MFF_CFLAGS := -i $(MFF) -d __USE_GTK3__ -exx
IDE_CFLAGS := -i . $(MFF_CFLAGS)

MFF_LIB := $(MFF)/libmff64_gtk3.so

.PHONY: all clean

all: ../ilwaco

../ilwaco: VisualFBEditor.bas $(wildcard *.bas) $(wildcard *.bi) $(wildcard *.frm) $(MFF_LIB)
	$(FBC) VisualFBEditor.bas -x ../ilwaco $(IDE_CFLAGS) -p $(MFF) -l mff64_gtk3 -Wl "-rpath,\$$ORIGIN/Controls/MyFbFramework" -s console

$(MFF_LIB): $(MFF)/mff/mff.bi
	cd $(MFF)/mff && $(FBC) -b mff.bi -dll -x ../libmff64_gtk3.so -d __USE_GTK3__

clean:
	rm -f ../ilwaco *.o $(MFF)/mff/*.o $(MFF)/libmff64_gtk3.so
