package mech.mania.competitor.model.decisions;

import java.util.List;

public class BuyDecision extends ActionDecision {
    protected List<String> cropTypes;
    protected List<Integer> quantities;
    public BuyDecision(List<String> cropTypes, List<Integer> quantities) {
        this.cropTypes = cropTypes;
        this.quantities = quantities;
        assert(cropTypes.size() == quantities.size());
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("buy ");
        for (int i = 0; i < cropTypes.size(); i++) {
            builder.append(cropTypes.get(i));
            builder.append(" ");
            builder.append(quantities.get(i));
        }

        return builder.toString();
    }

    public String getEngineReadableString() {
        StringBuilder builder = new StringBuilder();
        builder.append("BuyDecision(");
        for (int i = 0; i < cropTypes.size(); i++) {
            builder.append(cropTypes.get(i));
            builder.append(":");
            builder.append(quantities.get(i));
            if (i < cropTypes.size() - 1) {
                builder.append(",");
            }
        }
        builder.append(")");

        return builder.toString();
    }
}
