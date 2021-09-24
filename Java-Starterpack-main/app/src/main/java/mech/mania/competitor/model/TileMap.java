package mech.mania.competitor.model;

import java.util.ArrayList;
import java.util.Iterator;

public class TileMap implements Iterable<Tile> {
    private int mapHeight;
    private int mapWidth;
    private ArrayList<ArrayList<Tile>> tiles;

    private ArrayList<Position> greenGrocerTiles;

    private static final TileType[] UNPLANTABLE_TILETYPES = {TileType.GREEN_GROCER, TileType.GRASS};

    public int getMapHeight() {
        return mapHeight;
    }

    public int getMapWidth() {
        return mapWidth;
    }

    public boolean isValidPosition(Position pos) {
        return pos.getX() >= 0 && pos.getX() < mapWidth && pos.getY() >= 0 && pos.getY() < mapHeight;
    }

    public TileType getTileType(Position pos) {
        return get(pos).getType();
    }

    public Tile get(Position pos) {
        if (isValidPosition(pos)) {
            return tiles.get(pos.getY()).get(pos.getX());
        }
        return null;
    }

    @Override
    public Iterator<Tile> iterator() {
        return new TileMapIterator();
    }

    /**
     * Utility Iterator object to iterate through Tiles easily
     */
    class TileMapIterator implements Iterator<Tile> {
        private int pos = 0;

        // java.util.Iterator methods
        @Override
        public boolean hasNext() {
            return pos < mapHeight * mapWidth;
        }

        @Override
        public Tile next() {
            int row = pos / mapWidth;
            int col = pos % mapWidth;
            pos++;
            return tiles.get(row).get(col);
        }
    }

    public ArrayList<ArrayList<Tile>> getTiles() {
        return tiles;
    }

    public ArrayList<Position> getGreenGrocerTiles() {
        return greenGrocerTiles;
    }


}

