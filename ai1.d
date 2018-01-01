module spock.ai.l1;
import spock.board;
import spock.player;
import std.random;
import std.algorithm;
import std.array;
import std.typecons;

auto player(int SIZE)(ref Board!SIZE board, Side side)
{
	return new AI1!SIZE(board, side);
}
auto player(int SIZE)(Board!SIZE *board, Side side)
{
	return new AI1!SIZE(*board, side);
}


class AI1(int SIZE) : Player
{
	private Board!SIZE *board;

	this(ref Board!SIZE board, Side side) {
		super(side);
		this.board=&board;
	}

	override void make_turn() {
		if(board.turn != mine)
			return;
		if(!board.spock(mine)) {
			board.lock(Side.none);
			return;
		}

		board.move(random_move);
		board.lock(mine.opposite);
	}


	private auto random_move() {
		auto r=Board!SIZE.Move();
		uint N=0;
		foreach(m; board.variants_of(mine))
			if(uniform(0,++N) == 0) 
				r=m;
		return r;
	}

}


