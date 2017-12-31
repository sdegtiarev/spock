module board;
import std.conv;
import std.traits;
import std.algorithm;
import std.typecons;
import std.exception;
import std.random;
import std.range;

immutable uint CELL=64;
enum Side : ubyte { none=0, white=0x08, black=0x10 }
enum Mark : ubyte { none=0, selected=0x20, targeted=0x40 }
enum Unit : ubyte { none=0, pawn=1, bishop=2, queen=3, tour=4, knight=5 }


Unit reincarnate(Unit x) {
	switch(x) {
		default:
		case Unit.none: return Unit.none;
		case Unit.pawn: return Unit.bishop;
		case Unit.bishop: return Unit.queen;
		case Unit.queen: return Unit.tour;
		case Unit.tour: return Unit.knight;
		case Unit.knight: return Unit.pawn;
	}
}

Side opposite(Side x) {
	final switch(x) {
		case Side.white: return Side.black;
		case Side.black: return Side.white;
		case Side.none: return Side.none;
	}
}





struct Board(size_t SIZE)
{
static @property int pixels() { return CELL*SIZE+1; }
	@property size_t size() const { return SIZE; }
	struct cell {
		ubyte x=SIZE,y=SIZE;
		this(T)(T a, T b) if(isIntegral!T) { x=cast(ubyte) a; y=cast(ubyte) b; }
		bool opCast(T)() if(is(T == bool)) { return x < SIZE && y < SIZE; }
		cell opBinary(string op)(dP d) { return cell(mixin("x"~op~"d.x"), mixin("y"~op~"d.y")); }
		void opOpAssign(string op)(dP d) { mixin("x"~op~"=d.x;"); mixin("y"~op~"=d.y;"); }
		//auto toString() { return "("~to!string(x)~", "~to!string(y)~")"; }
		auto toString() { return to!string(cast(char)(x+'A'))~to!string(cast(char)('0'+SIZE-y)); }
	}
	struct dP { int x, y; }
	alias Move=Tuple!(cell,"from", cell,"to");
	
	private struct cellRange {
		private uint x=0, y=0;
		cell front() { return cell(x,y); }
		bool empty() const { return x >= SIZE && y >= SIZE; }
		void popFront() {
			if(empty) return;
			if(++x >= SIZE) {
				if(++y >= SIZE) { x=SIZE; y=SIZE; }
				else x=0;
			}
		}
	}

	static auto one_of(T)(T many) {
		ElementType!T r;
		ulong n=0;
		foreach(one; many)
			if(uniform(0,++n) == 0) r=one;
		return r;
	}


	private ubyte[SIZE][SIZE] field=init_field;
	private Side player_turn=Side.white;
	Move last_move;

	void lock(Side side) { player_turn=side; }
	@property Side turn() { return player_turn; }
	static auto cells() { return cellRange(); }

	void reset() {
		field=init_field;
		last_move=Move();
		lock(player_turn=Side.white);
	}

	ref ubyte at(cell p) { return field[p.x][p.y]; }
	ubyte at(cell p) const { return field[p.x][p.y]; }

	Unit unit(cell p) const { return cast(Unit) (at(p) & 0x07); }
	Side side(cell p) const { return cast(Side) (at(p) & (Side.black|Side.white)); }
	bool selected(cell p) const { return cast(bool) (at(p) & Mark.selected); }
	bool targeted(cell p) const { return cast(bool) (at(p) & Mark.targeted); }
	bool empty(cell p)    const { return unit(p) == Unit.none; }

	void select(cell p) { at(p) |=Mark.selected; }
	void target(cell p) { at(p) |=Mark.targeted; }
	void unselect(cell p) { at(p) &=~(Mark.selected|Mark.targeted); }
	void unselect() {
		for(int y=0; y < SIZE; ++y)
		for(auto p=cell(0,y); p; p+=dP(1,0))
			unselect(p);
	}



	auto units_of(Side player) {
		return Board.cells.filter!(a => side(a) == player);
	}

	cell[] targets_of(cell p) {
		switch(unit(p)) {
			case Unit.pawn: return targets_of_pawn(p);
			case Unit.bishop: return targets_of_bishop(p);
			case Unit.tour: return targets_of_tour(p);
			case Unit.queen: return targets_of_queen(p);
			case Unit.knight: return targets_of_knight(p);
			default: assert(0, "invalid target");
		}
	}

	static auto print_move(Move x) { return x[0].toString~"-"~x[1].toString; }

	auto variants_of(Side player) {
		return units_of(player).map!(a => targets_of(a).map!(b => Move(a,b))).joiner;
	}

	bool spock(Side player) {
		return !units_of(player)
			.filter!(a => unit(a) == Unit.knight)
			.empty;
	}

static string ident(int N)() {
	immutable char[256] s=' ';
	return s[0..N-1].idup;
}

	int rank(int N)(Move x) {
		static if(N == 0) {
			return 0;
		} else {
			auto mine=side(x[0]);
			int rnk=rank_move(x);

			auto tmp=this;
			tmp.move(x);

			if(!tmp.spock(mine.opposite))
				return 100;
			int alien=int.min;
			foreach(i; tmp.variants_of(mine.opposite).map!(a => tmp.rank!(N-1)(a)))
				alien=max(alien, i);
			return rnk-alien;
		}
	}

	bool is_safe_move(Move x) {
		auto mine=side(x[0]);
		auto tmp=this;
		tmp.move(x);
		// if we kill enemy last spock, the move is considered safe
		if(tmp.units_of(mine.opposite).filter!(a => tmp.unit(a) == Unit.knight).empty)
			return 1;
		// simulate enemy's response and see if he may kill our knight
		foreach(m; tmp.variants_of(mine.opposite)) {
			if(tmp.unit(m.to) == Unit.knight && tmp.side(m.to) == mine)
				return 0;
		}
		return 1;
	}

