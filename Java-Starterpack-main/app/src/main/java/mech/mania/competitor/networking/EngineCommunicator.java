package mech.mania.competitor.networking;

import mech.mania.competitor.api.Constants;

import java.io.IOException;
import java.io.InputStreamReader;

public final class EngineCommunicator {

    private static Constants gameConstants;

    public static void setGameConstants(Constants gameConstants) {
        EngineCommunicator.gameConstants = gameConstants;
    }

    public static String readLine() throws IOException {
        SafeBufferedReader reader = new SafeBufferedReader(new InputStreamReader(System.in), gameConstants.PLAYER_TIMEOUT);
        return reader.readLine();
    }

    public static void sendOut(String string) {
        System.out.println(string);
    }

    public static void sendErr(String string) {
        System.err.println(string);
    }
}
