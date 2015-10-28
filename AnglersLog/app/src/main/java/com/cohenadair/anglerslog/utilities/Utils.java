package com.cohenadair.anglerslog.utilities;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.Resources;
import android.graphics.Point;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.view.View;
import android.widget.Toast;

import com.cohenadair.anglerslog.R;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utils {

    private static final String TAG = "Utils";

    /**
     * The index of items that appear in a ManageAlert.
     */
    public static final int MANAGE_ALERT_EDIT = 0;
    public static final int MANAGE_ALERT_DELETE = 1;

    public static void showToast(Context context, int resId) {
        Toast.makeText(context, resId, Toast.LENGTH_SHORT).show();
    }

    public static void showSnackbar(View view, String msg) {
        Snackbar.make(view, msg, Snackbar.LENGTH_LONG).show();
    }

    public static void showErrorAlert(Context context, int msgId) {
        showErrorAlert(context, context.getResources().getString(msgId));
    }

    public static void showErrorAlert(Context context, String msg) {
        new AlertDialog.Builder(context)
                .setTitle(context.getResources().getString(R.string.error))
                .setMessage(msg)
                .setPositiveButton(R.string.OK, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    /**
     * An alert that shows managing options such as "Edit" and "Delete".
     * @param context The context in which to show the dialog.
     * @param onItemClick The on item click listener.
     */
    public static void showManageAlert(Context context, String title, DialogInterface.OnClickListener onItemClick) {
        new AlertDialog.Builder(context)
                .setTitle(title)
                .setPositiveButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setItems(R.array.manage_options, onItemClick)
                .show();
    }

    public static void showDeleteConfirm(Context context, DialogInterface.OnClickListener onConfirm) {
        new AlertDialog.Builder(context)
                .setTitle(context.getResources().getString(R.string.action_confirm))
                .setMessage(R.string.msg_confirm_delete)
                .setNegativeButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setPositiveButton(R.string.action_delete, onConfirm)
                .show();
    }

    public static void showDeleteOption(Context context, int msgId, DialogInterface.OnClickListener onConfirm) {
        new AlertDialog.Builder(context)
                .setTitle(R.string.action_delete)
                .setMessage(msgId)
                .setNegativeButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setPositiveButton(R.string.action_delete, onConfirm)
                .show();
    }

    /**
     * This method converts device specific pixels to density independent pixels.
     * @param px A value in px (pixels) unit. Which we need to convert into db.
     * @return A float value to represent dp equivalent to px value.
     */
    public static float pxToDp(float px){
        return px / Resources.getSystem().getDisplayMetrics().density;
    }

    /**
     * This method converts density independent pixels to device specific pixels.
     * @param dp A value in px (pixels) unit. Which we need to convert into db.
     * @return A float value to represent dp equivalent to px value.
     */
    public static float dpToPx(float dp){
        return dp * Resources.getSystem().getDisplayMetrics().density;
    }

    /**
     * Gets the screen size in pixels.
     * @param activity The activity used to get the screen size.
     * @return A Point object representing the screen size, in pixels.
     */
    public static Point getScreenSize(Activity activity) {
        Point size = new Point();
        activity.getWindowManager().getDefaultDisplay().getSize(size);
        return size;
    }

    /**
     * Checks to see if the current context is two-pane.
     * @param context The Context to check.
     * @return True if two-pane; false otherwise.
     */
    public static boolean isTwoPane(Context context) {
        return context.getResources().getBoolean(R.bool.has_two_panes);
    }

}
