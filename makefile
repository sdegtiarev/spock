
DC= dmd
GRAPHICS= arsd/simpledisplay.d arsd/color.d 

#all: spock0 spock1 spock2 spock3 spock4 spock 
all: spock 

# spock0: spock0.d player.d human.d board.d display.d icons.d $(GRAPHICS)
# 	$(DC) -g $^

# spock1: spock1.d player.d human.d ai1.d board.d display.d icons.d $(GRAPHICS)
# 	$(DC) -g $^

# spock2: spock2.d player.d human.d ai2.d board.d display.d icons.d $(GRAPHICS)
# 	$(DC) -g $^

# spock3: spock3.d player.d human.d ai3.d board.d display.d icons.d $(GRAPHICS)
# 	$(DC) -g $^

# spock4: spock4.d player.d human.d ai4.d board.d display.d icons.d $(GRAPHICS)
# 	$(DC) -g $^

spock: main.d getopt.d board.d display.d icons.d player.d human.d ai1.d ai2.d ai3.d ai4.d $(GRAPHICS)
	$(DC) -g $^ -of=$@

.PHONY: clean
clean:
	@rm -f *.o spock spock0 spock1 spock2 spock3 spock4 core*
