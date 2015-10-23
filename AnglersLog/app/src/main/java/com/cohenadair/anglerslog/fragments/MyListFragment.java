package com.cohenadair.anglerslog.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.utilities.LayoutController;

/**
 * The fragment showing the list of catches.
 */
public class MyListFragment extends Fragment {

    //region Callback Interface
    InteractionListener mCallbacks;

    /**
     * Callback interface must be implemented by any Activity implementing MyListFragment.
     */
    public interface InteractionListener {
        void onMyListClickNewButton();
    }
    //endregion

    public MyListFragment() {
        // default constructor required
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_mylist, container, false);

        if (view != null) {
            initNewButton(view);
            initRecyclerView(view);
        }

        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        // make sure the container activity has implemented the callback interface
        try {
            mCallbacks = (InteractionListener)context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement MyListFragment.InteractionListener.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    //region View Initializing
    private void initRecyclerView(View view) {
        RecyclerView recyclerView = (RecyclerView)view.findViewById(R.id.main_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        recyclerView.setAdapter(LayoutController.getMasterAdapter());
    }

    private void initNewButton(View view) {
        FloatingActionButton newButton = (FloatingActionButton)view.findViewById(R.id.new_button);
        newButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallbacks.onMyListClickNewButton();
            }
        });
    }
    //endregion
}
