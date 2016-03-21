package com.cohenadair.anglerslog.catches;

import android.Manifest;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;

import com.android.volley.RequestQueue;
import com.android.volley.toolbox.Volley;
import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.trips.ManageTripFragment;
import com.cohenadair.anglerslog.utilities.LayoutSpecManager;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.InputButtonView;
import com.cohenadair.anglerslog.views.SelectionSpinnerView;
import com.cohenadair.anglerslog.views.TextInputView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;
import com.cohenadair.anglerslog.views.WeatherView;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.model.LatLng;

import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

/**
 * The ManageBaitFragment is used to add and edit catches.
 */
public class ManageCatchFragment extends ManageContentFragment {

    private InputButtonView mDateTimeView;
    private InputButtonView mSpeciesView;
    private InputButtonView mLocationView;
    private InputButtonView mBaitView;
    private TitleSubTitleView mWaterClarityView;
    private TitleSubTitleView mFishingMethodsView;
    private TextInputView mQuantityView;
    private TextInputView mLengthView;
    private TextInputView mWeightView;
    private TextInputView mWaterDepthView;
    private TextInputView mWaterTemperatureView;
    private TextInputView mNotesView;
    private SelectionSpinnerView mResultSpinner;
    private WeatherView mWeatherView;

    private RequestQueue mRequestQueue;
    private GoogleApiClient mGoogleApiClient;

    /**
     * Used so there is no database interaction until the user saves their changes.
     */
    private ArrayList<UUID> mSelectedFishingMethods;
    private Weather mWeather;

    public ManageCatchFragment() {
        // Required empty public constructor
    }

    private Catch getNewCatch() {
        return (Catch)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_catch, container, false);

        initGoogleApi();
        initDateTimeView(view);
        initSpeciesView(view);
        initLocationView(view);
        initBaitView(view);
        initSelectPhotosView(view);
        initWaterClarityView(view);
        initFishingMethodsView(view);
        initResultView(view);
        initWeatherView(view);

        mQuantityView = (TextInputView)view.findViewById(R.id.quantity_view);
        mLengthView = (TextInputView)view.findViewById(R.id.length_view);
        mWeightView = (TextInputView)view.findViewById(R.id.weight_view);
        mWaterDepthView = (TextInputView)view.findViewById(R.id.water_depth_view);
        mWaterTemperatureView = (TextInputView)view.findViewById(R.id.water_temperature_view);
        mNotesView = (TextInputView)view.findViewById(R.id.notes_view);

        initSubclassObject();

        // reset for each time the view is created
        if (!isEditing()) {
            mSelectedFishingMethods = new ArrayList<>();
            mWeather = null;
        }

        mRequestQueue = Volley.newRequestQueue(getContext());

