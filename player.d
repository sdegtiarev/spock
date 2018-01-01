module spock.player;
import spock.board;

class Player
{
	protected Side mine;

	this(Side side) {
		this.mine=side;
	}

	abstract void make_turn();

	// these three are not made abstract and make sence for all AI players
	//   are to ve overriden for human players to notify and tobe notified
	//   of partner's window closed
	@property bool dead() { return false; }
	void terminate() { }
	void loop(void delegate()) { }
}
