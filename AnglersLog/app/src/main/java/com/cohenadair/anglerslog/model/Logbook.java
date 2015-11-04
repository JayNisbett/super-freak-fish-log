package com.cohenadair.anglerslog.model;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteConstraintException;
import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.database.cursors.BaitCursor;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.Random;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitCategoryTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.SpeciesTable;

/**
 * The Logbook class is a monostate class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    private static final String TAG = "Logbook";

    private static SQLiteDatabase mDatabase;
    private static File mDatabaseFile;

    private Logbook() { }

    public static void init(Context context) {
        mDatabaseFile = context.getDatabasePath(LogbookHelper.DATABASE_NAME);
        init(context, new LogbookHelper(context).getWritableDatabase());
    }

    public static void init(Context context, SQLiteDatabase database) {
        mDatabaseFile = context.getDatabasePath(LogbookHelper.DATABASE_NAME);
        mDatabase = database;
        mDatabase.setForeignKeyConstraintsEnabled(true);
        QueryHelper.setDatabase(mDatabase);
        cleanDatabasePhotos();
    }

    //region Getters & Setters
    public static SQLiteDatabase getDatabase() {
        return mDatabase;
    }

    public static File getDatabaseFile() {
        return mDatabaseFile;
    }
    //endregion

    //region Miscellaneous
    /**
     * Gets a random Catch photo to use in the NavigationView.
     * @return A String representing a random photo name, or null if no photos exist.
     */
    @Nullable
    public static String getRandomCatchPhoto() {
        ArrayList<String> photoNames = QueryHelper.queryPhotos(CatchPhotoTable.NAME, null, null);

        if (photoNames.size() <= 0)
            return null;

        return photoNames.get(new Random().nextInt(photoNames.size()));
    }
    //endregion

    //region Catch Manipulation
    public static void cleanDatabasePhotos() {
        // TODO delete photos from BaitPhotoTable

        int numDeleted = mDatabase.delete(
                CatchPhotoTable.NAME,
                CatchPhotoTable.Columns.USER_DEFINE_ID + " NOT IN(SELECT " + CatchTable.Columns.ID + " FROM " + CatchTable.NAME + ")",
                null);

        Log.i(TAG, "Deleted " + numDeleted + " photos from the database.");
    }

    public static ArrayList<UserDefineObject> getCatches() {
        ArrayList<UserDefineObject> catches = new ArrayList<>();
        CatchCursor cursor = QueryHelper.queryCatches(null, null);

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()) {
                catches.add(cursor.getCatch());
                cursor.moveToNext();
            }

        cursor.close();
        return catches;
    }

    @Nullable
    public static Catch getCatch(UUID id) {
        Catch aCatch = null;
        CatchCursor cursor = QueryHelper.queryCatches(CatchTable.Columns.ID + " = ?", new String[] { id.toString() });

        if (cursor.moveToFirst())
            aCatch = cursor.getCatch();

        cursor.close();
        return aCatch;
    }

    public static boolean catchExists(Date date) {
        Cursor cursor = QueryHelper.queryCatches(CatchTable.Columns.DATE + " = ?", new String[] { Long.toString(date.getTime()) });
        boolean result = cursor.getCount() > 0;
        cursor.close();
        return result;
    }

    public static boolean addCatch(Catch aCatch) {
        return mDatabase.insert(CatchTable.NAME, null, aCatch.getContentValues()) != -1;
    }

    public static boolean removeCatch(UUID id) {
        return mDatabase.delete(CatchTable.NAME, CatchTable.Columns.ID + " = ?", new String[]{id.toString()}) == 1;
    }

    public static boolean editCatch(UUID id, Catch newCatch) {
        newCatch.setId(id); // id needs to stay the same
        return mDatabase.update(CatchTable.NAME, newCatch.getContentValues(), CatchTable.Columns.ID + " = ?", new String[] { id.toString() }) == 1;
    }

    public static int getCatchCount() {
        return QueryHelper.queryCount(CatchTable.NAME);
    }
    //endregion

    //region Species Manipulation
    public static ArrayList<UserDefineObject> getSpecies() {
        ArrayList<UserDefineObject> species = new ArrayList<>();
        UserDefineCursor cursor = QueryHelper.queryUserDefines(SpeciesTable.NAME, null, null);

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()) {
                species.add(cursor.getObject());
                cursor.moveToNext();
            }

        cursor.close();
        return species;
    }

    @Nullable
    public static Species getSpecies(UUID id) {
        Species species = null;
        UserDefineCursor cursor = QueryHelper.queryUserDefines(SpeciesTable.NAME, SpeciesTable.Columns.ID + " = ?", new String[]{ id.toString() });

        if (cursor.moveToFirst())
            species = new Species(cursor.getObject(), true);

        cursor.close();
        return species;
    }

    public static boolean addSpecies(Species species) {
        return mDatabase.insert(SpeciesTable.NAME, null, species.getContentValues()) != -1;
    }

    public static boolean removeSpecies(UUID id) {
        boolean result = false;

        try {
            result = mDatabase.delete(SpeciesTable.NAME, SpeciesTable.Columns.ID + " = ?", new String[] { id.toString() }) == 1;
        } catch (SQLiteConstraintException e) {
            e.printStackTrace();
        }

        return result;
    }

    public static boolean editSpecies(UUID id, Species newSpecies) {
        newSpecies.setId(id); // id needs to stay the same
        return mDatabase.update(SpeciesTable.NAME, newSpecies.getContentValues(), SpeciesTable.Columns.ID + " = ?", new String[] { id.toString() }) == 1;
    }

    public static int getSpeciesCount() {
        return QueryHelper.queryCount(SpeciesTable.NAME);
    }
    //endregion

    //region BaitCategory Manipulation
    public static ArrayList<UserDefineObject> getBaitCategories() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(BaitCategoryTable.NAME, null, null), null);
    }

    @NonNull
    public static BaitCategory getBaitCategory(UUID id) {
        return new BaitCategory(QueryHelper.queryUserDefine(BaitCategoryTable.NAME, id, null));
    }

    public static boolean baitCategoryExists(String name) {
        return QueryHelper.queryHasResults(QueryHelper.queryUserDefines(BaitCategoryTable.NAME, BaitCategoryTable.Columns.NAME + " = ?", new String[]{ name }));
    }

    public static boolean addBaitCategory(BaitCategory baitCategory) {
        return QueryHelper.insertUserDefine(BaitCategoryTable.NAME, baitCategory.getContentValues());
    }

    public static boolean removeBaitCategory(UUID id) {
        return QueryHelper.deleteUserDefine(BaitCategoryTable.NAME, id);
    }

    public static boolean editBaitCategory(UUID id, BaitCategory newBaitCategory) {
        return QueryHelper.updateUserDefine(BaitCategoryTable.NAME, newBaitCategory.getContentValues(), id);
    }

    public static int getBaitCategoryCount() {
        return QueryHelper.queryCount(BaitCategoryTable.NAME);
    }
    //endregion

    //region Bait Manipulation
    public static ArrayList<UserDefineObject> getBaits() {
        return QueryHelper.queryUserDefines(QueryHelper.queryBaits(null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCursor(cursor).getBait();
            }
        });
    }

    @NonNull
    public static Bait getBait(UUID id) {
        return new Bait(QueryHelper.queryUserDefine(BaitTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCursor(cursor).getBait();
            }
        }));
    }

    public static boolean baitExists(Bait bait) {
        return QueryHelper.queryHasResults(QueryHelper.queryBaits(BaitTable.Columns.CATEGORY_ID + " = ? AND " + BaitTable.Columns.NAME + " = ?", new String[]{ bait.getCategory().idAsString(), bait.getName() }));
    }

    public static boolean addBait(Bait bait) {
        // add the Bait's BaitCategory if it doesn't already exist in the Logbook
        if (!baitCategoryExists(bait.getCategory().getName()))
            addBaitCategory(bait.getCategory());

        return QueryHelper.insertUserDefine(BaitTable.NAME, bait.getContentValues());
    }

    public static boolean removeBait(UUID id) {
        return QueryHelper.deleteUserDefine(BaitTable.NAME, id);
    }

    public static boolean editBait(UUID id, Bait newBait) {
        return QueryHelper.updateUserDefine(BaitTable.NAME, newBait.getContentValues(), id);
    }

    public static int getBaitCount() {
        return QueryHelper.queryCount(BaitTable.NAME);
    }
    //endregion
}
