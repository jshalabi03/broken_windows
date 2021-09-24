package mech.mania.competitor.model.decisions;

import mech.mania.competitor.model.Position;

import java.util.ArrayList;

public class HarvestDecision extends ActionDecision {
    protected ArrayList<Position> coords;

    public HarvestDecision(ArrayList<Position> coords) {
        this.coords = coords;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("HarvestDecision(");
        for (int i = 0; i < coords.size(); i++) {
            builder.append(coords.get(i).toString());
            if (i < coords.size() - 1) {
                builder.append(",");
            }
        }
        builder.append(")");

        return builder.toString();
    }

    public String getEngineReadableString() {
        StringBuilder builder = new StringBuilder();
        builder.append("harvest ");
        for (Position coord : coords) {
            builder.append(String.format("%s ", coord.getEngineReadableString()));
        }

        return builder.toString();
    }
}
