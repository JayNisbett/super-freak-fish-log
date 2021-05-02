// ignore_for_file: lines_longer_than_80_chars

Map<String, Map<String, String>> get englishStrings => {
      "US": {
        "catchField_favorite": "Favorite",
        "catchField_favoriteDescription": "A favorite catch.",
        "saveReportPage_favorites": "Favorites Only",
      },
      "CA": {
        "catchField_favorite": "Favourite",
        "catchField_favoriteDescription": "A favourite catch.",
        "saveReportPage_favorites": "Favourites",
      },
      "default": {
        "appName": "Anglers' Log",
        "rateDialog_title": "Rate Anglers' Log",
        "rateDialog_description":
            "Please take a moment to write a review of Anglers' Log. All feedback is greatly appreciated!",
        "rateDialog_rate": "Rate",
        "rateDialog_later": "Later",
        "cancel": "Cancel",
        "done": "Done",
        "save": "Save",
        "edit": "Edit",
        "delete": "Delete",
        "none": "None",
        "all": "All",
        "next": "Next",
        "ok": "Ok",
        "error": "Error",
        "warning": "Warning",
        "continue": "Continue",
        "yes": "Yes",
        "no": "No",
        "clear": "Clear",
        "today": "Today",
        "yesterday": "Yesterday",
        "directions": "Directions",
        "latLng": "Lat: %s, Lng: %s",
        "latLng_noLabels": "%s, %s",
        "add": "Add",
        "more": "More",
        "customFields": "Custom Fields",
        "na": "N/A",
        "finish": "Finish",
        "by": "by",
        "unknown": "Unknown",
        "devName": "Cohen Adair",
        "unknownSpecies": "Unknown Species",
        "fieldType_number": "Number",
        "fieldType_boolean": "Checkbox",
        "fieldType_text": "Text",
        "input_requiredMessage": "%s is required",
        "input_nameLabel": "Name",
        "input_genericRequired": "Required",
        "input_descriptionLabel": "Description",
        "input_invalidNumber": "Invalid number input",
        "input_photoLabel": "Photo",
        "input_photosLabel": "Photos",
        "input_notSelected": "Not Selected",
        "input_emailLabel": "Email",
        "input_invalidEmail": "Invalid email format",
        "input_passwordLabel": "Password",
        "input_passwordInvalidLength":
            "Password length must be greater than 6 characters",
        "addAnythingPage_catch": "Catch",
        "addAnythingPage_trip": "Trip",
        "catchListPage_menuLabel": "Catches",
        "catchListPage_title": "Catches (%s)",
        "catchListPage_searchHint": "Search catches",
        "catchListPage_emptyListTitle": "No catches",
        "catchListPage_emptyListDescription":
            "You haven't yet added any catches. Tap the %s button to begin.",
        "catchPage_deleteMessage":
            "Are you sure you want to delete catch %s? This cannot be undone.",
        "saveCatchPage_newTitle": "New Catch",
        "saveCatchPage_editTitle": "Edit Catch",
        "catchField_dateTime": "Date & Time",
        "catchField_date": "Date",
        "catchField_time": "Time",
        "catchField_period": "Time Of Day",
        "catchField_periodDescription": "Such as dawn, morning, dusk, etc.",
        "catchField_species": "Species",
        "catchField_images": "Photos",
        "catchField_fishingSpot": "Fishing Spot",
        "catchField_fishingSpotDescription":
            "Coordinates of where a catch was made.",
        "catchField_bait": "Bait",
        "catchField_angler": "Angler",
        "catchField_methods": "Fishing Methods",
        "catchField_methodsDescription": "The way in which a catch was made.",
        "catchField_noMethods": "No fishing methods",
        "saveReportPage_newTitle": "New Report",
        "saveReportPage_editTitle": "Edit Report",
        "saveReportPage_nameExists": "Report name already exists",
        "saveReportPage_typeTitle": "Type",
        "saveReportPage_comparison": "Comparison",
        "saveReportPage_summary": "Summary",
        "saveReportPage_startDateRangeLabel": "Compare",
        "saveReportPage_endDateRangeLabel": "To",
        "saveReportPage_allAnglers": "All anglers",
        "saveReportPage_species": "Species",
        "saveReportPage_allSpecies": "All species",
        "saveReportPage_allBaits": "All baits",
        "saveReportPage_allFishingSpots": "All fishing spots",
        "saveReportPage_allMethods": "All fishing methods",
        "photosPage_menuLabel": "Photos",
        "photosPage_title": "Photos (%s)",
        "photosPage_emptyTitle": "No photos",
        "photosPage_emptyDescription":
            "All photos attached to catches will be displayed here. To add a catch, tap the %s icon.",
        "baitListPage_menuLabel": "Baits",
        "baitListPage_title": "Baits (%s)",
        "baitListPage_pickerTitle": "Select Bait",
        "baitListPage_pickerTitleMulti": "Select Baits",
        "baitListPage_otherCategory": "No Category",
        "baitListPage_searchHint": "Search baits",
        "baitListPage_deleteMessage":
            "%s is associated with %s catches; are you sure you want to delete it? This cannot be undone.",
        "baitListPage_deleteMessageSingular":
            "%s is associated with %s catch; are you sure you want to delete it? This cannot be undone.",
        "baitListPage_emptyListTitle": "No baits",
        "baitListPage_emptyListDescription":
            "You haven't yet added any baits. Tap the %s button to begin.",
        "saveBaitPage_newTitle": "New Bait",
        "saveBaitPage_editTitle": "Edit Bait",
        "saveBaitPage_categoryLabel": "Bait Category",
        "saveBaitPage_baitExists":
            "A bait with these properties already exists. Please change at least one field and try again.",
        "saveBaitCategoryPage_newTitle": "New Bait Category",
        "saveBaitCategoryPage_editTitle": "Edit Bait Category",
        "saveBaitCategoryPage_existsMessage": "Bait category already exists",
        "baitCategoryListPage_menuTitle": "Bait Categories",
        "baitCategoryListPage_title": "Bait Categories (%s)",
        "baitCategoryListPage_pickerTitle": "Select Bait Category",
        "baitCategoryListPage_deleteMessage":
            "%s is associated with %s baits; are you sure you want to delete it? This cannot be undone.",
        "baitCategoryListPage_deleteMessageSingular":
            "%s is associated with %s bait; are you sure you want to delete it? This cannot be undone.",
        "baitCategoryListPage_searchHint": "Search bait categories",
        "baitCategoryListPage_emptyListTitle": "No bait categories",
        "baitCategoryListPage_emptyListDescription":
            "You haven't yet added any bait categories. Tap the %s button to begin.",
        "saveAnglerPage_newTitle": "New Angler",
        "saveAnglerPage_editTitle": "Edit Angler",
        "saveAnglerPage_existsMessage": "Angler already exists",
        "anglerListPage_menuTitle": "Anglers",
        "anglerListPage_title": "Anglers (%s)",
        "anglerListPage_pickerTitle": "Select Angler",
        "anglerListPage_deleteMessage":
            "%s is associated with %s catches; are you sure you want to delete them? This cannot be undone.",
        "anglerListPage_deleteMessageSingular":
            "%s is associated with %s catch; are you sure you want to delete them? This cannot be undone.",
        "anglerListPage_searchHint": "Search anglers",
        "anglerListPage_emptyListTitle": "No anglers",
        "anglerListPage_emptyListDescription":
            "You haven't yet added any anglers. Tap the %s button to begin.",
        "saveMethodPage_newTitle": "New Fishing Method",
        "saveMethodPage_editTitle": "Edit Fishing Method",
        "saveMethodPage_existsMessage": "Fishing method already exists",
        "methodListPage_menuTitle": "Fishing Methods",
        "methodListPage_title": "Fishing Methods (%s)",
        "methodListPage_pickerTitle": "Select Fishing Methods",
        "methodListPage_deleteMessage":
            "%s is associated with %s catches; are you sure you want to delete it? This cannot be undone.",
        "methodListPage_deleteMessageSingular":
            "%s is associated with %s catch; are you sure you want to delete it? This cannot be undone.",
        "methodListPage_searchHint": "Search fishing methods",
        "methodListPage_emptyListTitle": "No fishing methods",
        "methodListPage_emptyListDescription":
            "You haven't yet added any fishing methods. Tap the %s button to begin.",
        "statsPage_menuTitle": "Stats",
        "statsPage_title": "Stats",
        "statsPage_reportOverview": "Overview",
        "statsPage_newReport": "New Report",
        "reportView_noCatches": "No catches found",
        "reportView_noCatchesDescription":
            "No catches found in the selected date range.",
        "reportView_noCatchesReportDescription":
            "No catches found in the selected report's date range.",
        "reportSummary_viewCatches": "View catches (%s)",
        "reportSummary_catchTitle": "Catch Summary",
        "reportSummary_perSpecies": "Per species",
        "reportSummary_perFishingSpot": "Per fishing spot",
        "reportSummary_perBait": "Per bait",
        "reportSummary_sinceLastCatch": "Since last catch",
        "reportSummary_numberOfCatches": "Number of catches",
        "reportSummary_filters": "Filters",
        "reportSummary_viewSpecies": "View all species",
        "reportSummary_catchesPerSpeciesDescription":
            "Viewing number of catches per species.",
        "reportSummary_viewFishingSpots": "View all fishing spots",
        "reportSummary_catchesPerFishingSpotDescription":
            "Viewing number of catches per fishing spot.",
        "reportSummary_viewBaits": "View all baits",
        "reportSummary_catchesPerBaitDescription":
            "Viewing number of catches per bait.",
        "reportSummary_speciesTitle": "Species Summary",
        "reportSummary_baitsPerSpeciesDescription":
            "Viewing number of catches per species per bait.",
        "reportSummary_fishingSpotsPerSpeciesDescription":
            "Viewing number of catches per species per fishing spot.",
        "dateRangePickerPage_title": "Select Date Range",
        "morePage_title": "More",
        "morePage_rateApp": "Rate Anglers' Log",
        "morePage_pro": "Anglers' Log Pro",
        "tripListPage_menuLabel": "Trips",
        "tripListPage_title": "Trips (%s)",
        "settingsPage_title": "Settings",
        "settingsPage_logout": "Logout",
        "settingsPage_logoutConfirmMessage": "Are you sure you want to logout?",
        "mapPage_menuLabel": "Map",
        "mapPage_deleteFishingSpot":
            "%s is associated with %s catches; are you sure you want to delete it? This cannot be undone.",
        "mapPage_deleteFishingSpotSingular":
            "%s is associated with %s catch; are you sure you want to delete it? This cannot be undone.",
        "mapPage_deleteFishingSpotNoName":
            "This fishing spot is associated with %s catches; are you sure you want to delete it? This cannot be undone.",
        "mapPage_deleteFishingSpotNoNameSingular":
            "This fishing spot is associated with %s catch; are you sure you want to delete it? This cannot be undone.",
        "mapPage_addCatch": "Add Catch",
        "mapPage_searchHint": "Search fishing spots",
        "mapPage_droppedPin": "Dropped Pin",
        "mapPage_mapTypeNormal": "Normal",
        "mapPage_mapTypeSatellite": "Satellite",
        "mapPage_mapTypeTerrain": "Terrain",
        "mapPage_mapTypeHybrid": "Hybrid",
        "mapPage_errorGettingLocation":
            "Unable to retrieve current location. Please try again later.",
        "mapPage_errorOpeningDirections":
            "There are no navigation apps available on this device.",
        "mapPage_appleMaps": "Apple Maps",
        "mapPage_googleMaps": "Google Maps",
        "mapPage_waze": "Waze",
        "saveFishingSpotPage_newTitle": "New Fishing Spot",
        "saveFishingSpotPage_editTitle": "Edit Fishing Spot",
        "formPage_manageFieldText": "Manage Fields",
        "formPage_removeFieldsText": "Remove Fields",
        "formPage_confirmRemoveField": "Remove 1 Field",
        "formPage_confirmRemoveFields": "Remove %s Fields",
        "formPage_selectFieldsTitle": "Select Fields",
        "formPage_addCustomFieldNote":
            "To add a custom field, tap the %s icon.",
        "formPage_manageFieldsNote": "To manage fields, tap the %s icon.",
        "saveCustomEntityPage_newTitle": "New Field",
        "saveCustomEntityPage_editTitle": "Edit Field",
        "saveCustomEntityPage_nameExists": "Field name already exists",
        "customEntityListPage_title": "Custom Fields (%s)",
        "customEntityListPage_delete":
            "The custom field %s will no longer be associated with catches (%s) or baits (%s), are you sure you want to delete it? This cannot be undone.",
        "customEntityListPage_searchHint": "Search fields",
        "customEntityListPage_emptyListTitle": "No custom fields",
        "customEntityListPage_emptyListDescription":
            "You haven't yet added any custom fields. Tap the %s button to begin.",
        "imagePickerPage_noPhotosFoundTitle": "No photos found",
        "imagePickerPage_noPhotosFound":
            "Try changing the photo source from the dropdown above.",
        "imagePickerPage_openCameraLabel": "Open Camera",
        "imagePickerPage_cameraLabel": "Camera",
        "imagePickerPage_galleryLabel": "Gallery",
        "imagePickerPage_browseLabel": "Browse",
        "imagePickerPage_selectedLabel": "%s / %s Selected",
        "imagePickerPage_invalidSelectionSingle": "Must select an image file.",
        "imagePickerPage_invalidSelectionPlural": "Must select image files.",
        "imagePickerPage_noPermissionTitle": "Permission required",
        "imagePickerPage_noPermissionMessage":
            "To add photos, you must grant Anglers' Log permission to access your photo library. To do so, open your device settings.\n\nAlternatively, you can change the photos source from the dropdown menu above.",
        "imagePickerPage_openSettings": "Open Settings",
        "reportListPage_pickerTitle": "Select Report",
        "reportListPage_confirmDelete":
            "Are you sure you want to delete report %s? This cannot be undone.",
        "reportListPage_reportTitle": "Custom Reports",
        "reportListPage_reportAddNote":
            "To add a custom report, tap the %s icon.",
        "saveSpeciesPage_newTitle": "New Species",
        "saveSpeciesPage_editTitle": "Edit Species",
        "saveSpeciesPage_existsError": "Species already exists",
        "speciesListPage_menuTitle": "Species",
        "speciesListPage_title": "Species (%s)",
        "speciesListPage_pickerTitle": "Select Species",
        "speciesListPage_confirmDelete":
            "%s is associated with 0 catches; are you sure you want to delete it? This cannot be undone.",
        "speciesListPage_catchDeleteErrorSingular":
            "%s is associated with 1 catch and cannot be deleted.",
        "speciesListPage_catchDeleteErrorPlural":
            "%s is associated with %s catches and cannot be deleted.",
        "speciesListPage_searchHint": "Search species",
        "speciesListPage_emptyListTitle": "No species",
        "speciesListPage_emptyListDescription":
            "You haven't yet added any species. Tap the %s button to begin.",
        "fishingSpotPickerPage_title": "Select Fishing Spot",
        "fishingSpotPickerPage_hint":
            "Drag the map to use exact coordinates, or select an existing fishing spot.",
        "fishingSpotListPage_title": "Fishing Spots (%s)",
        "fishingSpotListPage_multiPickerTitle": "Select Fishing Spots",
        "fishingSpotListPage_singlePickerTitle": "Select Fishing Spot",
        "fishingSpotListPage_searchHint": "Search fishing spots",
        "fishingSpotListPage_emptyListTitle": "No fishing spots",
        "fishingSpotListPage_emptyListDescription":
            "To add a fishing spot, tap on the map and save the dropped pin.",
        "fishingSpotMap_locationPermissionTitle": "Location Access",
        "fishingSpotMap_locationPermissionDescription":
            "To show your current location, you must grant Anglers' Log access to read your device's location. To do so, open your device settings.",
        "fishingSpotMap_locationPermissionOpenSettings": "Open Settings",
        "feedbackPage_title": "Send Feedback",
        "feedbackPage_send": "Send",
        "feedbackPage_message": "Message",
        "feedbackPage_bugType": "Bug",
        "feedbackPage_suggestionType": "Suggestion",
        "feedbackPage_feedbackType": "Feedback",
        "feedbackPage_errorSending":
            "Error sending feedback. Please try again later, or email support@anglerslog.ca directly.",
        "feedbackPage_connectionError":
            "No internet connection. Please check your connection and try again.",
        "feedbackPage_sending": "Sending feedback...",
        "importPage_moreTitle": "Import",
        "importPage_title": "Import Data",
        "importPage_description":
            "Importing data you previously exported using Anglers' Log will added to your existing log data and may take several minutes.",
        "importPage_importingImages": "Copying images...",
        "importPage_importingData": "Copying fishing data...",
        "importPage_success": "Successfully imported data!",
        "importPage_error":
            "There was an error importing your data. If the backup file you chose was created using Anglers' Log, please send it to us for investigation.",
        "importPage_sendReport": "Send Report",
        "importPage_errorWarningMessage":
            "Pressing send will send Anglers' Log all your fishing data (excluding photos). Your data will not be shared outside the Anglers' Log organization.",
        "importPage_errorTitle": "Import Error",
        "dataImporter_chooseFile": "Choose File",
        "dataImporter_start": "Start",
        "migrationPage_title": "Data Migration",
        "migrationPage_description":
            "This is your first time opening Anglers' Log since updating to 2.0. Click the button below to start the data migration process.",
        "migrationPage_error":
            "There was an unexpected error while migrating your data to Anglers' Log 2.0. Please send us the error report and we will investigate as soon as possible. Note that none of your old data has been lost.",
        "migrationPage_loading": "Migrating data to Anglers' Log 2.0...",
        "migrationPage_success": "Successfully migrated data!",
        "migrationPage_feedbackTitle": "Migration Error",
        "angler_nameLabel": "Angler",
        "analysisDuration_allDates": "All dates",
        "analysisDuration_today": "Today",
        "analysisDuration_yesterday": "Yesterday",
        "analysisDuration_thisWeek": "This week",
        "analysisDuration_thisMonth": "This month",
        "analysisDuration_thisYear": "This year",
        "analysisDuration_lastWeek": "Last week",
        "analysisDuration_lastMonth": "Last month",
        "analysisDuration_lastYear": "Last year",
        "analysisDuration_last7Days": "Last 7 days",
        "analysisDuration_last14Days": "Last 14 days",
        "analysisDuration_last30Days": "Last 30 days",
        "analysisDuration_last60Days": "Last 60 days",
        "analysisDuration_last12Months": "Last 12 months",
        "analysisDuration_custom": "Custom",
        "daysFormat": "%sd",
        "hoursFormat": "%sh",
        "minutesFormat": "%sm",
        "secondsFormat": "%ss",
        "dateTimeFormat": "%s at %s",
        "dateDurationFormat": "%s (%s)",
        "onboardingJourney_welcomeTitle": "Welcome",
        "onboardingJourney_startDescription":
            "Welcome to Anglers' Log! Let's start by figuring out what kind of data you want to track.",
        "onboardingJourney_startButton": "Get Started",
        "onboardingJourney_skip": "No thanks, I'll learn as I go.",
        "onboardingJourney_catchFieldDescription":
            "When you log a catch, what do you want to know?",
        "onboardingJourney_manageFieldsTitle": "Manage Fields",
        "onboardingJourney_manageFieldsDescription":
            "Manage default fields, or add custom fields at any time when adding or editing a catch.",
        "onboardingJourney_manageFieldsSpecies": "Rainbow Trout",
        "onboardingJourney_locationAccessTitle": "Location Access",
        "onboardingJourney_locationAccessDescription":
            "To show your location on maps throughout Anglers' Log, device location access is required.",
        "onboardingJourney_locationAccessButton": "Set Permission",
        "onboardingJourney_howToFeedbackTitle": "Send Feedback",
        "onboardingJourney_howToFeedbackDescription":
            "Report a problem, suggest a feature, or send us feedback anytime. We'd love to hear from you!",
        "emptyListPlaceholder_noResultsTitle": "No results found",
        "emptyListPlaceholder_noResultsDescription":
            "Please adjust your search filter to find what you're looking for.",
        "loginPage_loginTitle": "Login",
        "loginPage_loginButtonText": "Login",
        "loginPage_loginQuestionText": "Don't have an account?",
        "loginPage_loginActionText": "Sign up.",
        "loginPage_signUpTitle": "Sign up",
        "loginPage_signUpButtonText": "Sign up",
        "loginPage_signUpQuestionText": "Already have an account?",
        "loginPage_signUpActionText": "Login.",
        "loginPage_passwordResetQuestion": "Forgot your password?",
        "loginPage_passwordResetAction": "Reset it.",
        "loginPage_errorUnknown": "Unknown error. Please try again later.",
        "loginPage_errorUnknownServer":
            "Unknown server error. Please try again later.",
        "loginPage_errorNoConnection":
            "Please connect to the internet and try again.",
        "loginPage_errorInvalidEmail":
            "The email address you entered is invalid.",
        "loginPage_errorUserDisabled":
            "The user associated with this email has been disabled.",
        "loginPage_errorUserNotFound":
            "An account with this email does not exist.",
        "loginPage_errorWrongPassword":
            "The password you entered is incorrect.",
        "loginPage_errorEmailInUse":
            "An account with this email already exists.",
        "loginPage_resetPasswordMessage":
            "Instructions on how to reset your password have been sent to %s",
        "proPage_upgradeTitle": "Upgrade to Anglers' Log",
        "proPage_proTitle": "Pro",
        "proPage_backup": "Automatically backup all your data to the cloud",
        "proPage_sync": "Sync data across all your devices",
        "proPage_reports": "Create custom reports and filters",
        "proPage_customFields": "Create custom input fields",
        "proPage_yearlyTitle": "%s/year",
        "proPage_yearlyTrial": "+%s days free",
        "proPage_yearlySubtext": "Billed annually",
        "proPage_monthlyTitle": "%s/month",
        "proPage_monthlyTrial": "+%s days free",
        "proPage_monthlySubtext": "Billed monthly",
        "proPage_fetchError":
            "Unable to fetch subscription options. Please ensure your device is connected to the internet and try again.",
        "proPage_upgradeSuccess":
            "Congratulations, you are an Anglers' Log Pro user!",
        "proPage_restoreQuestion": "Purchased Pro on another device?",
        "proPage_restoreAction": "Restore.",
        "proPage_restoreNoneFoundAppStore":
            "There were no previous purchases found. Please ensure you are signed in to the same Apple ID with which you made the original purchase.",
        "proPage_restoreNoneFoundGooglePlay":
            "There were no previous purchases found. Please ensure you are signed in to the same Google account with which you made the original purchase.",
        "proPage_restoreError":
            "Unexpected error occurred. Please ensure your device is connected to the internet and try again.",
        "period_dawn": "Dawn",
        "period_morning": "Morning",
        "period_midday": "Midday",
        "period_afternoon": "Afternoon",
        "period_dusk": "Dusk",
        "period_night": "Night",
        "period_pickerTitle": "Select Time Of Day",
        "period_pickerMultiTitle": "Select Times Of Day",
        "period_pickerAll": "All times of day",
      },
    };
