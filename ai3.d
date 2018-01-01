module spock.ai.l3;
import spock.board;
import spock.player;
import std.random;
import std.algorithm;
import std.array;
import std.typecons;
import std.exception;


auto player(int SIZE)(ref Board!SIZE board, Side side)
{
	return new AI3!SIZE(board, side);
}
auto player(int SIZE)(Board!SIZE *board, Side side)
{
	return new AI3!SIZE(*board, side);
}


class AI3(int SIZE) : Player
{
	private Board!SIZE *board;

	this(ref Board!SIZE board, Side side) {
		super(side);
		this.board=&board;
	}

	override void make_turn() {
		if(board.turn != mine)
			return;
		if(!board.spock(mine) || !board.move(best_move)) {
			board.lock(Side.none);
			return;
		}
		board.lock(mine.opposite);
	}

	private auto best_move() {
		Board!SIZE.Move[][int] weight;
		foreach(m; board.variants_of(mine))
			weight[board.rank!2(m)]~=m;
		if(weight.length == 0)
			return Board!SIZE.Move();
		auto w=sort!("a>b")(weight.byKey.array).front;
		auto best=Board!SIZE.one_of(weight[w]);
		return best;
	}

}