	void move(cell p, cell n) {
		enforce(p, "invalid move from ("~to!string(p.x)~","~to!string(p.y)~")-("~to!string(n.x)~"-"~to!string(n.y)~")");
		enforce(n, "invalid move to "~p.toString~"-"~n.toString);
		ubyte t=(unit(p) == Unit.knight)? reincarnate(unit(n))|side(p) : 0;
		at(n)=at(p);
		at(p)=t;
	}
	bool move(T)(T v) {
		if(v[0] && v[1]) {
			move(v[0],v[1]);
			last_move=v;
			return 1;
		}
		return 0;
	}

	int rank_move(Move m) {
		return (unit(m.from) == Unit.knight)? rank_spock_move(m) : rank_unit_move(m);
	}
	private int rank_unit_move(Move m) {
		auto mine=side(m.from);
		auto number_of_kings=units_of(mine.opposite).count!(a => unit(a) == Unit.knight);
		auto king_weigth=(number_of_kings > 1)? 5 : 10;
		final switch(unit(m.to)) {
			case Unit.none:   return 0;
			case Unit.pawn:   return 1;
			case Unit.bishop: return 2;
			case Unit.tour:   return 3;
			case Unit.queen:  return 3;
			case Unit.knight: return king_weigth;
		}
	}
	private int rank_spock_move(Move m) {
		auto mine=side(m.from);
		auto number_of_kings=units_of(mine.opposite).count!(a => unit(a) == Unit.knight);
		auto king_weigth=(number_of_kings > 1)? 5 : 10;
		final switch(unit(m.to)) {
			case Unit.none:   return 0;
			case Unit.pawn:   return (side(m.to) == mine)? 1 : 2;
			case Unit.bishop: return (side(m.to) == mine)? 2 : 3;
			case Unit.tour:   return (side(m.to) == mine)? 4 : 5;
			case Unit.queen:  return (side(m.to) == mine)? 2 : 3;
			case Unit.knight: return (side(m.to) == mine)? 0 : king_weigth;
		}
	}


	private cell[] targets_of_pawn(cell p) {
		cell[] r;
		foreach(dp; [dP(-1,1), dP(-1,0),dP(-1,-1),dP(0,1),dP(0,-1),dP(1,-1),dP(1,0),dP(1,1)]) {
			for(auto n=p+dp; n; n=n+dp) {
				if(unit(n) == Unit.none) r~=n;
				if(side(p) == side(n)) continue;
				if(unit(n) == Unit.bishop || unit(n) == Unit.queen) r~=n;
				break;
			}
		}
		return r;
	}

	private cell[] targets_of_bishop(cell p) {
		cell[] r;
		foreach(dp; [dP(-1,-1),dP(-1,1),dP(1,-1),dP(1,1)]) {
			for(auto n=p+dp; n; n=n+dp) {
				if(unit(n) == Unit.none) { r~=n; continue; }
				if(side(p) == side(n)) continue;
				if(unit(n) == Unit.queen || unit(n) == Unit.tour) r~=n;
				break;
			}
		}
		return r;
	}

	private cell[] targets_of_tour(cell p) {
		cell[] r;
		foreach(dp; [dP(-1,0), dP(1,0),dP(0,-1),dP(0,1)]) {
			for(auto n=p+dp; n; n=n+dp) {
				if(unit(n) == Unit.none) { r~=n; continue; }
				if(side(p) == side(n)) continue;
				if(unit(n) == Unit.pawn || unit(n) == Unit.knight) r~=n;
				break;
			}
		}
		return r;
	}

	private cell[] targets_of_queen(cell p) {
		cell[] r;
		foreach(dp; [dP(-1,0), dP(1,0),dP(0,-1),dP(0,1),dP(-1,-1), dP(-1,1),dP(1,-1),dP(1,1)]) {
			for(auto n=p+dp; n; n=n+dp) {
				if(unit(n) == Unit.none) { r~=n; continue; }
				if(side(p) == side(n)) continue;
				if(unit(n) == Unit.tour || unit(n) == Unit.knight) r~=n;
				break;
			}
		}
		return r;
	}

	private cell[] targets_of_knight(cell p) {
		cell[] r;
		foreach(dp; [dP(-1,2), dP(1,2),dP(-1,-2),dP(1,-2),dP(-2,-1), dP(-2,1),dP(2,-1),dP(2,1)]) {
			cell n=p+dp;
			if(!n || unit(n) == Unit.none) continue;
			r~=n;
		}
		return r;
	}

	private static auto init_field() {
		ubyte[SIZE][SIZE] r;
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x)
			r[x][y]=0;

		for(int x=0; x < SIZE; ++x) {
			r[x][SIZE-2]=Unit.pawn|Side.white;
			r[x][1]=Unit.pawn|Side.black;
		}
		r[0][0]=r[SIZE-1][0]=Unit.tour|Side.black;
		r[0][SIZE-1]=r[SIZE-1][SIZE-1]=Unit.tour|Side.white;
		r[1][0]=r[SIZE-2][0]=Unit.bishop|Side.black;
		r[1][SIZE-1]=r[SIZE-2][SIZE-1]=Unit.bishop|Side.white;
		r[2][0]=Unit.knight|Side.black;
		r[SIZE-3][SIZE-1]=Unit.knight|Side.white;
		static if(SIZE == 5) {
			} else static if(SIZE == 6) {
				r[3][0]=Unit.queen|Side.black;
				r[SIZE-4][SIZE-1]=Unit.queen|Side.white;
			} else 
				assert(0, "board size "~to!string(SIZE)~" is not supported");

		return r;
	}

}//Board


