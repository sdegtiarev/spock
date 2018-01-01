import spock.board;
import spock.human;
import spock.ai.l3;


void main(string[] arg)
{
	Board!6 board;
	auto h1=human(board, Side.white);
	auto h2=spock.ai.l3.player(board, Side.black);

	h1.loop((){
		if(h1.dead) h2.terminate;
		if(h2.dead) h1.terminate;
		h1.make_turn;
		h2.make_turn;
	});
}


