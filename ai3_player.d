module ai;
import board;
import std.random;
import std.algorithm;
import std.array;
import std.typecons;
import std.exception;


auto player_3(size_t SIZE)(ref Board!SIZE board, Side side)
{
	return new AI_3!SIZE(board, side);
}


class AI_3(size_t SIZE)
{
	private Side mine;
	private Board!SIZE *board;

	this(ref Board!SIZE board, Side side) {
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
		Board!SIZE.Move[][int] weight;
		foreach(m; board.variants_of(mine))
			weight[board.rank!2(m)]~=m;
		if(weight.length == 0)
			return Board!SIZE.Move();
		auto w=sort!("a>b")(weight.byKey.array).front;
		auto best=Board!SIZE.one_of(weight[w]);
		//writefln("%-6s %s    %s", board.unit(best.from),Board!SIZE.print_move(best), w);
		return best;
	}

}


