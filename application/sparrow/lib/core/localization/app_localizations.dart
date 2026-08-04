import 'package:flutter/material.dart';

import 'app_language.dart';

class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(AppLanguage.english);
  }

  static const _translations = <String, Map<AppLanguage, String>>{
    // Greetings & Headers
    'good_morning': {
      AppLanguage.english: 'Good Morning,',
      AppLanguage.hindi: 'शुभ प्रभात,',
    },
    'good_afternoon': {
      AppLanguage.english: 'Good Afternoon,',
      AppLanguage.hindi: 'शुभ दोपहर,',
    },
    'good_evening': {
      AppLanguage.english: 'Good Evening,',
      AppLanguage.hindi: 'शुभ संध्या,',
    },
    // Home screen sections
    'current_incident': {
      AppLanguage.english: 'CURRENT INCIDENT',
      AppLanguage.hindi: 'वर्तमान मामला',
    },
    'no_active_investigation': {
      AppLanguage.english: 'NO ACTIVE INVESTIGATION',
      AppLanguage.hindi: 'कोई सक्रिय जांच नहीं',
    },
    'ready_for_duty': {
      AppLanguage.english: 'Ready for Duty',
      AppLanguage.hindi: 'ड्यूटी के लिए तैयार',
    },
    'no_active_cases_desc': {
      AppLanguage.english:
          'You currently have no active cases assigned. Start a new investigation to log audio observations, statements, and timeline evidence.',
      AppLanguage.hindi:
          'वर्तमान में आपको कोई सक्रिय मामला आवंटित नहीं है। ऑडियो अवलोकन, बयान और टाइमलाइन साक्ष्य दर्ज करने के लिए एक नई जांच शुरू करें।',
    },
    'start_new_incident': {
      AppLanguage.english: 'Start New Incident',
      AppLanguage.hindi: 'नया मामला दर्ज करें',
    },
    'create_first_incident': {
      AppLanguage.english: 'Create First Incident',
      AppLanguage.hindi: 'पहला मामला दर्ज करें',
    },
    'started_at': {
      AppLanguage.english: 'Started At',
      AppLanguage.hindi: 'प्रारंभ समय',
    },
    'completed_at': {
      AppLanguage.english: 'Completed At',
      AppLanguage.hindi: 'पूर्ण होने का समय',
    },
    'started': {
      AppLanguage.english: 'Started',
      AppLanguage.hindi: 'प्रारंभ',
    },
    'completed': {
      AppLanguage.english: 'Completed',
      AppLanguage.hindi: 'पूर्ण',
    },
    'view_timeline': {
      AppLanguage.english: 'View Timeline',
      AppLanguage.hindi: 'टाइमलाइन देखें',
    },
    'quick_actions': {
      AppLanguage.english: 'Quick Actions',
      AppLanguage.hindi: 'त्वरित कार्रवाई',
    },
    'officer_observation': {
      AppLanguage.english: 'Officer\nObservation',
      AppLanguage.hindi: 'अधिकारी\nअवलोकन',
    },
    'victim_statement': {
      AppLanguage.english: 'Victim\nStatement',
      AppLanguage.hindi: 'पीड़ित का\nबयान',
    },
    'witness_statement': {
      AppLanguage.english: 'Witness\nStatement',
      AppLanguage.hindi: 'गवाह का\nबयान',
    },
    'suspect_statement': {
      AppLanguage.english: 'Suspect\nStatement',
      AppLanguage.hindi: 'संदिग्ध का\nबयान',
    },
    'recent_incidents': {
      AppLanguage.english: 'Recent Incidents',
      AppLanguage.hindi: 'हाल के मामले',
    },
    'no_cases_logged': {
      AppLanguage.english: 'No Cases Logged Yet',
      AppLanguage.hindi: 'अभी कोई मामला दर्ज नहीं है',
    },
    'no_cases_logged_desc': {
      AppLanguage.english:
          'Cases created by you or assigned to your station will appear here for fast access.',
      AppLanguage.hindi:
          'आपके द्वारा बनाए गए या आपके थाने को आवंटित मामले त्वरित पहुंच के लिए यहां दिखाई देंगे।',
    },

    // New Incident Screen
    'initial_incident_report': {
      AppLanguage.english: 'Initial Incident Report',
      AppLanguage.hindi: 'प्रारंभिक मामला रिपोर्ट',
    },
    'log_essential_details': {
      AppLanguage.english:
          'Log essential details to open an active investigation file.',
      AppLanguage.hindi:
          'सक्रिय जांच फ़ाइल खोलने के लिए आवश्यक विवरण दर्ज करें।',
    },
    'incident_title_type': {
      AppLanguage.english: 'Incident Title / Type *',
      AppLanguage.hindi: 'मामले का शीर्षक / प्रकार *',
    },
    'incident_title_hint': {
      AppLanguage.english: 'e.g. Stolen Pulsar 150 at Sector 62 Market',
      AppLanguage.hindi: 'जैसे: सेक्टर 62 मार्केट में पल्सर 150 चोरी',
    },
    'enter_incident_title': {
      AppLanguage.english: 'Please enter an incident title',
      AppLanguage.hindi: 'कृपया मामले का शीर्षक दर्ज करें',
    },
    'category_hint': {
      AppLanguage.english: 'Type or select category (e.g. Theft, Assault)',
      AppLanguage.hindi: 'श्रेणी दर्ज करें या चुनें (जैसे: चोरी, हमला)',
    },
    'enter_category': {
      AppLanguage.english: 'Please enter or select a category',
      AppLanguage.hindi: 'कृपया श्रेणी दर्ज करें या चुनें',
    },
    'enter_summary': {
      AppLanguage.english: 'Please enter initial summary or officer remarks',
      AppLanguage.hindi: 'कृपया प्रारंभिक सारांश या टिप्पणी दर्ज करें',
    },
    'enter_station': {
      AppLanguage.english: 'Please enter Police Station',
      AppLanguage.hindi: 'कृपया पुलिस स्टेशन दर्ज करें',
    },
    'enter_district': {
      AppLanguage.english: 'Please enter District',
      AppLanguage.hindi: 'कृपया जिला दर्ज करें',
    },
    'enter_state': {
      AppLanguage.english: 'Please enter State',
      AppLanguage.hindi: 'कृपया राज्य दर्ज करें',
    },
    'theft_crime': {
      AppLanguage.english: 'Theft',
      AppLanguage.hindi: 'चोरी',
    },
    'assault_crime': {
      AppLanguage.english: 'Assault',
      AppLanguage.hindi: 'हमला',
    },
    'vehicle_crime': {
      AppLanguage.english: 'Vehicle',
      AppLanguage.hindi: 'वाहन',
    },
    'cyber_crime': {
      AppLanguage.english: 'Cyber Crime',
      AppLanguage.hindi: 'साइबर अपराध',
    },
    'fraud_crime': {
      AppLanguage.english: 'Fraud',
      AppLanguage.hindi: 'धोखाधड़ी',
    },
    'general_crime': {
      AppLanguage.english: 'General',
      AppLanguage.hindi: 'सामान्य',
    },
    'location_hint': {
      AppLanguage.english: 'e.g. Sector 18, Noida',
      AppLanguage.hindi: 'जैसे: सेक्टर 18, नोएडा',
    },
    'enter_location': {
      AppLanguage.english: 'Please enter location',
      AppLanguage.hindi: 'कृपया स्थान दर्ज करें',
    },
    'initial_status': {
      AppLanguage.english: 'Initial Status',
      AppLanguage.hindi: 'प्रारंभिक स्थिति',
    },
    'active_investigation': {
      AppLanguage.english: 'Active Investigation',
      AppLanguage.hindi: 'सक्रिय जांच',
    },
    'save_as_draft': {
      AppLanguage.english: 'Save as Draft',
      AppLanguage.hindi: 'ड्राफ्ट के रूप में सहेजें',
    },
    'initial_parties': {
      AppLanguage.english: 'Initial Parties Involved',
      AppLanguage.hindi: 'शामिल प्रारंभिक पक्ष',
    },
    'brief_summary_remarks': {
      AppLanguage.english: 'Brief Summary / Officer Remarks',
      AppLanguage.hindi: 'संक्षिप्त सारांश / अधिकारी टिप्पणी',
    },
    'summary_field_hint': {
      AppLanguage.english:
          'Enter initial dispatch notes or preliminary observations...',
      AppLanguage.hindi: 'प्रारंभिक अवलोकन या नोट्स दर्ज करें...',
    },
    'create_and_open_file': {
      AppLanguage.english: 'Create & Open Incident File',
      AppLanguage.hindi: 'मामला फ़ाइल दर्ज करें और खोलें',
    },
    'incident_logged_success': {
      AppLanguage.english: 'Incident logged successfully!',
      AppLanguage.hindi: 'मामला सफलतापूर्वक दर्ज किया गया!',
    },

    // Filter Sheet
    'filter_and_sort': {
      AppLanguage.english: 'Filter & Sort Incidents',
      AppLanguage.hindi: 'फ़िल्टर और क्रमबद्ध करें',
    },
    'sort_order': {
      AppLanguage.english: 'Sort Order',
      AppLanguage.hindi: 'क्रमबद्ध करें',
    },
    'sort_by': {
      AppLanguage.english: 'Sort By',
      AppLanguage.hindi: 'क्रमबद्ध करें',
    },
    'sort_by_subtitle': {
      AppLanguage.english: 'Default order is Recent to Oldest',
      AppLanguage.hindi: 'डिफ़ॉल्ट क्रम नवीनतम से पुराना है',
    },
    'recent_to_oldest': {
      AppLanguage.english: 'Recent to Oldest',
      AppLanguage.hindi: 'नवीनतम से पुराना',
    },
    'oldest_to_recent': {
      AppLanguage.english: 'Oldest to Recent',
      AppLanguage.hindi: 'पुराने से नवीनतम',
    },
    'name_az': {
      AppLanguage.english: 'Name (A - Z)',
      AppLanguage.hindi: 'नाम (A - Z)',
    },
    'most_observations': {
      AppLanguage.english: 'Most Observations',
      AppLanguage.hindi: 'अधिकतम अवलोकन',
    },
    'incident_status': {
      AppLanguage.english: 'Incident Status',
      AppLanguage.hindi: 'मामले की स्थिति',
    },
    'all_statuses': {
      AppLanguage.english: 'All Statuses',
      AppLanguage.hindi: 'सभी स्थितियां',
    },
    'all_categories': {
      AppLanguage.english: 'All Categories',
      AppLanguage.hindi: 'सभी श्रेणियां',
    },
    'location_sector': {
      AppLanguage.english: 'Location / Sector',
      AppLanguage.hindi: 'स्थान / सेक्टर',
    },
    'all_locations': {
      AppLanguage.english: 'All Locations',
      AppLanguage.hindi: 'सभी स्थान',
    },
    'entity_requirements': {
      AppLanguage.english: 'Entity Requirements',
      AppLanguage.hindi: 'विशिष्ट आवश्यकताएं',
    },
    'has_suspects_only': {
      AppLanguage.english: 'Has Suspects Only',
      AppLanguage.hindi: 'केवल संदिग्ध शामिल हैं',
    },
    'has_suspects_subtitle': {
      AppLanguage.english: 'Show incidents with at least 1 suspect',
      AppLanguage.hindi: 'कम से कम 1 संदिग्ध वाले मामले दिखाएं',
    },
    'has_witnesses_only': {
      AppLanguage.english: 'Has Witnesses Only',
      AppLanguage.hindi: 'केवल गवाह शामिल हैं',
    },
    'has_witnesses_subtitle': {
      AppLanguage.english: 'Show incidents with recorded witnesses',
      AppLanguage.hindi: 'दर्ज गवाह वाले मामले दिखाएं',
    },
    'has_victims_only': {
      AppLanguage.english: 'Has Victims Only',
      AppLanguage.hindi: 'केवल पीड़ित शामिल हैं',
    },
    'has_victims_subtitle': {
      AppLanguage.english: 'Show incidents with recorded victims',
      AppLanguage.hindi: 'दर्ज पीड़ित वाले मामले दिखाएं',
    },
    'specific_filters': {
      AppLanguage.english: 'Specific Filters',
      AppLanguage.hindi: 'विशिष्ट फ़िल्टर',
    },
    'has_suspects': {
      AppLanguage.english: 'Has Suspects',
      AppLanguage.hindi: 'संदिग्ध शामिल हैं',
    },
    'has_victims': {
      AppLanguage.english: 'Has Victims',
      AppLanguage.hindi: 'पीड़ित शामिल हैं',
    },
    'has_witnesses': {
      AppLanguage.english: 'Has Witnesses',
      AppLanguage.hindi: 'गवाह शामिल हैं',
    },
    'apply_filters': {
      AppLanguage.english: 'Apply Filters',
      AppLanguage.hindi: 'फ़िल्टर लागू करें',
    },

    // Incidents Screen
    'case_records': {
      AppLanguage.english: 'Case Records',
      AppLanguage.hindi: 'मामले रिकॉर्ड',
    },
    'search_cases_hint': {
      AppLanguage.english: 'Search by case title or location...',
      AppLanguage.hindi: 'मामले का नाम या स्थान खोजें...',
    },
    'all_cases': {
      AppLanguage.english: 'All Cases',
      AppLanguage.hindi: 'सभी मामले',
    },
    'filter': {
      AppLanguage.english: 'Filter',
      AppLanguage.hindi: 'फ़िल्टर',
    },
    'reset_filters': {
      AppLanguage.english: 'Reset Filters',
      AppLanguage.hindi: 'फ़िल्टर रीसेट करें',
    },
    'no_matching_incidents': {
      AppLanguage.english: 'No Matching Incidents Found',
      AppLanguage.hindi: 'कोई मेल खाता मामला नहीं मिला',
    },
    // Timeline Screen
    'incident_details': {
      AppLanguage.english: 'Incident Details',
      AppLanguage.hindi: 'मामले का विवरण',
    },
    'edit': {
      AppLanguage.english: 'Edit',
      AppLanguage.hindi: 'संपादित करें',
    },
    'share': {
      AppLanguage.english: 'Share',
      AppLanguage.hindi: 'साझा करें',
    },
    'more': {
      AppLanguage.english: 'More',
      AppLanguage.hindi: 'अधिक',
    },
    'officer_observations': {
      AppLanguage.english: 'Officer Observations',
      AppLanguage.hindi: 'अधिकारी अवलोकन',
    },
    'observations': {
      AppLanguage.english: 'Observations',
      AppLanguage.hindi: 'अवलोकन',
    },

    'victims': {
      AppLanguage.english: 'Victims',
      AppLanguage.hindi: 'पीड़ित',
    },
    'witnesses': {
      AppLanguage.english: 'Witnesses',
      AppLanguage.hindi: 'गवाह',
    },
    'suspects': {
      AppLanguage.english: 'Suspects',
      AppLanguage.hindi: 'संदिग्ध',
    },
    'evidence': {
      AppLanguage.english: 'Evidence',
      AppLanguage.hindi: 'साक्ष्य',
    },
    'add_record': {
      AppLanguage.english: 'Add / Record',
      AppLanguage.hindi: 'जोड़ें / रिकॉर्ड करें',
    },
    'add_observation': {
      AppLanguage.english: 'Add\nObservation',
      AppLanguage.hindi: 'अवलोकन\nजोड़ें',
    },
    'add_victim_statement': {
      AppLanguage.english: 'Add Victim\nStatement',
      AppLanguage.hindi: 'पीड़ित बयान\nजोड़ें',
    },
    'add_witness_statement': {
      AppLanguage.english: 'Add Witness\nStatement',
      AppLanguage.hindi: 'गवाह बयान\nजोड़ें',
    },
    'add_suspect_statement': {
      AppLanguage.english: 'Add Suspect\nStatement',
      AppLanguage.hindi: 'संदिग्ध बयान\nजोड़ें',
    },
    'incident_information': {
      AppLanguage.english: 'Incident Information',
      AppLanguage.hindi: 'मामले की जानकारी',
    },
    'category': {
      AppLanguage.english: 'Category',
      AppLanguage.hindi: 'श्रेणी',
    },
    'weather': {
      AppLanguage.english: 'Weather',
      AppLanguage.hindi: 'मौसम',
    },
    'jurisdiction': {
      AppLanguage.english: 'Jurisdiction',
      AppLanguage.hindi: 'क्षेत्राधिकार',
    },
    'voice_input_lang': {
      AppLanguage.english: 'Voice Language',
      AppLanguage.hindi: 'वॉइस भाषा',
    },
    'edit_jurisdiction': {
      AppLanguage.english: 'Edit Jurisdiction',
      AppLanguage.hindi: 'क्षेत्राधिकार संपादित करें',
    },
    'save': {
      AppLanguage.english: 'Save',
      AppLanguage.hindi: 'सहेजें',
    },
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.hindi: 'रद्द करें',
    },
    'edit_incident_details': {
      AppLanguage.english: 'Edit Incident Details',
      AppLanguage.hindi: 'मामले का विवरण संपादित करें',
    },
    'incident_title': {
      AppLanguage.english: 'Incident Title',
      AppLanguage.hindi: 'मामले का शीर्षक',
    },
    'save_changes': {
      AppLanguage.english: 'Save Changes',
      AppLanguage.hindi: 'परिवर्तन सहेजें',
    },

    'delete_incident': {
      AppLanguage.english: 'Delete Incident',
      AppLanguage.hindi: 'मामला हटाएं',
    },
    'delete': {
      AppLanguage.english: 'Delete',
      AppLanguage.hindi: 'हटाएं',
    },
    'confirm_delete_msg': {
      AppLanguage.english: 'Are you sure you want to delete this incident? All associated statements, observations, evidence, and timeline records will be permanently removed.',
      AppLanguage.hindi: 'क्या आप वाकई इस मामले को हटाना चाहते हैं? सभी संबंधित बयान, अवलोकन, साक्ष्य और टाइमलाइन रिकॉर्ड स्थायी रूप से हटा दिए जाएंगे।',
    },
    'incident_updated': {
      AppLanguage.english: 'Incident details updated successfully!',
      AppLanguage.hindi: 'मामले के विवरण सफलतापूर्वक अपडेट किए गए!',
    },
    'incident_deleted': {
      AppLanguage.english: 'Incident deleted successfully.',
      AppLanguage.hindi: 'मामला सफलतापूर्वक हटा दिया गया।',
    },

    'auto_fetched': {
      AppLanguage.english: 'AUTO FETCHED',
      AppLanguage.hindi: 'ऑटो प्राप्त',
    },
    'police_station': {
      AppLanguage.english: 'Police Station',
      AppLanguage.hindi: 'पुलिस स्टेशन',
    },
    'district': {
      AppLanguage.english: 'District',
      AppLanguage.hindi: 'जिला',
    },
    'state': {
      AppLanguage.english: 'State',
      AppLanguage.hindi: 'राज्य',
    },
    'location': {
      AppLanguage.english: 'Location',
      AppLanguage.hindi: 'स्थान',
    },
    'gps_location': {
      AppLanguage.english: 'GPS Location',
      AppLanguage.hindi: 'जीपीएस स्थान',
    },
    'status': {
      AppLanguage.english: 'Status',
      AppLanguage.hindi: 'स्थिति',
    },
    'summary': {
      AppLanguage.english: 'Summary',
      AppLanguage.hindi: 'सारांश',
    },
    'show_more': {
      AppLanguage.english: 'Show More',
      AppLanguage.hindi: 'और दिखाएं',
    },
    'show_less': {
      AppLanguage.english: 'Show Less',
      AppLanguage.hindi: 'कम दिखाएं',
    },
    'view_map': {
      AppLanguage.english: 'View on Map',
      AppLanguage.hindi: 'मानचित्र देखें',
    },
    'people_involved': {
      AppLanguage.english: 'People Involved',
      AppLanguage.hindi: 'शामिल व्यक्ति',
    },
    'view_all': {
      AppLanguage.english: 'View All',
      AppLanguage.hindi: 'सभी देखें',
    },
    'evidence_and_media': {
      AppLanguage.english: 'Evidence & Media',
      AppLanguage.hindi: 'साक्ष्य और मीडिया',
    },
    'timeline_log': {
      AppLanguage.english: 'Timeline Log',
      AppLanguage.hindi: 'टाइमलाइन लॉग',
    },
    'expand': {
      AppLanguage.english: 'Expand',
      AppLanguage.hindi: 'विस्तार करें',
    },
    'collapse': {
      AppLanguage.english: 'Collapse',
      AppLanguage.hindi: 'छिपाएं',
    },
    'no_events_logged': {
      AppLanguage.english: 'No timeline events logged yet for this case.',
      AppLanguage.hindi: 'इस मामले के लिए अभी तक कोई टाइमलाइन घटना दर्ज नहीं की गई है।',
    },
    // Bottom Nav Bar
    'home': {
      AppLanguage.english: 'Home',
      AppLanguage.hindi: 'होम',
    },
    'incidents': {
      AppLanguage.english: 'Incidents',
      AppLanguage.hindi: 'मामले',
    },
    'new_incident': {
      AppLanguage.english: 'New Incident',
      AppLanguage.hindi: 'नया मामला',
    },
    'search': {
      AppLanguage.english: 'Search',
      AppLanguage.hindi: 'खोजें',
    },
    'profile': {
      AppLanguage.english: 'Profile',
      AppLanguage.hindi: 'प्रोफ़ाइल',
    },
    // Status Labels
    'investigation_active': {
      AppLanguage.english: 'INVESTIGATION ACTIVE',
      AppLanguage.hindi: 'जांच जारी है',
    },
    'active': {
      AppLanguage.english: 'ACTIVE',
      AppLanguage.hindi: 'सक्रिय',
    },
    'completed_status': {
      AppLanguage.english: 'COMPLETED',
      AppLanguage.hindi: 'पूर्ण',
    },
    'draft': {
      AppLanguage.english: 'DRAFT',
      AppLanguage.hindi: 'ड्राफ्ट',
    },
    // Common
    'coming_soon': {
      AppLanguage.english: 'Coming Soon',
      AppLanguage.hindi: 'शीघ्र उपलब्ध होगा',
    },
    'language_switched': {
      AppLanguage.english: 'Switched to English',
      AppLanguage.hindi: 'हिंदी भाषा में बदला गया',
    },
  };

  String text(String key) {
    final map = _translations[key];
    if (map == null) return key;
    return map[language] ?? map[AppLanguage.english] ?? key;
  }
}
