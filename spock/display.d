module spock.display;
import spock.board;
import spock.icons;
import arsd.simpledisplay;
@property arsd.color.Size size() { return arsd.color.Size(CELL*SIZE+1, CELL*SIZE+1); }


class display
{
	private SimpleWindow window;
	private Sprite[ubyte] icon;
	private Point off;
	private bool reverse;


	this(SimpleWindow window, Point off =Point(0,0), bool reverse =0) {
		this.window=window;
		this.off=off;
		this.reverse=reverse;
		init_icons();
		draw_axes();
	}

	void draw_axes() {
		auto p=window.draw();
		p.outlineColor=Color.black;
		p.fillColor=Color.black;
		char L='A';
		for(int x=0; x < SIZE; ++x, ++L)
			p.drawText(Point(x*CELL+off.x+CELL/2, SIZE*CELL-SIZE+10+off.y), [L]);
		if(reverse) {
			char D='1';
			for(int y=0; y < SIZE; ++y, ++D)
				p.drawText(Point(off.x+SIZE*CELL+8, y*CELL+CELL/2+off.y), [D]);
		} else {
			char D='5';
			for(int y=0; y < SIZE; ++y, --D)
				p.drawText(Point(off.x-16, y*CELL+CELL/2+off.y), [D]);
		}

	}

	void flip() { reverse=!reverse; }

	Board.point inside(int x, int y) {
		if(x <= off.x || y <= off.y) return Board.point(SIZE,SIZE);
		x=(x-off.x)/CELL; y=(y-off.y)/CELL;
		if(x >= SIZE || y >= SIZE) return Board.point(SIZE,SIZE);
		return reverse? Board.point(x, SIZE-1-y) : Board.point(x,y);
	}


	void draw(ref Board board)
	{
		auto painter=window.draw();
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x) {
			auto unit=reverse? board.at(board.point(x,SIZE-1-y)) : board.at(board.point(x,y));
			icon[unit].drawAt(painter, translate(x,y));
		}
		draw_grid();
	}

	Point translate(int x, int y) {
		return Point(x*CELL+off.x, y*CELL+off.y);
	}

	private void draw_grid() {
		auto painter=window.draw();
		painter.outlineColor=Color.black;
		painter.fillColor=Color.black;
		for(int y=0; y <= SIZE; ++y)
			painter.drawLine(translate(0,y), translate(SIZE, y));
		for(int x=0; x <= SIZE; ++x)
			painter.drawLine(translate(x,0), translate(x, SIZE));
	}

	private void init_icons()
	{
		icon[Unit.none|Side.none|Mark.none]=spock.icons.sprite(window, blank);
		icon[Unit.none|Side.none|Mark.targeted]=spock.icons.sprite(window, blank_t);
		icon[Unit.pawn|Side.white|Mark.none]=spock.icons.sprite(window, pawn_w);
		icon[Unit.pawn|Side.black|Mark.none]=spock.icons.sprite(window, pawn_b);
		icon[Unit.pawn|Side.white|Mark.selected]=spock.icons.sprite(window, pawn_ws);
		icon[Unit.pawn|Side.black|Mark.selected]=spock.icons.sprite(window, pawn_bs);
		icon[Unit.pawn|Side.white|Mark.targeted]=spock.icons.sprite(window, pawn_wt);
		icon[Unit.pawn|Side.black|Mark.targeted]=spock.icons.sprite(window, pawn_bt);
		icon[Unit.bishop|Side.white|Mark.none]=spock.icons.sprite(window, bishop_w);
		icon[Unit.bishop|Side.black|Mark.none]=spock.icons.sprite(window, bishop_b);
		icon[Unit.bishop|Side.white|Mark.selected]=spock.icons.sprite(window, bishop_ws);
		icon[Unit.bishop|Side.black|Mark.selected]=spock.icons.sprite(window, bishop_bs);
		icon[Unit.bishop|Side.white|Mark.targeted]=spock.icons.sprite(window, bishop_wt);
		icon[Unit.bishop|Side.black|Mark.targeted]=spock.icons.sprite(window, bishop_bt);
		icon[Unit.tour|Side.white|Mark.none]=spock.icons.sprite(window, tour_w);
		icon[Unit.tour|Side.black|Mark.none]=spock.icons.sprite(window, tour_b);
		icon[Unit.tour|Side.white|Mark.selected]=spock.icons.sprite(window, tour_ws);
		icon[Unit.tour|Side.black|Mark.selected]=spock.icons.sprite(window, tour_bs);
		icon[Unit.tour|Side.white|Mark.targeted]=spock.icons.sprite(window, tour_wt);
		icon[Unit.tour|Side.black|Mark.targeted]=spock.icons.sprite(window, tour_bt);
		icon[Unit.queen|Side.white|Mark.none]=spock.icons.sprite(window, queen_w);
		icon[Unit.queen|Side.black|Mark.none]=spock.icons.sprite(window, queen_b);
		icon[Unit.queen|Side.white|Mark.selected]=spock.icons.sprite(window, queen_ws);
		icon[Unit.queen|Side.black|Mark.selected]=spock.icons.sprite(window, queen_bs);
		icon[Unit.queen|Side.white|Mark.targeted]=spock.icons.sprite(window, queen_wt);
		icon[Unit.queen|Side.black|Mark.targeted]=spock.icons.sprite(window, queen_bt);
		icon[Unit.knight|Side.white|Mark.none]=spock.icons.sprite(window, spock_w);
		icon[Unit.knight|Side.black|Mark.none]=spock.icons.sprite(window, spock_b);
		icon[Unit.knight|Side.white|Mark.selected]=spock.icons.sprite(window, spock_ws);
		icon[Unit.knight|Side.black|Mark.selected]=spock.icons.sprite(window, spock_bs);
		icon[Unit.knight|Side.white|Mark.targeted]=spock.icons.sprite(window, spock_wt);
		icon[Unit.knight|Side.black|Mark.targeted]=spock.icons.sprite(window, spock_bt);
	}

}

