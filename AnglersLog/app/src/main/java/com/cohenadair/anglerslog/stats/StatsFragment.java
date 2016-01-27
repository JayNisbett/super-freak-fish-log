package com.cohenadair.anglerslog.stats;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.CardDetailActivity;
import com.cohenadair.anglerslog.activities.LayoutSpecActivity;
import com.cohenadair.anglerslog.fragments.MasterFragment;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.Utils;
import com.cohenadair.anglerslog.views.DefaultCardView;

/**
 * The StatsFragment is the fragment that displays statistical summaries of the Logbook's data.
 * Created by Cohen Adair on 2016-01-26.
 */
public class StatsFragment extends MasterFragment {

    private DefaultCardView mSpeciesCard;
    private DefaultCardView mBaitsCard;
    private DefaultCardView mLocationsCard;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.stats_layout, container, false);

        mSpeciesCard = (DefaultCardView)view.findViewById(R.id.species_card);
        mBaitsCard = (DefaultCardView)view.findViewById(R.id.baits_card);
        mLocationsCard = (DefaultCardView)view.findViewById(R.id.locations_card);

        update(getRealActivity());

        return view;
    }

    @Override
    public void update(LayoutSpecActivity activity) {
        mSpeciesCard.init(getContext().getResources().getString(R.string.species_caught), Logbook.getSpeciesCaughtCount(), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startCardDetailActivity(StatsManager.STATS_SPECIES);
            }
        });

        mBaitsCard.init(getContext().getResources().getString(R.string.baits_used), Logbook.getBaitUsedCount(), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startCardDetailActivity(StatsManager.STATS_BAITS);
            }
        });

        mLocationsCard.init(getContext().getResources().getString(R.string.location_success), Logbook.getLocationCatchCount(), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startCardDetailActivity(StatsManager.STATS_LOCATIONS);
            }
        });
    }

    private void startCardDetailActivity(int statsId) {
        Intent intent = new Intent(getContext(), CardDetailActivity.class);
        intent.putExtra(CardDetailActivity.EXTRA_TWO_PANE, Utils.isTwoPane(getActivity()));
        intent.putExtra(CardDetailActivity.EXTRA_STATS_ID, statsId);
        startActivity(intent);
    }
}
