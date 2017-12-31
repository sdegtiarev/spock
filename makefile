
DC= dmd
GRAPHICS= arsd/simpledisplay.d arsd/color.d 

all: spock spock1 spock2 spock3

spock: spock.d human_player.d board.d display.d icons.d $(GRAPHICS)
	$(DC) -g $^

spock1: spock1.d human_player.d ai1_player.d board.d display.d icons.d $(GRAPHICS)
	$(DC) -g $^

spock2: spock2.d human_player.d ai2_player.d board.d display.d icons.d $(GRAPHICS)
	$(DC) -g $^

spock3: spock3.d human_player.d ai3_player.d board.d display.d icons.d $(GRAPHICS)
	$(DC) -g $^

.PHONY: clean
clean:
	rm -f *.o spock spock1 spock2 spock3 core*
