import spock.board;
import spock.player;
import spock.human;
import spock.ai.l1;
import spock.ai.l2;
import spock.ai.l3;
import spock.ai.l4;
import local.getopt;
import std.algorithm;
import std.typecons;
import std.stdio;


enum Level { ive, i1, i2, i3, i4 };

void main(string[] arg)
{
	Side mine=Side.white;
	bool xfield=0;
	Level mode=Level.i3;
	bool help=0;

	Option[] opt;
	auto r=getopt(opt, arg
		, noThrow.yes
		, "-w", "play white", (){ mine=Side.white; }
		, "-b", "play black", (){ mine=Side.black; }

		, "-5", "play 5 cells field", &xfield, false
		, "-6", "play 6 cells field", &xfield, true

		, "-l", "-live - two players game", &mode
		, "-a", "game level: -ai1, -ai2 -ai3, -ai4", &mode

		, "-h", "this help", &help
	);
	if(r) {
		writeln("getopt: ",r.msg);
		return;
	}
	if(help) {
		writeln("Spock chess game\nOptions:\n"
			,optionHelp(sort!("a.group < b.group || a.group == b.group && a.tag < b.tag")(opt))
		);
		return;
	}

	auto player=xfield? game!6(mode, mine) : game!5(mode, mine);
	player.human.loop(() {
		if(player.human.dead) player.ai.terminate;
		if(player.ai.dead) player.human.terminate;
		player.human.make_turn;
		player.ai.make_turn;
	});

}


auto game(int SIZE)(Level level, Side mine) {
	auto board=new Board!SIZE;
	auto me=human(board, mine);
	Player ai;
	final switch(level) {
		case Level.ive: ai=human!SIZE(board, mine.opposite); break;
		case Level.i1: ai=spock.ai.l1.player(board, mine.opposite); break;
		case Level.i2: ai=spock.ai.l2.player(board, mine.opposite); break;
		case Level.i3: ai=spock.ai.l3.player(board, mine.opposite); break;
		case Level.i4: ai=spock.ai.l4.player(board, mine.opposite); break;
	}
	return tuple!("human","ai")(me,ai);
}
