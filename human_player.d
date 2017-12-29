module human;
import board;
import display;
import arsd.simpledisplay;


class Human
{
	private SpockDisplay disp;
	private Side side;
	private Board board;
	private bool rollback, redo;
	Board.point selection=Board.point(SIZE,SIZE);

	this(SpockDisplay disp, Board board, Side side) {
		this.side=side;
		this.board=board;
		this.disp=(side == Side.white)? disp : disp.flip;
		disp.window.setEventHandlers(
			  (MouseEvent event) { handle_mouse(event); }
			, (dchar ch) { handle_key(ch); }
		);
	}

	this(Board board, Side side) {
		this.side=side;
		this.board=board;
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
		disp.draw(board);
		if(!check_spock) {
			board.lock(Side.none);
			disp.window.title("You lost");
			return;
		}
		if(board.turn == side)
			disp.window.title("Your turn");
		else if(board.turn == Side.none)
			disp.window.title("Your win");
		else 
			disp.window.title("Wait ...");
	}

	void loop(T)(T handler) {
		disp.window.eventLoop(100, handler);
	}


	private bool check_spock() const {
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x) {
			auto p=Board.point(x,y);
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
			selection=Board.point(SIZE,SIZE);
			board.unselect;
		} else if(board.targeted(p)) {
		// make move
			board.move(selection, p);
			board.unselect;
			selection=Board.point(SIZE,SIZE);
			board.lock(side.opposite);
		}
		// false click, do nothing
	}

	private void handle_key(dchar ch) {
		import std.stdio;
		switch(ch) {
			case 17: terminate;   break; // Ctl-Q
			case 14: board.reset; break; // Ctl-N
			case 26: rollback=1;  break; // Ctl-Z
			case 25: redo=1;      break; // Ctl-Y
			//case 27: b.unselect; d1.draw(b); d2.draw(b); ex=-1; break;
			//case 'a': case 'b': case 'c': case 'd': case 'e': ex=ch-'a'; break;
			//case '1': case '2': case '3': case '4': case '5':
			//	if(ex >= 0) {
			//		b.click(Board.point(ex, SIZE-ch+'0'));
			//		d1.draw(b);
			//		d2.draw(b); ex=-1;
			//		handle_title();
			//	}
			//	break;
			default: //writeln("key ", ch, " (", cast(int) ch, ")");
		}
	}
}