package mech.mania.competitor.model;

import java.util.*;

public class Player {
    private int id;
    private String name;
    private Position position;
    private String item;
    private String upgrade;
    private double money;
    private Map<CropType, Integer> seedInventory = new HashMap<>();
    private ArrayList<Crop> harvestedInventory = new ArrayList<>();

    private double discount;
    private int amountSpent;
    private int protectionRadius;
    private int harvestRadius;
    private int plantRadius;
    private int carryingCapacity;
    private int maxMovement;
    private double doubleDropChance;

    private boolean usedItem = false;
    private boolean hasDeliveryDrone = false;
    private boolean useCoffeeThermos = false;
    private boolean itemTimeExpired = false;

    public double getMoney() {
        return money;
    }

    public String getUpgrade() {
        return upgrade;
    }

    public String getItem() {
        return item;
    }

    public Position getPosition() {
        return position;
    }

    public String getName() {
        return name;
    }

    public ArrayList<Crop> getHarvestedCrops() {
        return harvestedInventory;
    }

    public Map<CropType, Integer> getSeeds() {
        return this.seedInventory;
    }

    public Map<CropType, Integer> getSeedInventory() {
        return seedInventory;
    }

    public ArrayList<Crop> getHarvestedInventory() {
        return harvestedInventory;
    }

    public double getDiscount() {
        return discount;
    }

    public int getAmountSpent() {
        return amountSpent;
    }

    public int getProtectionRadius() {
        return protectionRadius;
    }

    public int getHarvestRadius() {
        return harvestRadius;
    }

    public int getPlantRadius() {
        return plantRadius;
    }

    public int getCarryingCapacity() {
        return carryingCapacity;
    }

    public int getMaxMovement() {
        return maxMovement;
    }

    public double getDoubleDropChance() {
        return doubleDropChance;
    }

    public boolean isUsedItem() {
        return usedItem;
    }

    public boolean hasDeliveryDrone() {
        return hasDeliveryDrone;
    }

    public boolean usedCoffeeThermos() {
        return useCoffeeThermos;
    }

    public boolean hasItemTimeExpired() {
        return itemTimeExpired;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }
}
