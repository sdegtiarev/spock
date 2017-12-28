module spock.board;
import arsd.simpledisplay;
import arsd.color;
import spock.icons;
import std.conv;
import std.traits;

immutable ubyte SIZE=5;
enum Side : ubyte { none=0, white=0x08, black=0x10 }
enum Mark : ubyte { none=0, selected=0x20, targeted=0x40 }
enum Unit : ubyte { none=0, pawn=1, bishop=2, queen=3, tour=4, knight=5 }
@property arsd.color.Size pixels() { return arsd.color.Size(CELL*SIZE+1, CELL*SIZE+1); }


class Board
{
	private ubyte[SIZE][SIZE] field;
	private point selection=point(SIZE,SIZE);
	Side turn=Side.white, winner=Side.none;


	this() {
		init_field();
	}

	void reset() {
		turn=Side.white;
		winner=Side.none;
		init_field();
	}


	ref ubyte at(point p) { return field[p.x][p.y]; }
	ubyte at(point p) const { return field[p.x][p.y]; }


	void click(point p) {
		if(winner != Side.none)
			return;
		if(!p) return;
		if(selection) {
			if(selection == p)
				unselect;
			else if(targeted(p))
				move(selection, p);
		} else if(find_targets(p)) 
			select(p);
	}

	void move(point p, point n) {
		ubyte t=(unit(p) == Unit.knight)? reincarnate(unit(n))|side(p) : 0;
		at(n)=at(p);
		at(p)=t;
		unselect;
		if(check_winner)
			return;
		turn=(turn == Side.white)? Side.black : Side.white;
	}

	private Side check_winner() {
		int white_knights=0, black_knights=0;
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x) {
			auto p=point(x,y);
			if(unit(p) == Unit.knight) {
				if(side(p) == Side.white) ++white_knights;
				if(side(p) == Side.black) ++black_knights;
			}
		}
		if(!white_knights) return winner=Side.black;
		if(!black_knights) return winner=Side.white;
		return Side.none;
	}


	bool find_targets(point p) {
		if(unit(p) == Unit.none) return false;
		if(side(p) != turn) return false;
		bool has_move=0;

		if(unit(p) == Unit.pawn) {
			foreach(dp; [dP(-1,1), dP(-1,0),dP(-1,-1),dP(0,1),dP(0,-1),dP(1,-1),dP(1,0),dP(1,1)]) {
				for(auto n=p+dp; n; n=n+dp) {
					if(empty(n)) { at(n) |= Mark.targeted; has_move=1; break; }
					if(side(p) == side(n)) continue;
					if(unit(n) == Unit.bishop || unit(n) == Unit.queen) {
						at(n) |= Mark.targeted;
						has_move=1;
					}
					break;
				}
			}
		} else if(unit(p) == Unit.bishop) {
			foreach(dp; [dP(-1,-1), dP(-1,1),dP(1,-1),dP(1,1)]) {
				for(auto n=p+dp; n; n=n+dp) {
					if(empty(n)) { at(n) |= Mark.targeted; has_move=1; continue; }
					if(side(p) == side(n)) continue;
					if(unit(n) == Unit.queen || unit(n) == Unit.tour) {
						at(n) |= Mark.targeted;
						has_move=1;
					}
					break;
				}
			}
		} else if(unit(p) == Unit.tour) {
			foreach(dp; [dP(-1,0), dP(1,0),dP(0,-1),dP(0,1)]) {
				for(auto n=p+dp; n; n=n+dp) {
					if(empty(n)) { at(n) |= Mark.targeted; has_move=1; continue; }
					if(side(p) == side(n)) continue;
					if(unit(n) == Unit.pawn || unit(n) == Unit.knight) {
						at(n) |= Mark.targeted;
						has_move=1;
					}
					break;
				}
			}
		} else if(unit(p) == Unit.queen) {
			foreach(dp; [dP(-1,0), dP(1,0),dP(0,-1),dP(0,1),dP(-1,-1), dP(-1,1),dP(1,-1),dP(1,1)]) {
				for(auto n=p+dp; n; n=n+dp) {
					if(empty(n)) { at(n) |= Mark.targeted; has_move=1; continue; }
					if(side(p) == side(n)) continue;
					if(unit(n) == Unit.tour || unit(n) == Unit.knight) {
						at(n) |= Mark.targeted;
						has_move=1;
					}
					break;
				}
			}
		} else if(unit(p) == Unit.knight) {
			foreach(dp; [dP(-1,2), dP(1,2),dP(-1,-2),dP(1,-2),dP(-2,-1), dP(-2,1),dP(2,-1),dP(2,1)]) {
				point n=p+dp;
				if(!n || empty(n)) continue;
				at(n) |= Mark.targeted;
				has_move=1;
			}
		}

		return has_move;
	}


	private bool targeted(point p) { return cast(bool) (at(p) & Mark.targeted); }

	Unit unit(point p) { return cast(Unit) (at(p) & 0x07); }

	private Unit reincarnate(Unit x) {
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
	Side side(point p) { return cast(Side) (at(p) & (Side.black|Side.white)); }
	private bool empty(point p) { return unit(p) == Unit.none; }

	private @property point invalid() { return point(SIZE,SIZE); }

	void select(point p) {
		selection=p;
		at(selection) |=Mark.selected;
	}
	void unselect() {
		selection=invalid;
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x)
			field[x][y] &=~(Mark.selected|Mark.targeted);
	}



	private void init_field() {
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x)
			field[x][y]=0;
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


	struct point {
		ubyte x,y;
		this(T)(T a, T b) if(isIntegral!T) { x=cast(ubyte) a; y=cast(ubyte) b; }
		bool opCast(T)() if(is(T == bool)) { return x < SIZE && y < SIZE; }
		point opBinary(string op)(dP d) { return point(mixin("x"~op~"d.x"), mixin("y"~op~"d.y")); }
		void opOpAssign(string op)(dP d) { mixin("x"~op~"=d.x"); mixin("y"~op~"=d.y"); }
		auto toString() { return "("~to!string(x)~", "~to!string(y)~")"; }
	}
	struct dP { int x, y; }
}
