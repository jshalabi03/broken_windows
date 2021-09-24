package mech.mania.competitor;

import com.google.gson.GsonBuilder;
import mech.mania.competitor.api.Constants;
import mech.mania.competitor.model.GameState;
import mech.mania.competitor.model.decisions.ActionDecision;
import mech.mania.competitor.model.decisions.MoveDecision;
import mech.mania.competitor.model.ItemType;
import mech.mania.competitor.model.UpgradeType;
import mech.mania.competitor.networking.EngineCommunicator;
import com.google.gson.Gson;

import java.io.IOException;

public class Game {

    private final Gson gson;

    private GameState gameState;

    public Game(ItemType item, UpgradeType upgrade) {
        // tell the engine that the bot can receive game states now
        EngineCommunicator.setGameConstants(new Constants("mm27"));
        EngineCommunicator.sendOut("heartbeat");

        sendItem(item.toString());
        sendUpgrade(upgrade.toString());

        gson = new GsonBuilder().create();
    }

    public void updateGame() throws IOException {
        String gameStateJson = EngineCommunicator.readLine();
        gameState = gson.fromJson(gameStateJson, GameState.class);
        gameState.getPlayer1().setId(1);
        gameState.getPlayer2().setId(2);
    }

    public GameState getGameState() {
        return gameState;
    }

    public void sendItem(String item) {
        EngineCommunicator.sendOut(item);
    }

    public void sendUpgrade(String upgrade) {
        EngineCommunicator.sendOut(upgrade);
    }

    public void sendMoveDecision(MoveDecision decision) {
        EngineCommunicator.sendOut(decision.getEngineReadableString());
    }

    public void sendActionDecision(ActionDecision decision) {
        EngineCommunicator.sendOut(decision.getEngineReadableString());
    }
}
