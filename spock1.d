import board;
import human;
import ai;


void main(string[] arg)
{
	Board!5 board;
	auto h1=human.human(board, Side.white);
	auto h2=ai.player_1(board, Side.black);

	h1.loop((){
		if(h1.dead) h2.terminate;
		if(h2.dead) h1.terminate;
		h1.make_turn;
		h2.make_turn;
	});
}


