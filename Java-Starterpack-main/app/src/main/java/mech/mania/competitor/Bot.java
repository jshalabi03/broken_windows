package mech.mania.competitor;

import mech.mania.competitor.api.Constants;
import mech.mania.competitor.api.GameUtil;
import mech.mania.competitor.model.*;
import mech.mania.competitor.model.decisions.*;

import mech.mania.competitor.networking.Logger;

import java.io.IOException;
import java.util.*;

/**
 * Class that runs the game.
 */
public class Bot {

    private static final Constants constants = new Constants();
    private static final Logger logger = new Logger();
    private static final Random rand = new Random();

    /**
     * Returns a move decision for the turn given the current game state.
     * This is part 1 of 2 of the turn.
     *
     * Remember, you can only sell crops once you get to a Green Grocer tile,
     * and you can only harvest or plant within your harvest or plant radius.
     *
     * After moving (and submitting the move decision), you will be given a new
     * game state with both players in their updated positions.
     *
     * @param game The object that contains the game state and other related information
     * @return MoveDecision A location for the bot to move to this turn
     */
    private static MoveDecision getMoveDecision(Game game) {
        GameState gameState = game.getGameState();
        logger.debug(String.format("[Turn %d] Feedback received from engine: [%s]",
                gameState.getTurn(),
                String.join(", ", gameState.getFeedback())));

        // Select your decision here!
        Player myPlayer = gameState.getMyPlayer();
        MoveDecision decision;
        Position pos = myPlayer.getPosition();

        if (Math.random() < 0.5 && (myPlayer.getSeedInventory().isEmpty() || !myPlayer.getHarvestedInventory().isEmpty())) {
            // If we have something to sell that we harvested, then try to move towards the green grocer tiles
            logger.debug("Moving towards green grocer");
            decision = new MoveDecision(new Position(constants.BOARD_WIDTH / 2, Math.max(0, pos.getY() - constants.MAX_MOVEMENT)));
        } else {
            // If not, then move randomly within the range of locations we can move to
            List<Position> possiblePositions = GameUtil.withinMoveRange(gameState, myPlayer.getName());

            pos = possiblePositions.get(rand.nextInt(possiblePositions.size()));
            logger.debug("Moving randomly");
            decision = new MoveDecision(pos);
        }

        logger.debug(String.format("[Turn %d] Sending MoveDecision: %s",
                gameState.getTurn(), decision));
        return decision;
    }

    /**
     * Returns an action decision for the turn given the current game state.
     * This is part 2 of 2 of the turn.
     *
     * There are multiple action decisions that you can return here: BuyDecision,
     * HarvestDecision, PlantDecision, or UseItemDecision.
     *
     * After this action, the next turn will begin.
     *
     * @param game The object that contains the game state and other related information
     * @return ActionDecision A decision for the bot to make this turn
     */
    private static ActionDecision getActionDecision(Game game) {
        GameState gameState = game.getGameState();
        logger.debug(String.format("[Turn %d] Feedback received from engine: [%s]",
                gameState.getTurn(),
                String.join(", ", gameState.getFeedback())));

        // Select your decision here!
        Player myPlayer = gameState.getMyPlayer();
        Position pos = myPlayer.getPosition();
        ActionDecision decision;

        // Let the crop of focus be the one we have a seed for, if not just choose a random crop
        CropType crop;
        if (!myPlayer.getSeedInventory().isEmpty()) {
            crop = Collections.max(myPlayer.getSeedInventory().entrySet(), (entry1, entry2) -> entry1.getValue() - entry2.getValue()).getKey();
        } else {
            crop = CropType.values()[rand.nextInt(CropType.values().length)];
        }

        // Get a list of possible harvest locations for our harvest radius
        ArrayList<Position> possibleHarvestLocations = new ArrayList<>();
        int harvestRadius = myPlayer.getHarvestRadius();

        for (Position harvestPos : GameUtil.withinHarvestRange(gameState, myPlayer.getName())) {
            if (gameState.getTileMap().get(harvestPos).getCrop().getValue() > 0) {
                possibleHarvestLocations.add(harvestPos);
            }
        }

        logger.debug(String.format("Possible harvest locations=%s", possibleHarvestLocations));

        if (possibleHarvestLocations.size() > 0) {
            // If we can harvest something, try to harvest it
            decision = new HarvestDecision(possibleHarvestLocations);
        } else if (myPlayer.getSeedInventory().get(crop) > 0
                && gameState.getTileMap().get(pos).getType() != TileType.GREEN_GROCER
                && gameState.getTileMap().get(pos).getType().ordinal() >= TileType.F_BAND_OUTER.ordinal()) {
            // If not but we have that seed, then try to plant it in a fertility band
            logger.debug(String.format("Deciding to try to plant at position %s", pos));
            decision = new PlantDecision(Collections.singletonList(crop.name()), Collections.singletonList(pos));
        } else if (myPlayer.getMoney() >= crop.getSeedBuyPrice()
                && gameState.getTileMap().get(pos).getType() == TileType.GREEN_GROCER) {
            // If we don't have that seed, but we have the money to buy it, then move towards the green grocer to buy it
            logger.debug(String.format("Buy 1 of %s", crop));
            decision = new BuyDecision(Collections.singletonList(crop.name()), Collections.singletonList(1));
        } else {
            // If we can't do any of that, then just do nothing (move around some more)
            logger.debug("Couldn't find anything to do, waiting for move step");
            decision = new DoNothingDecision();
        }
        
        logger.debug(String.format("[Turn %d] Sending ActionDecision: %s",
                gameState.getTurn(), decision));
        return decision;
    }

    /**
     * Competitor TODO: choose an item and upgrade for your bot
     *
     * @param args Program arguments (ignored)
     */
    public static void main(String[] args) {
        Game game = new Game(ItemType.COFFEE_THERMOS, UpgradeType.LONGER_SCYTHE);

        while (true) {
            // Turn part 1: Move Decision
            try {
                game.updateGame();
            } catch (IOException e) {
                System.exit(-1);
            }
            game.sendMoveDecision(getMoveDecision(game));

            // Turn part 2: Action Decision
            try {
                game.updateGame();
            } catch (IOException e) {
                System.exit(-1);
            }
            game.sendActionDecision(getActionDecision(game));
        }
    }
}
