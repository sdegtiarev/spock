import arsd.simpledisplay;
import icons;
import std.conv;
import std.traits;
import std.stdio;
immutable int CELL=64;
immutable int N=5;
immutable int L=CELL*N+1;

immutable ubyte WHITE=0x00;
immutable ubyte BLACK=0x08;
immutable ubyte TARGETED=0x20;
immutable ubyte SELECTED=0x10;


alias Board=ubyte[N][N];



void main(string[] arg) {
	bool turn=1;
	auto window=new SimpleWindow(Size(L, L), "spock");
	auto b=board();
	Sprite[ubyte] chm=chessmen(window);
	draw_board(window, b, chm, turn);



	window.eventLoop(0
		, (KeyEvent event) { do_nothing(window); }
		, (MouseEvent event) {
			if(event.type == MouseEventType.buttonPressed) {
				handleClick(b, at(event.x, event.y, turn), turn);
				draw_board(window, b, chm, turn);
			}
		}
		, (dchar ch) {
			if(ch == 17) window.close;
		}
	);
}

point at(int x, int y, bool turn) {
	if(turn)
		return point(x/CELL, y/CELL);
	else
		return point(x/CELL, N-1-y/CELL);
}

struct point {
	ubyte x,y;
	this(T)(T a, T b) if(isIntegral!T) { x=cast(ubyte) a; y=cast(ubyte) b; }
	bool opCast(T)() if(is(T == bool)) { return x < N && y < N; }
	auto toString() { return "("~to!string(x)~", "~to!string(y)~")"; }
	point opBinary(string op)(dP d) { return point(mixin("x"~op~"d.x"), mixin("y"~op~"d.y")); }
}
struct dP { int x, y; }


void handleClick(ref Board b, point t, ref bool turn)
{
	auto p=selected(b);
	if(p) {
		if(p == t)
			unselect(b);
		else if(is_targeted(b, t)) {
			unselect(b);
			move(b,p,t);
			turn=!turn;
		}
	} else if(mark_targets(b, t))
		select(b,t);
}

void select(ref Board b, point p)
{
	b[p.x][p.y] |=SELECTED;
}

void move(ref Board b, point p, point n) {
	ubyte t=0;
	if(figure(b,p) == 5) {
		t=incarnate(figure(b,n));
		t |=color(b,p);
	}
	b[n.x][n.y]=b[p.x][p.y];
	b[p.x][p.y]=t;
}


void unselect(ref Board b)
{
	for(int y=0; y < N; ++y)
	for(int x=0; x < N; ++x)
		b[x][y]&=~(TARGETED|SELECTED);
}

point selected(ref Board b)
{
	for(ubyte y=0; y < N; ++y)
	for(ubyte x=0; x < N; ++x)
		if(b[x][y] & SELECTED) return point(x,y);
	return point(N,N);
}

bool is_targeted(ref Board b, point p)
{
	return p && b[p.x][p.y] & TARGETED;
}
void target(ref Board b, point p)
{
	b[p.x][p.y] |=TARGETED;
}

ubyte figure(ref Board b, point p) { return b[p.x][p.y] & 0x07; }
ubyte color(ref Board b, point p) { return b[p.x][p.y] & BLACK; }
bool empty(ref Board b, point p) { return figure(b,p) == 0; }
ubyte incarnate(ubyte x) {
	switch(x) {
		case 1: return 2;
		case 2: return 4;
		case 4: return 3;
		case 3: return 5;
		case 5: return 1;
		default: return 0;
	}
}
bool pawnable(ref Board b, point p) {
	return figure(b,p) == 2 || figure(b,p) == 4;
}
bool bishopable(ref Board b, point p) {
	return figure(b,p) == 3 || figure(b,p) == 4;
}
bool tourable(ref Board b, point p) {
	return figure(b,p) == 1 || figure(b,p) == 5;
}
bool queenable(ref Board b, point p) {
	return figure(b,p) == 3 || figure(b,p) == 5;
}


bool mark_targets(ref Board b, point p)
{
	switch(figure(b, p)) {
		case 1: return target_pawn(b, p);
		case 2: return target_bishop(b, p);
		case 3: return target_tour(b, p);
		case 4: return target_queen(b, p);
		case 5: return target_spock(b, p);
		case 0: 
		default: break;
	}
	return 0;
}

bool target_pawn(ref Board b, point p)
{
	bool has_move=0;
	foreach(dp; [dP(-1,1), dP(-1,0),dP(-1,-1),dP(0,1),dP(0,-1),dP(1,-1),dP(1,0),dP(1,1)]) {
		for(auto n=p+dp; n; n=n+dp) {
			if(empty(b,n)) { target(b,n); has_move=1; continue; }
			if(color(b,p) == color(b,n)) continue;
			if(pawnable(b,n)) { target(b,n); has_move=1; }
			break;
		}
	}
	return has_move;
}

bool target_bishop(ref Board b, point p)
{
	bool has_move=0;
	foreach(dp; [dP(-1,-1), dP(-1,1),dP(1,-1),dP(1,1)]) {
		for(auto n=p+dp; n; n=n+dp) {
			if(empty(b,n)) { target(b,n); has_move=1; continue; }
			if(color(b,p) == color(b,n)) continue;
			if(bishopable(b,n)) { target(b,n); has_move=1; }
			break;
		}
	}
	return has_move;
}

