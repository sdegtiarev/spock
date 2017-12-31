import board;
import human;
import ai;


void main(string[] arg)
{
	Human h1;
	AI_3 h2;
	Board board;
	if(arg[0][$-5..$] == "black") {
		h1=new Human(board, Side.black);
		h2=new AI_3(board, Side.white);
	} else {
		h1=new Human(board, Side.white);
		h2=new AI_3(board, Side.black);
	}

	h1.loop((){
		if(h1.dead) h2.terminate;
		if(h2.dead) h1.terminate;
		h1.make_turn;
		h2.make_turn;
	});
}


