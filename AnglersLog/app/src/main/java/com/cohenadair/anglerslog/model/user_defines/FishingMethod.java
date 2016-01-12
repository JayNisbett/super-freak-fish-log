package com.cohenadair.anglerslog.model.user_defines;

/**
 * Represents a single fishing method property, added by the user.
 * @author Cohen Adair
 */
public class FishingMethod extends UserDefineObject {

    public FishingMethod(String name) {
        super(name);
    }

    public FishingMethod(FishingMethod method) {
        super(method);
    }

    public FishingMethod(UserDefineObject obj) {
        super(obj);
    }

    public FishingMethod(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }
}
