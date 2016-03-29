package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;

/**
 * Used to store and retrieve values from {@link android.content.SharedPreferences}.
 *
 * Created by Cohen Adair on 2016-01-23.
 */
public class LogbookPreferences {

    public static final String PREF_CLEANUP = "com.cohenadair.anglerslog.Cleanup";
    public static final String PREF_SELECTIONS = "com.cohenadair.anglerslog.PreviousSelections";
    public static final String PREF_LAYOUT = "com.cohenadair.anglerslog.LayoutPreferences";

    public static final String NAVIGATION_ID = "navigationId";
    public static final String ROOT_TWO_PANE = "isRootTwoPane";
    public static final String WEATHER_UNITS = "weatherUnits";
    public static final String BACKUP_FILE = "backupFilePath";
    public static final String MAP_TYPE = "mapType";
    public static final String FIRST_RUN = "firstRun";

    private static Context mContext;

    public static void init(Context context) {
        mContext = context;
    }

    private static SharedPreferences getCleanup() {
        return mContext.getSharedPreferences(PREF_CLEANUP, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getPreviousSelections() {
        return mContext.getSharedPreferences(PREF_SELECTIONS, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getLayoutPreferences() {
        return mContext.getSharedPreferences(PREF_LAYOUT, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getDefaultPreferences() {
        return PreferenceManager.getDefaultSharedPreferences(mContext);
    }

    public static void setBackupFile(String filePath) {
        getCleanup().edit().putString(BACKUP_FILE, filePath).apply();
    }

    public static String getBackupFile() {
        return getCleanup().getString(BACKUP_FILE, null);
    }

    public static void setNavigationId(int id) {
        getPreviousSelections().edit().putInt(NAVIGATION_ID, id).apply();
    }

    public static int getNavigationId() {
        return getPreviousSelections().getInt(NAVIGATION_ID, LayoutSpecManager.LAYOUT_CATCHES);
    }

    public static void setMapType(int type) {
        getPreviousSelections().edit().putInt(MAP_TYPE, type).apply();
    }

    public static int getMapType() {
        return getPreviousSelections().getInt(MAP_TYPE, 1);
    }

    public static void setIsRootTwoPane(boolean isTwoPane) {
        getLayoutPreferences().edit().putBoolean(ROOT_TWO_PANE, isTwoPane).apply();
    }

    public static boolean getIsRootTwoPane() {
        return getLayoutPreferences().getBoolean(ROOT_TWO_PANE, false);
    }

    public static void setWeatherUnits(int units) {
        getPreviousSelections().edit().putInt(WEATHER_UNITS, units).apply();
    }

    public static int getWeatherUnits() {
        return getPreviousSelections().getInt(WEATHER_UNITS, -1);
    }

    //region Settings Preferences
    public static int getUnits() {
        return Integer.parseInt(getDefaultPreferences().getString(mContext.getResources().getString(R.string.pref_units), Integer.toString(Logbook.UNIT_IMPERIAL)));
    }

    public static void setUnits(int units) {
        getDefaultPreferences()
                .edit()
                .putString(mContext.getResources().getString(R.string.pref_units), Integer.toString(units))
                .apply();
    }

    public static boolean isInstabugEnabled() {
        return getDefaultPreferences().getBoolean(mContext.getResources().getString(R.string.pref_instabug), true);
    }

    public static void setInstabugEnabled(boolean enabled) {
        getDefaultPreferences()
                .edit()
                .putBoolean(mContext.getResources().getString(R.string.pref_instabug), enabled)
                .apply();
    }
    //endregion

    public static boolean isFirstRun() {
        return getDefaultPreferences().getBoolean(FIRST_RUN, true);
    }

    public static void setFirstRun(boolean isFirstRun) {
        getDefaultPreferences().edit().putBoolean(FIRST_RUN, isFirstRun).apply();
    }
}
