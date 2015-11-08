package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;

/**
 * The Bait class represents a single bait used for fishing.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class Bait extends PhotoUserDefineObject {

    public static final int TYPE_ARTIFICIAL = 0;
    public static final int TYPE_LIVE = 1;
    public static final int TYPE_REAL = 2;

    private BaitCategory mCategory;
    private String mColor;
    private String mSize;
    private String mDescription;
    private int mType;

    //region Constructors
    public Bait(String name, BaitCategory category) {
        super(name, BaitPhotoTable.NAME);
        mCategory = category;
    }

    public Bait(Bait bait, boolean keepId) {
        super(bait, keepId);
        mCategory = new BaitCategory(bait.getCategory(), true);
        mColor = bait.getColor();
        mSize = bait.getSize();
        mDescription = bait.getDescription();
        mType = bait.getType();
    }

    public Bait(UserDefineObject obj) {
        super(obj);
        setPhotoTable(BaitPhotoTable.NAME);
    }
    //endregion

    //region Getters & Setters
    public BaitCategory getCategory() {
        return mCategory;
    }

    public void setCategory(BaitCategory category) {
        mCategory = category;
    }

    public String getColor() {
        return mColor;
    }

    public void setColor(String color) {
        mColor = color;
    }

    public String getSize() {
        return mSize;
    }

    public void setSize(String size) {
        mSize = size;
    }

    public String getDescription() {
        return mDescription;
    }

    public void setDescription(String description) {
        mDescription = description;
    }

    public int getType() {
        return mType;
    }

    public void setType(int type) {
        mType = type;
    }
    //endregion

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(BaitTable.Columns.COLOR, mColor);
        values.put(BaitTable.Columns.DESCRIPTION, mDescription);
        values.put(BaitTable.Columns.SIZE, mSize);
        values.put(BaitTable.Columns.TYPE, mType);
        if (mCategory != null)
            values.put(BaitTable.Columns.CATEGORY_ID, mCategory.idAsString());

        return values;
    }
}
