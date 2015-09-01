package com.cohenadair.anglerslog;

import android.app.Application;

import com.cohenadair.anglerslog.model.Catch;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Species;

import java.util.Calendar;
import java.util.Date;

/**
 * The AnglersLogApplication class is used for startup and teardown code execution.
 * @author Cohen Adair
 */
public class AnglersLogApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        // initialize some dummy catches
        if (Logbook.getSharedLogbook().catchCount() <= 0)
            for (int i = 0; i < 12; i++) {
                Calendar calendar = Calendar.getInstance();
                calendar.set(Calendar.MONTH, i);
                Date aDate = calendar.getTime();

                Catch aCatch = new Catch(aDate);
                aCatch.setSpecies(new Species("Species " + i));

                Logbook.getSharedLogbook().addCatch(aCatch);
            }
    }

}
