package com.cohenadair.anglerslog.locations;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManageFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.MoreDetailView;
import com.cohenadair.anglerslog.views.TextInputView;

import java.util.ArrayList;
import java.util.UUID;

/**
 * The ManageLocationFragment is used to add and edit locations.
 */
public class ManageLocationFragment extends ManageContentFragment {

    private LinearLayout mContainer;
    private TextInputView mNameView;

    private ArrayList<MoreDetailView> mFishingSpotViews;
    private ArrayList<UserDefineObject> mFishingSpots;

    public ManageLocationFragment() {
        // Required empty public constructor
    }

    private Location getNewLocation() {
        return (Location)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_location, container, false);

        mContainer = (LinearLayout)view.findViewById(R.id.container);
        initNameView(view);
        initAddFishingSpotButton(view);
        initSubclassObject();

        if (mFishingSpots == null || !isEditing())
            mFishingSpots = new ArrayList<>();

        if (mFishingSpotViews == null)
            mFishingSpotViews = new ArrayList<>();

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        mNameView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewLocation().setName(newText);
            }
        }));
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_location_add, R.string.success_location_add, R.string.error_location_edit, R.string.success_location_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                if (Logbook.editLocation(getEditingId(), getNewLocation())) {
                    getNewLocation().setFishingSpots(mFishingSpots);
                    return true;
                }

                return false;
            }

            @Override
            public boolean onAdd() {
                if (Logbook.addLocation(getNewLocation())) {
                    getNewLocation().setFishingSpots(mFishingSpots);
                    return true;
                }

                return false;
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getLocation(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                Location loc = new Location((Location)oldObject, true);
                mFishingSpots = loc.getFishingSpots();
                return loc;
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Location();
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        Location loc = getNewLocation();

        // name
        if (loc.isNameNull()) {
            Utils.showErrorAlert(getActivity(), R.string.error_name);
            return false;
        }

        // duplicate name
        if (isNameDifferent() && Logbook.locationExists(loc)) {
            Utils.showErrorAlert(getActivity(), R.string.error_location_name);
            return false;
        }

        // fishing spots
        if (mFishingSpots.size() <= 0) {
            Utils.showErrorAlert(getActivity(), R.string.error_no_fishing_spots);
            return false;
        }

        return true;
    }

    @Override
    public void updateViews() {
        mNameView.setInputText(getNewLocation().getName() != null ? getNewLocation().getName() : "");
        updateAllFishingSpots();
    }

    private void updateAllFishingSpots() {
        // remove all old views
        for (MoreDetailView fishingSpotView : mFishingSpotViews) {
            ViewGroup parent = ((ViewGroup)fishingSpotView.getParent());
            if (parent != null)
                parent.removeView(fishingSpotView);
        }

        for (UserDefineObject spot : mFishingSpots)
            addFishingSpot((FishingSpot)spot);
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    private void initAddFishingSpotButton(View view) {
        ImageButton fishingSpotButton = (ImageButton)view.findViewById(R.id.add_button);
        fishingSpotButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                goToManageFishingSpot(null);
            }
        });
    }

    private void addFishingSpot(final FishingSpot spot) {
        String lat = getContext().getResources().getString(R.string.latitude);
        String lng = getContext().getResources().getString(R.string.longitude);

        final MoreDetailView fishingSpotView = new MoreDetailView(getContext());
        fishingSpotView.setTitle(spot.getName());
        fishingSpotView.setSubtitle(spot.getCoordinatesAsString(lat, lng));
        fishingSpotView.setDetailButtonImage(R.drawable.ic_remove);
        fishingSpotView.setTitleStyle(R.style.TextView_Small);
        fishingSpotView.setSubtitleStyle(R.style.TextView_SmallSubtitle);
        fishingSpotView.useDefaultSpacing();
        fishingSpotView.useDefaultStyle();

        fishingSpotView.setOnClickDetailButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFishingSpots.remove(spot);
                mContainer.removeView(fishingSpotView);
            }
        });

        fishingSpotView.setOnClickContent(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                goToManageFishingSpot(spot.getId());
            }
        });

        mFishingSpotViews.add(fishingSpotView);
        mContainer.addView(fishingSpotView);
    }

    /**
     * Opens a ManageFishingSpotFragment dialog.
     * @param editingId The editing id of the fishing spot, or null if a new spot is being added.
     */
    private void goToManageFishingSpot(UUID editingId) {
        final ManageFishingSpotFragment fragment = new ManageFishingSpotFragment();

        if (editingId != null)
            fragment.setIsEditing(true, editingId);

        fragment.setLocation(getNewLocation());

        fragment.setOnVerifyInterface(new ManageFishingSpotFragment.OnVerifyInterface() {
            @Override
            public boolean isDuplicate(FishingSpot fishingSpot) {
                for (UserDefineObject obj : mFishingSpots)
                    if (obj.getName().equals(fishingSpot.getName()))
                        return true;

                return false;
            }
        });

        fragment.setManageObjectSpec(new ManageObjectSpec(R.string.error_fishing_spot_add, R.string.success_fishing_spot_add, R.string.error_fishing_spot_edit, R.string.success_fishing_spot_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                for (int i = 0; i < mFishingSpots.size(); i++)
                    // update the fishing spot if this is the one we're editing
                    if (mFishingSpots.get(i).getId().equals(fragment.getNewFishingSpot().getId())) {
                        mFishingSpots.set(i, new FishingSpot(fragment.getNewFishingSpot(), true));
                        updateViews();
                        return true;
                    }

                return false;
            }

            @Override
            public boolean onAdd() {
                mFishingSpots.add(fragment.getNewFishingSpot());
                addFishingSpot(fragment.getNewFishingSpot());
                return true;
            }
        }));

        fragment.setInitializeInterface(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return getFishingSpot(fragment.getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                return new FishingSpot((FishingSpot) oldObject, true);
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new FishingSpot();
            }
        });

        ManageFragment manageFragment = new ManageFragment();
        manageFragment.setNoTitle(true);
        manageFragment.setContentFragment(fragment);
        manageFragment.show(getChildFragmentManager(), null);
    }

    @Nullable
    private FishingSpot getFishingSpot(UUID id) {
        for (UserDefineObject fishingSpot : mFishingSpots)
            if (fishingSpot.getId().equals(id))
                return (FishingSpot)fishingSpot;

        return null;
    }

}
