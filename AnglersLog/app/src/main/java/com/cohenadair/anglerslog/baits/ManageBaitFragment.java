package com.cohenadair.anglerslog.baits;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.fragments.ManageContentFragment;
import com.cohenadair.anglerslog.fragments.ManagePrimitiveFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.trips.ManageTripFragment;
import com.cohenadair.anglerslog.utilities.PrimitiveSpecManager;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.SelectionSpinnerView;
import com.cohenadair.anglerslog.views.TextInputView;
import com.cohenadair.anglerslog.views.TitleSubTitleView;

import java.util.ArrayList;

/**
 * The ManageBaitFragment is used to add and edit baits.
 */
public class ManageBaitFragment extends ManageContentFragment {

    private TitleSubTitleView mCategoryView;
    private TextInputView mNameView;
    private TextInputView mColorView;
    private TextInputView mSizeView;
    private TextInputView mDescriptionView;
    private SelectionSpinnerView mTypeSpinner;

    public ManageBaitFragment() {
        // Required empty public constructor
    }

    private Bait getNewBait() {
        return (Bait)getNewObject();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_manage_bait, container, false);

        initCategoryView(view);
        initNameView(view);
        initSelectPhotosView(view);
        initSpinner(view);
        initColorView(view);
        initSizeView(view);
        initDescriptionView(view);
        initSubclassObject();

        getSelectPhotosView().setMaxPhotos(1);

        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        initInputListeners();
    }

    @Override
    public ManageObjectSpec getManageObjectSpec() {
        return new ManageObjectSpec(R.string.error_bait, R.string.success_bait, R.string.error_bait_edit, R.string.success_bait_edit, new ManageInterface() {
            @Override
            public boolean onEdit() {
                return Logbook.editBait(getEditingId(), getNewBait());
            }

            @Override
            public boolean onAdd() {
                return Logbook.addBait(getNewBait());
            }
        });
    }

    @Override
    public void initSubclassObject() {
        initObject(new InitializeInterface() {
            @Override
            public UserDefineObject onGetOldObject() {
                return Logbook.getBait(getEditingId());
            }

            @Override
            public UserDefineObject onGetNewEditObject(UserDefineObject oldObject) {
                return new Bait((Bait)oldObject, true);
            }

            @Override
            public UserDefineObject onGetNewBlankObject() {
                return new Bait();
            }
        });
    }

    @Override
    public boolean verifyUserInput() {
        // category is set in the TitleSubtitleView interface
        // type is set in the Spinner interface
        // input properties are set in a OnTextChanged listener

        // category
        if (getNewBait().getCategory() == null) {
            Utils.showErrorAlert(getActivity(), R.string.error_bait_category);
            return false;
        }

        // name
        if (getNewBait().isNameNull()) {
            Utils.showErrorAlert(getActivity(), R.string.error_name);
            return false;
        }

        // name and category combo
        if (isNameDifferent() && Logbook.baitExists(getNewBait())) {
            Utils.showErrorAlert(getActivity(), R.string.error_bait_category_name);
            return false;
        }

        return true;
    }

    @Override
    public void updateViews() {
        mCategoryView.setSubtitle(getNewBait().getBaitCategoryAsString());
        mNameView.setInputText(getNewBait().getNameAsString());
        mColorView.setInputText(getNewBait().getColorAsString());
        mSizeView.setInputText(getNewBait().getSizeAsString());
        mDescriptionView.setInputText(getNewBait().getDescriptionAsString());
        mTypeSpinner.setSelection(getNewBait().getType());
    }

    private void initCategoryView(View view) {
        final ManagePrimitiveFragment.OnDismissInterface onDismissInterface = new ManagePrimitiveFragment.OnDismissInterface() {
            @Override
            public void onDismiss(ArrayList<UserDefineObject> selectedItems) {
                getNewBait().setCategory((BaitCategory)selectedItems.get(0));
                mCategoryView.setSubtitle(getNewBait().getCategoryName());
            }
        };

        mCategoryView = (TitleSubTitleView)view.findViewById(R.id.category_view);
        mCategoryView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showCategoryDialog(onDismissInterface);
            }
        });
    }

    private void showCategoryDialog(ManagePrimitiveFragment.OnDismissInterface onDismissInterface) {
        ManagePrimitiveFragment fragment = ManagePrimitiveFragment.newInstance(PrimitiveSpecManager.BAIT_CATEGORY, false);
        fragment.setOnDismissInterface(onDismissInterface);
        fragment.show(getFragmentManager(), "dialog");
    }

    private void initNameView(View view) {
        mNameView = (TextInputView)view.findViewById(R.id.name_view);
    }

    private void initColorView(View view) {
        mColorView = (TextInputView)view.findViewById(R.id.color_view);
    }

    private void initSizeView(View view) {
        mSizeView = (TextInputView)view.findViewById(R.id.size_view);
    }

    private void initDescriptionView(View view) {
        mDescriptionView = (TextInputView)view.findViewById(R.id.description_view);
    }

    private void initSpinner(View view) {
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(getContext(), R.array.bait_types, R.layout.list_item_spinner);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        mTypeSpinner = (SelectionSpinnerView)view.findViewById(R.id.type_spinner);
        mTypeSpinner.setAdapter(adapter);
        mTypeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                getNewBait().setType(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    /**
     * See {@link ManageTripFragment#initInputListeners()}.
     */
    private void initInputListeners() {
        mNameView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setName(newText);
            }
        }));

        mDescriptionView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setDescription(newText);
            }
        }));

        mSizeView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setSize(newText);
            }
        }));

        mColorView.addOnInputTextChangedListener(Utils.onTextChangedListener(new Utils.OnTextChangedListener() {
            @Override
            public void onTextChanged(String newText) {
                getNewBait().setColor(newText);
            }
        }));
    }

}
