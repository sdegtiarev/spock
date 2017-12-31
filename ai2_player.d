module ai;
import board;
import std.random;
import std.algorithm;
import std.array;
import std.typecons;


class AI_2
{
	private Side mine;
	private Board *board;

	this(ref Board board, Side side) {
		this.mine=side;
		this.board=&board;
	}

	@property bool dead() { return false; }
	void terminate() { }

	auto random_move() {
		auto r=Board.Move();
		uint N=0;
		auto v=board.variants_of(mine).filter!(a => board.is_safe_move(a)).array;
		foreach(m; v) {
			if(board.unit(m.to) == Unit.knight && board.side(m.to) == mine.opposite)
				return m;
			if(uniform(0,++N) == 0) 
				r=m;
		}

		if(r[0] && r[1])
			return r;
		else
			return random_unsafe_move;
	}

	auto random_unsafe_move() {
		foreach(p; board.units_of(mine))
			foreach(n; board.targets_of(p))
				return tuple(p,n);
		return Board.Move();
	}

	void make_turn() {
		if(board.turn != mine)
			return;
		if(!check_spock(mine)) {
			board.lock(Side.none);
			return;
		}

		board.move(random_move);
		board.lock(mine.opposite);
	}


	private bool check_spock(Side player) {
		return !board.units_of(player)
			.filter!(a => board.unit(a) == Unit.knight)
			.empty;
	}
}


