package com.cohenadair.anglerslog.fragments;

import android.Manifest;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.GoogleMapLayout;
import com.cohenadair.anglerslog.utilities.Utils;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;

/**
 * A SupportMapFragment wrapper class to handle map drag events. It also handles optional user
 * location support and integration with the Google FusedLocationProviderApi.
 *
 * Created by Cohen Adair on 2015-12-06.
 * Updated by Cohen Adair on 2016-02-03.
 */
public class DraggableMapFragment extends SupportMapFragment implements OnMapReadyCallback, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    private static final String TAG = "DraggableMapFragment";
    private static final float ZOOM = 15;

    private static final int REQUEST_LOCATION = 0;
    private static final int GRANTED = PackageManager.PERMISSION_GRANTED;
    private static final String PERMISSION_LOCATION = Manifest.permission.ACCESS_FINE_LOCATION;

    private static final String ARG_ENABLE_LOCATION = "arg_enable_location";
    private static final String ARG_ENABLE_UPDATES = "arg_enable_updates";

    private GoogleApiClient mGoogleApiClient;
    private View mOriginalView;
    private GoogleMapLayout mMapLayout;
    private GoogleMap mGoogleMap;

    private GoogleMapLayout.OnDragListener mOnDragListener;
    private InteractionListener mCallbacks;
    private boolean mLocationEnabled = false;
    private boolean mLocationUpdatesEnabled = false;

    public interface InteractionListener {
        void onMapReady(GoogleMap map);
        void onLocationUpdate(Location location);
    }

    public static DraggableMapFragment newInstance(boolean enableLocation, boolean enableLocationUpdates) {
        DraggableMapFragment fragment = new DraggableMapFragment();

        // add primitive id to bundle so save through orientation changes
        Bundle args = new Bundle();
        args.putBoolean(ARG_ENABLE_LOCATION, enableLocation);
        args.putBoolean(ARG_ENABLE_UPDATES, enableLocationUpdates);

        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (getArguments() != null) {
            mLocationEnabled = getArguments().getBoolean(ARG_ENABLE_LOCATION);
            mLocationUpdatesEnabled = getArguments().getBoolean(ARG_ENABLE_UPDATES);
        }

        if (mGoogleApiClient == null)
            mGoogleApiClient = new GoogleApiClient.Builder(getContext())
                    .addApi(LocationServices.API)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .build();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mOriginalView = super.onCreateView(inflater, container, savedInstanceState);

        mMapLayout = new GoogleMapLayout(getActivity());
        mMapLayout.addView(mOriginalView);

        // nested inner class used here in case mOnDragListener is set after onCreateView is called
        mMapLayout.setOnDragListener(new GoogleMapLayout.OnDragListener() {
            @Override
            public void onDrag(MotionEvent motionEvent) {
                if (mOnDragListener != null)
                    mOnDragListener.onDrag(motionEvent);
            }
        });

        return mMapLayout;
    }

    @Override
    public void onStart() {
        connectToGoogleClient();
        super.onStart();
    }

    @Override
    public void onStop() {
        disconnectFromGoogleClient();
        super.onStop();
    }

    @Override
    public View getView() {
        return mOriginalView;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode != REQUEST_LOCATION || permissions.length != 1)
            return;

        if (permissions[0].equals(PERMISSION_LOCATION) && grantResults[0] == GRANTED)
            enableMyLocation();
        else
            Utils.showErrorAlert(getContext(), R.string.error_location_permission);
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        Log.d(TAG, "Map is ready.");

        mGoogleMap = googleMap;

        if (isLocationPermissionGranted())
            enableMyLocation();
        else
            requestLocationPermission();

        if (mCallbacks != null)
            mCallbacks.onMapReady(googleMap);
    }

    @Override
    public void onConnected(Bundle bundle) {
        Log.d(TAG, "GoogleClient connected.");

        if (mLocationUpdatesEnabled)
            startLocationUpdates();
    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }

    public void getMapAsync(InteractionListener callbacks) {
        mCallbacks = callbacks;

        if (mLocationUpdatesEnabled)
            startLocationUpdates();
        else {
            Log.d(TAG, "Location updates disabled, disconnecting from GoogleClientApi.");
            disconnectFromGoogleClient();
        }

        getMapAsync(this);
    }

    public GoogleMap getGoogleMap() {
        return mGoogleMap;
    }

    public void setLocationEnabled(boolean locationEnabled) {
        mLocationEnabled = locationEnabled;
    }

    public void setLocationUpdatesEnabled(boolean locationUpdatesEnabled) {
        mLocationUpdatesEnabled = locationUpdatesEnabled;
    }

    public void setOnDragListener(GoogleMapLayout.OnDragListener onDragListener) {
        mOnDragListener = onDragListener;
    }

    public void updateCamera(LatLng loc, GoogleMap.CancelableCallback callback) {
        try {
            mGoogleMap.animateCamera(CameraUpdateFactory.newLatLngZoom(loc, ZOOM), 2000, callback);
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    public void updateCamera(LatLng loc) {
        updateCamera(loc, null);
    }

    private boolean isLocationPermissionGranted() {
        return mLocationEnabled && ContextCompat.checkSelfPermission(getContext(), PERMISSION_LOCATION) == GRANTED;
    }

    private void requestLocationPermission() {
        if (!mLocationEnabled)
            return;

        requestPermissions(
                new String[]{ Manifest.permission.ACCESS_FINE_LOCATION },
                REQUEST_LOCATION
        );
    }

    private void connectToGoogleClient() {
        if (mGoogleApiClient != null && !mGoogleApiClient.isConnected())
            mGoogleApiClient.connect();
    }

    private void disconnectFromGoogleClient() {
        if (mGoogleApiClient != null && mGoogleApiClient.isConnected())
            mGoogleApiClient.disconnect();
    }

    /**
     * The {@link #isLocationPermissionGranted()} should always be called before calling this
     * method, unless this method is called in
     * {@link #onRequestPermissionsResult(int, String[], int[])}.
     */
    @SuppressWarnings("ResourceType")
    private void enableMyLocation() {
        if (!mLocationEnabled)
            return;

        mGoogleMap.setMyLocationEnabled(true);
        startLocationUpdates();
    }

    /**
     * @see {@link #enableMyLocation()}
     */
    @SuppressWarnings("ResourceType")
    private void startLocationUpdates() {
        if (mGoogleApiClient == null || !mGoogleApiClient.isConnected())
            return;

        Log.d(TAG, "Starting location updates...");

        if (!isLocationPermissionGranted())
            return;

        LocationRequest request =
                new LocationRequest().setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, request, new LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                Log.d(TAG, "Received location update...");

                if (!mLocationUpdatesEnabled) {
                    LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, mDummyListener);
                    Log.d(TAG, "Removed location updates.");
                    return;
                }

                if (mCallbacks != null)
                    mCallbacks.onLocationUpdate(location);
            }
        });
    }

    // used to remove ambiguity in a FusedLocationApi.removeLocationUpdates call
    LocationListener mDummyListener = new LocationListener() {
        @Override
        public void onLocationChanged(Location location) {

        }
    };
}
