module human;
import board;
import display;
import arsd.simpledisplay;
import std.conv : to;


class Human
{
	private SpockDisplay disp;
	private Side side;
	private Board *board;
	Board.cell selection;

	this(SpockDisplay disp, ref Board board, Side side) {
		this.side=side;
		this.board=&board;
		this.disp=(side == Side.white)? disp : disp.flip;
		disp.window.setEventHandlers(
			  (MouseEvent event) { handle_mouse(event); }
			, (dchar ch) { handle_key(ch); }
		);
	}

	this(ref Board board, Side side) {
		this.side=side;
		this.board=&board;
		this.disp=display.display();
		if(side == Side.black) 
			disp.flip;
		disp.window.setEventHandlers(
			  (MouseEvent event) { handle_mouse(event); }
			, (dchar ch) { handle_key(ch); }
		);
	}

	@property bool dead() { return disp.window.closed; }
	void terminate() { disp.window.close; }

	void make_turn() {
		if(dead)
			return;
		disp.draw(*board);
		if(!board.spock(side)) {
			board.lock(Side.none);
			if(board.last_move.from)
				disp.window.title(to!string(board.unit(board.last_move.to))~" "~Board.print_move(board.last_move)~" : you lost");
			else
				disp.window.title("you lost");
			return;
		}
		if(board.turn == side)
			if(board.last_move.from)
				disp.window.title(to!string(board.unit(board.last_move.to))~" "~Board.print_move(board.last_move)~" : your turn");
			else
				disp.window.title("your turn");
		else if(board.turn == Side.none)
			disp.window.title("you win");
		else 
			disp.window.title("wait ...");
	}

	void loop(T)(T handler) {
		disp.window.eventLoop(100, handler);
	}


	private bool check_spock() const {
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x) {
			auto p=Board.cell(x,y);
			if(board.side(p) == side && board.unit(p) == Unit.knight)
				return 1;
		}
		return 0;
	}


	private void handle_mouse(MouseEvent event) {
		if(event.type != MouseEventType.buttonPressed)
			return;
		if(board.turn != this.side)
			return;

		auto p=disp.inside(event.x, event.y);
		if(!p)  // point is outside of display area
			return;

		if(!selection) {
		// make new selection
			if(board.side(p) == this.side) {
				auto ts=board.targets_of(p);
				if(ts.length == 0) return;
				foreach(t; ts)
					board.target(t);
				board.select(selection=p);
			}
		} else if(p == selection) {
		// selection uncheck
			selection=Board.cell(SIZE,SIZE);
			board.unselect;
		} else if(board.targeted(p)) {
		// make move
			board.move(selection, p);
			board.unselect;
			selection=Board.cell(SIZE,SIZE);
			board.lock(side.opposite);
		}
		// false click, do nothing
	}

	private void handle_key(dchar ch) {
		switch(ch) {
			case 17: terminate;   break; // Ctl-Q
			case 14: board.reset; break; // Ctl-N
			case 26: break; // Ctl-Z
			case 25: break; // Ctl-Y
			default: //writeln("key ", ch, " (", cast(int) ch, ")");
		}
	}
}