import spock.board;
import spock.display;
import arsd.simpledisplay;


void main(string[] arg) {
	auto sz=Size(spock.display.size.width+24, spock.display.size.height+24);
	auto window=new SimpleWindow(sz, "spock");
	auto d1=new display(window, Point(24, 0));
	auto b=new Board();
	d1.draw(b);

	void handle_title() {
		if(b.winner == Side.white) window.title("Whites win");
		else if(b.winner == Side.black) window.title("Blacks win");
		else if(b.turn == Side.white) window.title("Whites turn");
		else if(b.turn == Side.black) window.title("Blacks turn");
	}

	int ex=-1;
	void handle_key(dchar ch) {
		import std.stdio;
		switch(ch) {
			case 17: window.close; break;
			case 14: b.reset; d1.draw(b); window.title("spock"); break;
			case 27: b.unselect; d1.draw(b); ex=-1; break;
			case 'a': case 'b': case 'c': case 'd': case 'e': ex=ch-'a'; break;
			case '1': case '2': case '3': case '4': case '5':
				if(ex >= 0) {
					b.click(Board.point(ex, SIZE-ch+'0'));
					d1.draw(b);
					ex=-1;
					handle_title();
				}
				break;
			default: //writeln("key ", ch, " (", cast(int) ch, ")");
		}
	}

	void handle_mouse(MouseEvent event) {
		if(event.type == MouseEventType.buttonPressed) {
			auto p=d1.inside(event.x, event.y);
			if(!p) return;

			b.click(p);
			d1.draw(b);
			if(b.turn == Side.black) {
				black_move(b, d1);
				b.turn=Side.white;
			}
			handle_title();
		}
	}

	handle_title;
	window.eventLoop(0
		, (MouseEvent event) { handle_mouse(event); }
		, (dchar ch) { handle_key(ch); }
	);
}


void black_move(Board b, display d)
{
	import std.stdio;
	for(int y=0; y < SIZE; ++y)
	for(int x=0; x < SIZE; ++x) {
		auto p=Board.point(x,y);
		if(b.side(p) == Side.black) {
			write(b.unit(p)," ",cast(char)('A'+x),cast(char)('1'+SIZE-1-y)," > ");
			b.select(p);
			b.find_targets(p);
			d.draw(b);
			stdin.readln;
			b.unselect;
			d.draw(b);
		}
	}
	writeln("next turn");
}
