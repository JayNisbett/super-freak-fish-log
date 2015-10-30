package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.UserDefineTable;

/**
 * A UserDefineObject is the superclass for all "user defined" data such as species and locations.
 * @author Cohen Adair
 */
public class UserDefineObject {

    private UUID mId;
    private String mName;
    private boolean mShouldDelete; // toggled on UI selection for deleting multiple items
    private boolean mIsSelected; // used to show selection in RecyclerView layouts

    public UserDefineObject(String name) {
        setId(UUID.randomUUID());
        setName(name);
    }

    public UserDefineObject(UserDefineObject obj) {
        initFromObj(obj, false);
    }

    public UserDefineObject(UserDefineObject obj, boolean keepId) {
        initFromObj(obj, keepId);
    }

    private void initFromObj(UserDefineObject obj, boolean keepId) {
        if (obj != null) {
            mId = keepId ? obj.getId() : UUID.randomUUID();
            mName = obj.getName();
            mShouldDelete = obj.getShouldDelete();
        }
    }

    //region Getters & Setters
    public UUID getId() {
        return mId;
    }

    public void setId(UUID id) {
        mId = id;
    }

    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }

    public boolean getShouldDelete() {
        return mShouldDelete;
    }

    public void setShouldDelete(boolean shouldDelete) {
        mShouldDelete = shouldDelete;
    }

    public boolean isSelected() {
        return mIsSelected;
    }

    public void setIsSelected(boolean isSelected) {
        mIsSelected = isSelected;
    }
    //endregion

    public String toString() {
        return mName;
    }

    public ContentValues getContentValues() {
        ContentValues values = new ContentValues();

        values.put(UserDefineTable.Columns.ID, mId.toString());
        values.put(UserDefineTable.Columns.NAME, mName);

        return values;
    }

    public void remove() {
        // remove stuff from database if necessary
    }
}
