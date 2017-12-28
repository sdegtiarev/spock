
DC= dmd
GRAPHICS= arsd/simpledisplay.d arsd/color.d 

all: t1 t2 

t1: t1.d spock/*.d
	$(DC) t1 spock/*.d $(GRAPHICS)

t2: t2.d spock/*.d
	$(DC) t1 spock/*.d $(GRAPHICS)

.PHONY: clean
clean:
	rm -f *.o t1 t2 core*
