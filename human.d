module spock.human;
import spock.board;
import spock.player;
import spock.display;
import arsd.simpledisplay;
import std.conv : to;

Player human(int SIZE)(ref Board!SIZE board, Side side)
{
	return new Human!SIZE(board, side);
}
Player human(int SIZE)(Board!SIZE *board, Side side)
{
	return new Human!SIZE(*board, side);
}

class Human(int SIZE) : Player
{
	private SpockDisplay disp;
	private Board!SIZE *board;
	Board!SIZE.cell selection;

	this(SpockDisplay disp, ref Board!SIZE board, Side side) {
		super(side);
		this.board=&board;
		this.disp=(side == Side.white)? disp : disp.flip(board);
		disp.window.setEventHandlers(
			  (MouseEvent event) { handle_mouse(event); }
			, (dchar ch) { handle_key(ch); }
		);
	}

	this(ref Board!SIZE board, Side side) {
		super(side);
		this.board=&board;
		this.disp=display(board);
		if(side == Side.black) 
			disp.flip(board);
		disp.window.setEventHandlers(
			  (MouseEvent event) { handle_mouse(event); }
			, (dchar ch) { handle_key(ch); }
		);
	}

	override @property bool dead() { return disp.window.closed; }
	override void terminate() { disp.window.close; }
	override void loop(void delegate() handler) {
		disp.window.eventLoop(100, handler);
	}



	override void make_turn() {
		if(dead)
			return;
		disp.draw(*board);
		if(!board.spock(mine)) {
			board.lock(Side.none);
			if(board.last_move.from)
				disp.window.title(to!string(board.unit(board.last_move.to))~" "~Board!SIZE.print_move(board.last_move)~" : you lost");
			else
				disp.window.title("you lost");
			return;
		}
		if(board.turn == mine)
			if(board.last_move.from)
				disp.window.title(to!string(board.unit(board.last_move.to))~" "~Board!SIZE.print_move(board.last_move)~" : your turn");
			else
				disp.window.title("your turn");
		else if(board.turn == Side.none)
			disp.window.title("you win");
		else 
			disp.window.title("wait ...");
	}

	private void handle_mouse(MouseEvent event) {
		if(event.type != MouseEventType.buttonPressed)
			return;
		if(board.turn != mine)
			return;

		auto p=disp.inside(board, event.x, event.y);
		if(!p)  // point is outside of display area
			return;

		if(!selection) {
		// make new selection
			if(board.side(p) == mine) {
				auto ts=board.targets_of(p);
				if(ts.length == 0) return;
				foreach(t; ts)
					board.target(t);
				board.select(selection=p);
			}
		} else if(p == selection) {
		// selection uncheck
			selection=Board!SIZE.cell();
			board.unselect;
		} else if(board.targeted(p)) {
		// make move
			board.move(selection, p);
			board.unselect;
			selection=Board!SIZE.cell();
			board.lock(mine.opposite);
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