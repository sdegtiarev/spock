module ai;
import board;
import std.random;
import std.algorithm;
import std.array;
import std.typecons;
import std.stdio;


class AI_2
{
	private Side mine;
	private Board board;

	this(Board board, Side side) {
		this.mine=side;
		this.board=board;
	}

	@property bool dead() { return false; }
	void terminate() { }

	auto random_move() {
		auto r=tuple(Board.point(SIZE,SIZE),Board.point(SIZE,SIZE));
		uint N=0;
		foreach(p; board.units_of(mine)) {
			foreach(n; board.targets_of(p)) {
				if(board.unit(n) == Unit.knight && board.side(n) == mine.opposite)
					return tuple(p,n);
				if(is_fatal_move(tuple(p,n)))
					continue;
				if(uniform(0,++N) == 0) 
					r=tuple(p,n);
			}
		}

		if(r[0] && r[1]) {
			//writeln(board.unit(r[0]),": ", r[0], "-", r[1]);
			return r;
		} else {
			writeln("NO SAFE TURNS!\n");
			return random_unsafe_move;
		}
	}

	auto random_unsafe_move() {
		foreach(p; board.units_of(mine))
			foreach(n; board.targets_of(p))
				return tuple(p,n);
		writeln("NO TURNS FOUND!\n");
		return tuple(Board.point(SIZE,SIZE),Board.point(SIZE,SIZE));
	}

	bool is_fatal_move(T)(T x) {
		auto tmp=board.dup;
		tmp.move(x);
		foreach(p; tmp.units_of(mine.opposite)) {
			foreach(n; tmp.targets_of(p))
				if(tmp.unit(n) == Unit.knight && tmp.side(n) == mine)
					return 1;
		}
		return 0;
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


	private bool check_spock(Side t) const {
		return !Board.cells
			.filter!(a => board.side(a) == t)
			.filter!(a => board.unit(a) == Unit.knight)
			.empty;
	}
}


