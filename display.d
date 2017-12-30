module display;
import board;
import icons;
import arsd.simpledisplay;
immutable int MARGIN=24;
alias CELL=board.CELL;


SpockDisplay display() {
	auto window=new SimpleWindow(SpockDisplay.size, "spock");
	return new SpockDisplay(window, Point(MARGIN,MARGIN));
}

class SpockDisplay
{
	static @property arsd.color.Size size() {
		return arsd.color.Size(Board.pixels+2*MARGIN, Board.pixels+2*MARGIN);
	}
	SimpleWindow window;
	private Sprite[ubyte] icon;
	private Point off;
	private bool reverse;

	SpockDisplay flip() { reverse=!reverse; return this; }

	this(SimpleWindow window, Point off) {
		this.window=window;
		this.off=off;
		this.reverse=0;
		init_icons();
	}

	Board.cell inside(int x, int y) {
		if(x <= off.x || y <= off.y) return Board.cell(SIZE,SIZE);
		x=(x-off.x)/CELL; y=(y-off.y)/CELL;
		if(x >= SIZE || y >= SIZE) return Board.cell(SIZE,SIZE);
		return reverse? Board.cell(x, SIZE-1-y) : Board.cell(x,y);
	}


	void draw(ref Board board)
	{
		auto painter=window.draw();
		for(int y=0; y < SIZE; ++y)
		for(int x=0; x < SIZE; ++x) {
			auto p=reverse? Board.cell(x,SIZE-1-y) : Board.cell(x,y);
			auto unit=board.at(p);
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
		icon[Unit.none|Side.none|Mark.none]=icons.sprite(window, blank);
		icon[Unit.none|Side.none|Mark.targeted]=icons.sprite(window, blank_t);
		icon[Unit.pawn|Side.white|Mark.none]=icons.sprite(window, pawn_w);
		icon[Unit.pawn|Side.black|Mark.none]=icons.sprite(window, pawn_b);
		icon[Unit.pawn|Side.white|Mark.selected]=icons.sprite(window, pawn_ws);
		icon[Unit.pawn|Side.black|Mark.selected]=icons.sprite(window, pawn_bs);
		icon[Unit.pawn|Side.white|Mark.targeted]=icons.sprite(window, pawn_wt);
		icon[Unit.pawn|Side.black|Mark.targeted]=icons.sprite(window, pawn_bt);
		icon[Unit.bishop|Side.white|Mark.none]=icons.sprite(window, bishop_w);
		icon[Unit.bishop|Side.black|Mark.none]=icons.sprite(window, bishop_b);
		icon[Unit.bishop|Side.white|Mark.selected]=icons.sprite(window, bishop_ws);
		icon[Unit.bishop|Side.black|Mark.selected]=icons.sprite(window, bishop_bs);
		icon[Unit.bishop|Side.white|Mark.targeted]=icons.sprite(window, bishop_wt);
		icon[Unit.bishop|Side.black|Mark.targeted]=icons.sprite(window, bishop_bt);
		icon[Unit.tour|Side.white|Mark.none]=icons.sprite(window, tour_w);
		icon[Unit.tour|Side.black|Mark.none]=icons.sprite(window, tour_b);
		icon[Unit.tour|Side.white|Mark.selected]=icons.sprite(window, tour_ws);
		icon[Unit.tour|Side.black|Mark.selected]=icons.sprite(window, tour_bs);
		icon[Unit.tour|Side.white|Mark.targeted]=icons.sprite(window, tour_wt);
		icon[Unit.tour|Side.black|Mark.targeted]=icons.sprite(window, tour_bt);
		icon[Unit.queen|Side.white|Mark.none]=icons.sprite(window, queen_w);
		icon[Unit.queen|Side.black|Mark.none]=icons.sprite(window, queen_b);
		icon[Unit.queen|Side.white|Mark.selected]=icons.sprite(window, queen_ws);
		icon[Unit.queen|Side.black|Mark.selected]=icons.sprite(window, queen_bs);
		icon[Unit.queen|Side.white|Mark.targeted]=icons.sprite(window, queen_wt);
		icon[Unit.queen|Side.black|Mark.targeted]=icons.sprite(window, queen_bt);
		icon[Unit.knight|Side.white|Mark.none]=icons.sprite(window, spock_w);
		icon[Unit.knight|Side.black|Mark.none]=icons.sprite(window, spock_b);
		icon[Unit.knight|Side.white|Mark.selected]=icons.sprite(window, spock_ws);
		icon[Unit.knight|Side.black|Mark.selected]=icons.sprite(window, spock_bs);
		icon[Unit.knight|Side.white|Mark.targeted]=icons.sprite(window, spock_wt);
		icon[Unit.knight|Side.black|Mark.targeted]=icons.sprite(window, spock_bt);
	}

}

