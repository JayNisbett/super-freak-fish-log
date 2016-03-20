package com.cohenadair.anglerslog.locations;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.CatchListPortionActivity;
import com.cohenadair.anglerslog.fragments.DetailFragment;
import com.cohenadair.anglerslog.fragments.DraggableMapFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.FishingSpotMarkerManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectionSpinnerView;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Marker;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A {@link DetailFragment} subclass used to show the details of a single location.
 */
public class LocationFragment extends DetailFragment {

    private static final String TAG_MAP = "LocationMap";

    private Location mLocation;

    private TextView mTitleTextView;
    private SelectionSpinnerView mFishingSpotSpinner;
    private DraggableMapFragment mMapFragment;
    private View mBreakView;

    private FishingSpotMarkerManager mMarkerManager;

    public LocationFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_location, container, false);

        setContainer((LinearLayout) view.findViewById(R.id.location_container));
        mBreakView = view.findViewById(R.id.view_break);

        initMapFragment();
        initTitle(view);
        initFishingSpotSelection(view);

        update(getActivity());

        // Inflate the layout for this fragment
        return view;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_location, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_show_all_catches) {
            showAllCatches();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void update(UUID id) {
        if (!isAttached())
            return;

        boolean idIsNull = (id == null);

        // must hide individual components for the menu to show property on tablets
        Utils.toggleVisibility(mTitleTextView, !idIsNull && isTwoPane());
        Utils.toggleVisibility(mFishingSpotSpinner, !idIsNull);
        Utils.toggleVisibility(mBreakView, !idIsNull);
        toggleMapVisibility(!idIsNull);

        // id can be null if in two-pane view and there are no locations
        if (idIsNull)
            return;

        setItemId(id);
        mLocation = Logbook.getLocation(id);
        FishingSpot fishingSpot = null;

        // for DetailFragmentActivity, the fishing spot id is passed in
        if (mLocation == null) {
            fishingSpot = Logbook.getFishingSpot(id);
            if (fishingSpot == null) {
                hide();
                return;
            }

            mLocation = Logbook.getLocation(fishingSpot.getLocationId());
            if (mLocation == null) {
                hide();
                return;
            }
        }

        show();

        // update spinner adapter
        ArrayAdapter<UserDefineObject> adapter = new ArrayAdapter<>(getContext(), R.layout.list_item_spinner, mLocation.getFishingSpots());
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        mFishingSpotSpinner.setAdapter(adapter);

        // select the correct fishing spot if it exists
        if (fishingSpot != null) {
            for (int i = 0; i < mLocation.getFishingSpotCount(); i++) {
                FishingSpot spot = (FishingSpot) mFishingSpotSpinner.getAdapter().getItem(i);
                if (spot.getName().equals(fishingSpot.getName())) {
                    mFishingSpotSpinner.setSelection(i);
                    break;
                }
            }
        }

        // update title
        if (isTwoPane())
            mTitleTextView.setText(mLocation.getName());
        else
            setActionBarTitle(mLocation.getName());

        // update map
        updateMap();
    }

    @Override
    public void hide() {
        super.hide();
        Utils.toggleVisibility(mMapFragment.getView(), false);
        Utils.toggleVisibility(mTitleTextView, false);
        Utils.toggleVisibility(mFishingSpotSpinner, false);
        Utils.toggleVisibility(mBreakView, false);
    }

    private void showAllCatches() {
        Intent intent = CatchListPortionActivity.getIntent(getContext(), mLocation.getDisplayName(), mLocation.getCatches());
        getContext().startActivity(intent);
    }

    //region Map Fragment
    private void initMapFragment() {
        // check to see if the map fragment already exists
        mMapFragment = (DraggableMapFragment)getChildFragmentManager().findFragmentByTag(TAG_MAP);
        if (mMapFragment != null)
            return;

        mMapFragment = DraggableMapFragment.newInstance(true, false);
        mMapFragment.getMapAsync(new DraggableMapFragment.InteractionListener() {
            @Override
            public void onMapReady(GoogleMap map) {
                LocationFragment.this.onMapReady();
            }

            @Override
            public void onLocationUpdate(android.location.Location location) {

            }
        });

        getChildFragmentManager()
                .beginTransaction()
                .add(R.id.location_container, mMapFragment, TAG_MAP)
                .commit();
    }

    /**
     * Needed if there is no selection in two-pane mode. Makes sure that the map isn't shown if
     * the user hasn't selected a location.
     *
     * @param show True to show the map; false to hide.
     */
    public void toggleMapVisibility(boolean show) {
        if (show)
            getChildFragmentManager().beginTransaction().show(mMapFragment).commitAllowingStateLoss();
        else
            getChildFragmentManager().beginTransaction().hide(mMapFragment).commitAllowingStateLoss();
    }

    public void onMapReady() {
        mMarkerManager = new FishingSpotMarkerManager(getContext(), getContainer(), mMapFragment.getGoogleMap(), new FishingSpotMarkerManager.InteractionListener() {
            @Override
            public void onMarkerClick(Marker marker, int index) {
                // update the Spinner if one of the fishing spot markers was selected
                mFishingSpotSpinner.setSelection(index);
            }
        });

        updateMap();
    }

    private void updateMap() {
        if (mMapFragment.getGoogleMap() == null || mLocation == null)
            return;

        mMarkerManager.setFishingSpots(mLocation.getFishingSpots());
        mMarkerManager.updateMarkers();

        updateFishingSpotSelection();
    }
    //endregion

    private void initTitle(View view) {
        mTitleTextView = (TextView)view.findViewById(R.id.title_text_view);
        mTitleTextView.setVisibility(isTwoPane() ? View.VISIBLE : View.GONE);
    }

    private void initFishingSpotSelection(View view) {
        mFishingSpotSpinner = (SelectionSpinnerView)view.findViewById(R.id.fishing_spot_spinner);
        mFishingSpotSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectFishingSpot(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private void selectFishingSpot(int position) {
        mFishingSpotSpinner.setSelection(position);
        updateFishingSpotSelection();
    }

    private void updateFishingSpotSelection() {
        ArrayList<UserDefineObject> fishingSpots = mLocation.getFishingSpots();

        final int selectedIndex = mFishingSpotSpinner.getSelectedIndex();
        FishingSpot fishingSpot = (FishingSpot)fishingSpots.get(selectedIndex);

        // move the camera to the current fishing spot
        mMapFragment.updateCamera(fishingSpot.getCoordinates(), 250, new GoogleMap.CancelableCallback() {
            @Override
            public void onFinish() {
                // show the info window for the selected fishing spot
                mMarkerManager.showInfoWindowAtIndex(selectedIndex);
            }

            @Override
            public void onCancel() {

            }
        });
    }
}
