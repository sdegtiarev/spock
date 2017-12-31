module ai;
import board;
import std.random;
import std.algorithm;
import std.array;
import std.typecons;

auto player_1(size_t SIZE)(ref Board!SIZE board, Side side)
{
	return new AI_1!SIZE(board, side);
}


class AI_1(size_t SIZE)
{
	private Side side;
	private Board!SIZE *board;

	this(ref Board!SIZE board, Side side) {
		this.side=side;
		this.board=&board;
	}

	@property bool dead() { return false; }
	void terminate() { }

	auto random_move() {
		auto r=Board!SIZE.Move();
		uint N=0;
		foreach(p; Board!SIZE.cells.filter!(a => board.side(a) == side)) {
			foreach(n; board.targets_of(p)) {
				if(board.unit(n) == Unit.knight && board.side(n) == side.opposite)
					return tuple(p,n);
				if(uniform(0,++N) == 0)
					r=tuple(p,n);
			}
		}
		return r;
	}

	void make_turn() {
		if(board.turn != side)
			return;
		if(!check_spock(side)) {
			board.lock(Side.none);
			return;
		}

		board.move(random_move);
		board.lock(side.opposite);
	}


	private bool check_spock(Side t) const {
		return !Board!SIZE.cells
			.filter!(a => board.side(a) == t)
			.filter!(a => board.unit(a) == Unit.knight)
			.empty;
	}
}


