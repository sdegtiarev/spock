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
	private Board *board;

	this(ref Board board, Side side) {
		this.mine=side;
		this.board=&board;
	}

	@property bool dead() { return false; }
	void terminate() { }

	auto moves() {
		return board.variants_of(mine).filter!(a => board.is_safe_move(a));
	}

	auto random_move() {
		auto r=tuple(Board.cell(),Board.cell());
		uint N=0;
		foreach(m; board.variants_of(mine).filter!(a => board.is_safe_move(a))) {
			if(board.unit(m.to) == Unit.knight && board.side(m.to) == mine.opposite)
				return m;
			if(uniform(0,++N) == 0) 
				r=m;
		}

		if(r[0] && r[1]) {
			//writeln(board.unit(r[0]),": ", r[0], "-", r[1]);
			return r;
		} else {
			writeln("NO SAFE TURNS!");
			return random_unsafe_move;
		}
	}

	auto random_unsafe_move() {
		foreach(p; board.units_of(mine))
			foreach(n; board.targets_of(p))
				return tuple(p,n);
		writeln("NO TURNS FOUND!");
		return Board.Move();
	}

	bool is_fatal_move(T)(T x) {
		auto tmp=*board;
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

		//auto v=moves;
		//bool mv=1;
		//foreach(m; v.filter!(a => board.unit(a.to) == Unit.knight && board.side(a.to) == mine.opposite)) {
		//	board.move(m);
		//	mv=0;
		//	break;
		//}
		//if(mv)
		//	board.move(board.one_of(v));


		board.move(random_move);
		board.lock(mine.opposite);
	}


	private bool check_spock(Side player) {
		return !board.units_of(player)
			.filter!(a => board.unit(a) == Unit.knight)
			.empty;
	}
}