        return view;
    }

    @Override
    public void onStart() {
        mGoogleApiClient.connect();
        super.onStart();
    }

    @Override
    public void onStop() {
        mGoogleApiClient.disconnect();
        super.onStop();
    }

    @Override
    public void onResume() {
        super.onResume();
        initInputListeners();
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_catch, R.string.success_catch, R.string.error_catch_edit, R.string.success_catch_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editCatch(getEditingId(), getNewCatch());
            }

            @Override
            public boolean onAdd() {
                return Logbook.addCatch(getNewCatch());
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getCatch(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                Catch newCatch = new Catch((Catch) oldObject, true);
                mSelectedFishingMethods = UserDefineArrays.asIdArray(newCatch.getFishingMethods());
                mWeather = newCatch.getWeather();
                return newCatch;
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Catch(new Date());
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        // species
        if (getNewCatch().getSpecies() == null) {
            Utils.showErrorAlert(getActivity(), R.string.error_catch_species);
            return false;
        }

        // all input properties are set using an OnTextChanged listener

        // update properties that interact directly with the database
        getNewCatch().setWeather(mWeather);
        getNewCatch().setFishingMethods(getSelectedFishingMethods());

        return true;
    }

    @Override
    public void updateViews() {
        mDateTimeView.setPrimaryButtonText(getNewCatch().getDateAsString());
        mDateTimeView.setSecondaryButtonText(getNewCatch().getTimeAsString());
        mSpeciesView.setPrimaryButtonText(getNewCatch().getSpeciesAsString());
        mBaitView.setPrimaryButtonText(getNewCatch().getBaitAsString());
        mLocationView.setPrimaryButtonText(getNewCatch().getFishingSpotAsString());
        mWaterClarityView.setSubtitle(getNewCatch().getWaterClarityAsString());
        mFishingMethodsView.setSubtitle(UserDefineArrays.namesAsString(getSelectedFishingMethods()));
        mResultSpinner.setSelection(getNewCatch().getCatchResult().getValue());
        mWeatherView.updateViews(mWeather);
        mQuantityView.setInputText(getNewCatch().getQuantityAsString());
        mLengthView.setInputText(getNewCatch().getLengthAsString());
        mWeightView.setInputText(getNewCatch().getWeightAsString());
        mWaterDepthView.setInputText(getNewCatch().getWaterDepthAsString());
        mWaterTemperatureView.setInputText(getNewCatch().getWaterTemperatureAsString());
        mNotesView.setInputText(getNewCatch().getNotesAsString());
    }

    //region Google API
    private void initGoogleApi() {
        if (mGoogleApiClient != null)
            return;

        mGoogleApiClient = new GoogleApiClient.Builder(getContext())
                .addConnectionCallbacks(new GoogleApiClient.ConnectionCallbacks() {
                    @Override
                    public void onConnected(Bundle bundle) {

                    }

                    @Override
                    public void onConnectionSuspended(int i) {

                    }
                })
                .addApi(LocationServices.API)
                .build();
    }
    //endregion

    //region Date & Time
    private void initDateTimeView(View view) {
        mDateTimeView = (InputButtonView)view.findViewById(R.id.date_time_view);

        mDateTimeView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDatePickerFragment(getNewCatch().getDate(), new DateTimePickerInterface() {
                    @Override
                    public void onFinish(Date date) {
                        getNewCatch().setDate(date);
                        mDateTimeView.setPrimaryButtonText(getNewCatch().getDateAsString());
                    }
                });
            }
        });

        mDateTimeView.setOnClickSecondaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showTimePickerFragment(getNewCatch().getDate(), new DateTimePickerInterface() {
                    @Override
                    public void onFinish(Date date) {
                        getNewCatch().setDate(date);
                        mDateTimeView.setSecondaryButtonText(getNewCatch().getTimeAsString());
                    }
                });
            }
        });
    }
    //endregion

    private void initSpeciesView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UUID> selectedIds) {
                getNewCatch().setSpecies(Logbook.getSpecies(selectedIds.get(0)));
                mSpeciesView.setPrimaryButtonText(getNewCatch().getSpeciesAsString());
            }
        };

        mSpeciesView = (InputButtonView)view.findViewById(R.id.species_view);
        mSpeciesView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.SPECIES, false, null, onDismissInterface);
            }
        });
    }

    private void initLocationView(View view) {
        mLocationView = (InputButtonView)view.findViewById(R.id.location_view);
        mLocationView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startSelectionActivity(LayoutSpecManager.LAYOUT_LOCATIONS, new OnSelectionActivityResult() {
                    @Override
                    public void onSelect(ArrayList<String> ids) {
                        // should be one and only one element in ids
                        getNewCatch().setFishingSpot(Logbook.getFishingSpot(UUID.fromString(ids.get(0))));
                    }
                });
            }
        });
    }

    private void initBaitView(View view) {
        mBaitView = (InputButtonView)view.findViewById(R.id.bait_view);
        mBaitView.setOnClickPrimaryButton(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startSelectionActivity(LayoutSpecManager.LAYOUT_BAITS, new OnSelectionActivityResult() {
                    @Override
                    public void onSelect(ArrayList<String> ids) {
                        // should be one and only one element in ids
                        getNewCatch().setBait(Logbook.getBait(UUID.fromString(ids.get(0))));
                    }
                });
            }
        });
    }

    private void initWaterClarityView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UUID> selectedIds) {
                getNewCatch().setWaterClarity(Logbook.getWaterClarity(selectedIds.get(0)));
                mWaterClarityView.setSubtitle(getNewCatch().getWaterClarityAsString());
            }
        };

        mWaterClarityView = (TitleSubTitleView)view.findViewById(R.id.clarity_layout);
        mWaterClarityView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.WATER_CLARITY, false, null, onDismissInterface);
            }
        });
    }

    private void initFishingMethodsView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UUID> selectedIds) {
                mSelectedFishingMethods = selectedIds;
                mFishingMethodsView.setSubtitle(UserDefineArrays.namesAsString(getSelectedFishingMethods()));
            }
        };

        mFishingMethodsView = (TitleSubTitleView)view.findViewById(R.id.methods_layout);
        mFishingMethodsView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showPrimitiveDialog(PrimitiveSpecManager.FISHING_METHODS, true, mSelectedFishingMethods, onDismissInterface);
            }
        });
    }

    private void initResultView(View view) {
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(getContext(), R.array.result_types, R.layout.list_item_spinner);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        mResultSpinner = (SelectionSpinnerView)view.findViewById(R.id.result_spinner);
        mResultSpinner.setAdapter(adapter);
        mResultSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                getNewCatch().setCatchResult(Catch.CatchResult.fromInt(position));
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    //region Weather View
    private void initWeatherView(View view) {
        mWeatherView = (WeatherView)view.findViewById(R.id.weather_view);
        mWeatherView.setListener(new WeatherView.InteractionListener() {
            @Override
            public void onClickButton() {
                openEditWeatherDialog();
            }
        });
    }

    private void updateWeatherView(Weather weather) {
        mWeatherView.updateViews(weather);
        mWeather = weather;
    }

    private void openEditWeatherDialog() {
        WeatherView.EditDialog editDialog = WeatherView.EditDialog.newInstance(mWeather);

        editDialog.setInteractionListener(new WeatherView.EditDialog.InteractionListener() {
            @Override
            public void onClear() {
                mWeather = null;
                updateWeatherView(null);
            }

            @Override
            public void onSave(Weather weather) {
                updateWeatherView(weather);
            }

            @Override
            public void onClickRefresh(WeatherView.EditDialog.OnGetWeatherListener l) {
                requestWeatherData(l);
            }
        });

        editDialog.show(getChildFragmentManager(), "EditWeatherDialog");
    }

    private void requestWeatherData(final WeatherView.EditDialog.OnGetWeatherListener l) {
        if (!mGoogleApiClient.isConnected()) {
            Utils.showToast(getContext(), R.string.error_google_services);
            return;
        }

        if (!Utils.requestLocationServices(getContext()))
            return;

        Location loc = null;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (getContext().checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)
                loc = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
        } else
            loc = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);

        if (loc == null) {
            Utils.showToast(getContext(), R.string.error_user_location);
            return;
        }

        final Weather weather = new Weather(new LatLng(loc.getLatitude(), loc.getLongitude()));
        String units = getResources().getStringArray(R.array.pref_unitTypes_entries)[LogbookPreferences.getWeatherUnits()];

        mRequestQueue.add(weather.getRequest(units, new Weather.OnFetchInterface() {
            @Override
            public void onSuccess() {
                l.onSuccess(weather);
            }

            @Override
            public void onError() {
                Utils.showToast(getContext(), R.string.error_getting_weather);
            }
        }));
    }
    //endregion

    private ArrayList<UserDefineObject> getSelectedFishingMethods() {
        return UserDefineArrays.objectsFromIds(mSelectedFishingMethods, new UserDefineArrays.OnConvertInterface() {
            @Override
            public UserDefineObject onGetObject(String idStr) {
                return Logbook.getFishingMethod(UUID.fromString(idStr));
            }
        });
    }

    /**
     * See {@link ManageTripFragment#initInputListeners()}.
     */
    private void initInputListeners() {
        mNotesView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewCatch().setNotes(newText);
            }
        }));

        mWaterTemperatureView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewCatch().setWaterTemperature((int) asFloat(newText, -1));
            }
        }));

        mWaterDepthView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewCatch().setWaterDepth(asFloat(newText, -1));
            }
        }));

        mWeightView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewCatch().setWeight(asFloat(newText, -1));
            }
        }));

        mLengthView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewCatch().setLength(asFloat(newText, -1));
            }
        }));

        mQuantityView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewCatch().setQuantity((int) asFloat(newText, 1));
            }
        }));
    }

    private float asFloat(String str, float defaultValue) {
        if (str.isEmpty())
            return defaultValue;

        return Float.parseFloat(str);
    }
}