bool target_tour(ref Board b, point p)
{
	bool has_move=0;
	foreach(dp; [dP(-1,0), dP(1,0),dP(0,-1),dP(0,1)]) {
		for(auto n=p+dp; n; n=n+dp) {
			if(empty(b,n)) { target(b,n); has_move=1; continue; }
			if(color(b,p) == color(b,n)) continue;
			if(tourable(b,n)) { target(b,n); has_move=1; }
			break;
		}
	}
	return has_move;
}

bool target_queen(ref Board b, point p)
{
	bool has_move=0;
	foreach(dp; [dP(-1,0), dP(1,0),dP(0,-1),dP(0,1),dP(-1,-1), dP(-1,1),dP(1,-1),dP(1,1)]) {
		for(auto n=p+dp; n; n=n+dp) {
			if(empty(b,n)) { target(b,n); has_move=1; continue; }
			if(color(b,p) == color(b,n)) continue;
			if(queenable(b,n)) { target(b,n); has_move=1; }
			break;
		}
	}
	return has_move;
}

bool target_spock(ref Board b, point p)
{
	bool has_move=0;
	foreach(dp; [dP(-1,2), dP(1,2),dP(-1,-2),dP(1,-2),dP(-2,-1), dP(-2,1),dP(2,-1),dP(2,1)]) {
		point n=p+dp;
		if(!n || empty(b,n)) continue;
		target(b,n);
		has_move=1;
	}
	return has_move;
}



Sprite[ubyte] chessmen(SimpleWindow w)
{
	Sprite[ubyte] r;
	r[0]=icon(w, blank);
	r[0|TARGETED]=icon(w, blank_t);
	r[1|WHITE]=icon(w, pawn_w);
	r[1|BLACK]=icon(w, pawn_b);
	r[1|WHITE|SELECTED]=icon(w, pawn_ws);
	r[1|BLACK|SELECTED]=icon(w, pawn_bs);
	r[1|WHITE|TARGETED]=icon(w, pawn_wt);
	r[1|BLACK|TARGETED]=icon(w, pawn_bt);
	r[2|WHITE]=icon(w, bishop_w);
	r[2|BLACK]=icon(w, bishop_b);
	r[2|WHITE|SELECTED]=icon(w, bishop_ws);
	r[2|BLACK|SELECTED]=icon(w, bishop_bs);
	r[2|WHITE|TARGETED]=icon(w, bishop_wt);
	r[2|BLACK|TARGETED]=icon(w, bishop_bt);
	r[3|WHITE]=icon(w, tour_w);
	r[3|BLACK]=icon(w, tour_b);
	r[3|WHITE|SELECTED]=icon(w, tour_ws);
	r[3|BLACK|SELECTED]=icon(w, tour_bs);
	r[3|WHITE|TARGETED]=icon(w, tour_wt);
	r[3|BLACK|TARGETED]=icon(w, tour_bt);
	r[4|WHITE]=icon(w, queen_w);
	r[4|BLACK]=icon(w, queen_b);
	r[4|WHITE|SELECTED]=icon(w, queen_ws);
	r[4|BLACK|SELECTED]=icon(w, queen_bs);
	r[4|WHITE|TARGETED]=icon(w, queen_wt);
	r[4|BLACK|TARGETED]=icon(w, queen_bt);
	r[5|WHITE]=icon(w, spock_w);
	r[5|BLACK]=icon(w, spock_b);
	r[5|WHITE|SELECTED]=icon(w, spock_ws);
	r[5|BLACK|SELECTED]=icon(w, spock_bs);
	r[5|WHITE|TARGETED]=icon(w, spock_wt);
	r[5|BLACK|TARGETED]=icon(w, spock_bt);

	return r;
}


Board board()
{
	Board r;
	for(int x=0; x < N; ++x) {
		r[x][1]=1|WHITE;
		r[x][N-2]=1|BLACK;
	}
	r[0][0]=r[N-1][0]=3|WHITE;
	r[0][N-1]=r[N-1][N-1]=3|BLACK;
	r[1][0]=r[N-2][0]=2|WHITE;
	r[1][N-1]=r[N-2][N-1]=2|BLACK;
	r[2][0]=5|WHITE;
	r[2][N-1]=5|BLACK;

	return r;
}



void do_nothing(SimpleWindow window) {}

void draw_board(SimpleWindow window, Board board, Sprite[ubyte] chm, bool turn)
{
	auto painter=window.draw();
	for(int y=0; y < N; ++y)
	for(int x=0; x < N; ++x) {
		//chm[board[x][y]].drawAt(painter, Point(x*CELL,y*CELL));
		if(turn)
			chm[board[x][y]].drawAt(painter, Point(x*CELL,y*CELL));
		else
			chm[board[x][N-1-y]].drawAt(painter, Point(x*CELL,y*CELL));
	}
	draw_grid(window);
}

void draw_grid(SimpleWindow window) {
	auto painter=window.draw();
	painter.outlineColor=Color.black;
	painter.fillColor=Color.black;
	for(int y=0; y < L; y+=CELL)
		painter.drawLine(Point(0,y), Point(window.width, y));
	for(int x=0; x < L; x+=CELL)
		painter.drawLine(Point(x,0), Point(x, window.height));
}


