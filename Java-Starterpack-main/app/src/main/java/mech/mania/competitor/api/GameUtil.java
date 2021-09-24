package mech.mania.competitor.api;

import mech.mania.competitor.model.GameState;
import mech.mania.competitor.model.Player;
import mech.mania.competitor.model.Position;
import mech.mania.competitor.model.TileType;

import java.util.ArrayList;
import java.util.List;

public class GameUtil {

    private static final Constants constants = new Constants();

    public static boolean validPosition(Position pos) {
        return pos.getX() >= 0 && pos.getX() < constants.BOARD_WIDTH && pos.getY() >= 0 && pos.getY() < constants.BOARD_HEIGHT;
    }

    public static int distance(Position pos1, Position pos2) {
        return Math.abs(pos1.getX() - pos2.getX()) + Math.abs(pos1.getY() - pos2.getY());
    }

    public static Player getPlayerFromName(GameState state, String playerName) {
        return state.getPlayer1().getName().equals(playerName) ? state.getPlayer1() : state.getPlayer2();
    }

    public static List<Position> withinMoveRange(GameState state, String playerName) {
        Player myPlayer = getPlayerFromName(state, playerName);
        int speed = myPlayer.getMaxMovement();

        List<Position> res = new ArrayList<>();

        for (int i = myPlayer.getPosition().getY() - speed; i < myPlayer.getPosition().getY() + speed; i++) {
            int leftoverTravel = Math.max(0, speed - Math.abs(myPlayer.getPosition().getY() - i));
            for (int j = myPlayer.getPosition().getX() - leftoverTravel; j < myPlayer.getPosition().getX() + leftoverTravel; j++) {
                Position pos = new Position(j, i);
                if (validPosition(pos)) {
                    res.add(pos);
                }
            }
        }
        return res;
    }

    public static List<Position> withinHarvestRange(GameState state, String playerName) {
        Player myPlayer = getPlayerFromName(state, playerName);
        int radius = myPlayer.getHarvestRadius();

        List<Position> res = new ArrayList<>();

        for (int i = myPlayer.getPosition().getY() - radius; i < myPlayer.getPosition().getY() + radius; i++) {
            for (int j = myPlayer.getPosition().getX() - radius; j < myPlayer.getPosition().getX() + radius; j++) {
                Position pos = new Position(j, i);
                if (distance(pos, myPlayer.getPosition()) <= radius && validPosition(pos)) {
                    res.add(pos);
                }
            }
        }
        return res;
    }

    public static TileType tileTypeOnTurn(int turn, Constants constants, Position coord) {
        int shifts = (turn - 1 - constants.F_BAND_INIT_DELAY) / constants.F_BAND_MOVE_DELAY;
        shifts = Math.max(0, shifts);

        int row = coord.getY();
        TileType newType;

        // offset records how far into the fertility zone a row is (negative indicates below)
        // init position indicates the first row that will *become* part of a band after the first shift
        // e.g. 0 => fertility band starts off the map while 1 => fertility band starts with 1 row on the map
        int offset = shifts - row - 1 + constants.F_BAND_INIT_POSITION;
        if (offset < 0) {
            // Below fertility band
            newType = TileType.SOIL;
        } else if (offset < constants.F_BAND_OUTER_HEIGHT) {
            // Within first outer band
            newType = TileType.F_BAND_OUTER;
        } else if (offset < constants.F_BAND_OUTER_HEIGHT + constants.F_BAND_MID_HEIGHT) {
            // Within first mid band
            newType = TileType.F_BAND_MID;
        } else if (offset < constants.F_BAND_OUTER_HEIGHT + constants.F_BAND_MID_HEIGHT +
                constants.F_BAND_INNER_HEIGHT) {
            // Within inner band
            newType = TileType.F_BAND_INNER;
        } else if (offset < constants.F_BAND_OUTER_HEIGHT + 2 * constants.F_BAND_MID_HEIGHT +
                constants.F_BAND_INNER_HEIGHT) {
            // Within second mid band
            newType = TileType.F_BAND_MID;
        } else if (offset < 2 * constants.F_BAND_OUTER_HEIGHT + 2 * constants.F_BAND_MID_HEIGHT +
                constants.F_BAND_INNER_HEIGHT) {
            // Within second outer band
            newType = TileType.F_BAND_OUTER;
        } else {
            // Above fertility bands
            newType = TileType.ARID;
        }

        return newType;
    }
}
