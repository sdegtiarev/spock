module board;
import std.conv;
import std.traits;
import std.algorithm;
import std.algorithm;
import std.exception;

immutable ubyte SIZE=5;
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



class Board
{
static @property int pixels() { return CELL*SIZE+1; }
	struct point {
		ubyte x,y;
		this(T)(T a, T b) if(isIntegral!T) { x=cast(ubyte) a; y=cast(ubyte) b; }
		bool opCast(T)() if(is(T == bool)) { return x < SIZE && y < SIZE; }
		point opBinary(string op)(dP d) { return point(mixin("x"~op~"d.x"), mixin("y"~op~"d.y")); }
		void opOpAssign(string op)(dP d) { mixin("x"~op~"=d.x;"); mixin("y"~op~"=d.y;"); }
		//auto toString() { return "("~to!string(x)~", "~to!string(y)~")"; }
		auto toString() { return to!string(cast(char)(x+'A'))~to!string(cast(char)('0'+SIZE-y)); }
	}
	struct dP { int x, y; }
	private struct rangeCells {
		private int x=0, y=0;
		point front() { return point(x,y); }
		bool empty() const { return x >= SIZE && y >= SIZE; }
		void popFront() {
			if(empty) return;
			if(++x >= SIZE) {
				x=0;
				if(++y >= SIZE) { x=SIZE; y=SIZE; }
			}
		}
	}


	private ubyte[SIZE][SIZE] field;
	private Side player_turn=Side.white;

	void lock(Side side) { player_turn=side; }
	@property Side turn() { return player_turn; }
	static auto cells() { return rangeCells(); }


	this() { reset; }

	Board dup() {
		auto x=new Board;
		x.field[]=this.field;
		x.player_turn=this.player_turn;
		return x;
	}

	void reset() { init_field(); player_turn=Side.white; }

	ref ubyte at(point p) { return field[p.x][p.y]; }
	ubyte at(point p) const { return field[p.x][p.y]; }

	Unit unit(point p) const { return cast(Unit) (at(p) & 0x07); }
	Side side(point p) const { return cast(Side) (at(p) & (Side.black|Side.white)); }
	bool selected(point p) const { return cast(bool) (at(p) & Mark.selected); }
	bool targeted(point p) const { return cast(bool) (at(p) & Mark.targeted); }
	bool empty(point p)    const { return unit(p) == Unit.none; }

	void select(point p) { at(p) |=Mark.selected; }
	void target(point p) { at(p) |=Mark.targeted; }
	void unselect(point p) { at(p) &=~(Mark.selected|Mark.targeted); }
	void unselect() {
		for(int y=0; y < SIZE; ++y)
		for(auto p=point(0,y); p; p+=dP(1,0))
			unselect(p);
	}



	void move(point p, point n) {
		enforce(p, "invalid move from ("~to!string(p.x)~","~to!string(p.y)~")-("~to!string(n.x)~"-"~to!string(n.y)~")");
		enforce(n, "invalid move to "~p.toString~"-"~n.toString);
		ubyte t=(unit(p) == Unit.knight)? reincarnate(unit(n))|side(p) : 0;
		at(n)=at(p);
		at(p)=t;
	}
	void move(T)(T v) { move(v[0],v[1]); }


	auto units_of(Side player) {
		return Board.cells.filter!(a => side(a) == player);
	}

	point[] targets_of(point p) {
		switch(unit(p)) {
			case Unit.pawn: return targets_of_pawn(p);
			case Unit.bishop: return targets_of_bishop(p);
			case Unit.tour: return targets_of_tour(p);
			case Unit.queen: return targets_of_queen(p);
			case Unit.knight: return targets_of_knight(p);
			default: assert(0, "invalid target");
		}
	}

	private point[] targets_of_pawn(point p) {
		point[] r;
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

	private point[] targets_of_bishop(point p) {
		point[] r;
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

	private point[] targets_of_tour(point p) {
		point[] r;
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

	private point[] targets_of_queen(point p) {
		point[] r;
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

	private point[] targets_of_knight(point p) {
		point[] r;
		foreach(dp; [dP(-1,2), dP(1,2),dP(-1,-2),dP(1,-2),dP(-2,-1), dP(-2,1),dP(2,-1),dP(2,1)]) {
			point n=p+dp;
			if(!n || unit(n) == Unit.none) continue;
			r~=n;
		}
		return r;
	}

	private void init_field() {
		foreach(p; Board.cells)
			at(p)=0;
		for(int x=0; x < SIZE; ++x) {
			field[x][SIZE-2]=Unit.pawn|Side.white;
			field[x][1]=Unit.pawn|Side.black;
		}
		field[0][0]=field[SIZE-1][0]=Unit.tour|Side.black;
		field[0][SIZE-1]=field[SIZE-1][SIZE-1]=Unit.tour|Side.white;
		field[1][0]=field[SIZE-2][0]=Unit.bishop|Side.black;
		field[1][SIZE-1]=field[SIZE-2][SIZE-1]=Unit.bishop|Side.white;
		field[2][0]=Unit.knight|Side.black;
		field[2][SIZE-1]=Unit.knight|Side.white;
	}


}
