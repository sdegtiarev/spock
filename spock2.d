import board;
import human;
import ai;
import std.stdio;


void main(string[] arg)
{
	auto board=new Board();
	auto h1=new Human(board, Side.white);
	auto h2=new AI_2(board, Side.black);

	h1.loop((){
		if(h1.dead) h2.terminate;
		if(h2.dead) h1.terminate;
		h1.make_turn;
		h2.make_turn;
	});
}


