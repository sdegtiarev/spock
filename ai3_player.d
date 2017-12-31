module ai;
import board;
import std.random;
import std.algorithm;
import std.array;
import std.typecons;
import std.exception;


class AI_3
{
	private Side mine;
	private Board *board;

	this(ref Board board, Side side) {
		this.mine=side;
		this.board=&board;
	}

	@property bool dead() { return false; }
	void terminate() { }

	void make_turn() {
		if(board.turn != mine)
			return;
		if(!board.spock(mine) || !board.move(best_move)) {
			board.lock(Side.none);
			return;
		}
		board.lock(mine.opposite);
	}

	auto best_move() {
		Board.Move[][int] weight;
		foreach(m; board.variants_of(mine))
			weight[board.rank!4(m)]~=m;
		if(weight.length == 0)
			return Board.Move();
		auto w=sort!("a>b")(weight.byKey.array).front;
		auto best=Board.one_of(weight[w]);
		//writefln("%-6s %s    %s", board.unit(best.from),Board.print_move(best), w);
		return best;
	}

}


