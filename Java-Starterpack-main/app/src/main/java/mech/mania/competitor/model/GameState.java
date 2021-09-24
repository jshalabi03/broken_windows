package mech.mania.competitor.model;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class GameState {
    private int turn;
    @SerializedName("p1")
    private Player player1;
    @SerializedName("p2")
    private Player player2;
    private TileMap tileMap;
    private int playerNum;

    private List<String> feedback;

    public int getTurn() {
        return turn;
    }

    public TileMap getTileMap() {
        return tileMap;
    }

    public Player getPlayer1() {
        return player1;
    }

    public Player getPlayer2() {
        return player2;
    }

    public Player getMyPlayer() {
        if (playerNum == 1) {
            return player1;
        }
        return player2;
    }

    public Player getOpponentPlayer() {
        if (playerNum == 1) {
            return player2;
        }
        return player1;
    }

    public List<String> getFeedback() {
        return feedback;
    }
}
