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
      AppLanguage.english: 'Add Officer\nObservation',
      AppLanguage.hindi: 'अधिकारी अवलोकन\nजोड़ें',
    },
    'victim_statement': {
      AppLanguage.english: 'Add Victim\nStatement',
      AppLanguage.hindi: 'पीड़ित का बयान\nजोड़ें',
    },
    'witness_statement': {
      AppLanguage.english: 'Add Witness\nStatement',
      AppLanguage.hindi: 'गवाह का बयान\nजोड़ें',
    },
    'suspect_statement': {
      AppLanguage.english: 'Add Suspect\nStatement',
      AppLanguage.hindi: 'संदिग्ध का बयान\nजोड़ें',
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
    'press_back_again_to_exit': {
      AppLanguage.english: 'Press back again to exit',
      AppLanguage.hindi: 'ऐप से बाहर निकलने के लिए फिर से वापस दबाएं',
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
    'report_generation': {
      AppLanguage.english: 'Report Gen',
      AppLanguage.hindi: 'रिपोर्ट निर्माण',
    },
    'report_generator': {
      AppLanguage.english: 'AI Report Generator',
      AppLanguage.hindi: 'एआई रिपोर्ट जनरेटर',
    },
    'generate_report': {
      AppLanguage.english: 'Generate AI Report',
      AppLanguage.hindi: 'एआई रिपोर्ट जनरेट करें',
    },
    'select_incident_file': {
      AppLanguage.english: 'Select Incident File',
      AppLanguage.hindi: 'मामला फ़ाइल चुनें',
    },
    'report_type': {
      AppLanguage.english: 'Report Type',
      AppLanguage.hindi: 'रिपोर्ट का प्रकार',
    },
    'ai_case_report_generator': {
      AppLanguage.english: 'AI Case Report Generator',
      AppLanguage.hindi: 'एआई केस रिपोर्ट जनरेटर',
    },
    'automated_case_summaries': {
      AppLanguage.english: 'Automated Case Summaries & Reports',
      AppLanguage.hindi: 'स्वचालित मामला सारांश और रिपोर्ट',
    },
    'select_completed_case_banner': {
      AppLanguage.english:
          'Select a completed case to view details, inspect raw JSON, and generate automated reports.',
      AppLanguage.hindi:
          'विवरण देखने, कच्चा JSON जांचने और स्वचालित रिपोर्ट उत्पन्न करने के लिए एक पूर्ण मामला चुनें।',
    },
    'step_select_completed_case': {
      AppLanguage.english: '1. Select Completed Case',
      AppLanguage.hindi: '1. पूर्ण मामला चुनें',
    },
    'select_completed_case_hint': {
      AppLanguage.english: 'Select a completed case',
      AppLanguage.hindi: 'एक पूर्ण मामला चुनें',
    },
    'step_select_report_language': {
      AppLanguage.english: '2. Select Report Language',
      AppLanguage.hindi: '2. रिपोर्ट की भाषा चुनें',
    },
    'view_case_details_json': {
      AppLanguage.english: 'View Case Details in JSON View',
      AppLanguage.hindi: 'JSON व्यू में मामले का विवरण देखें',
    },
    'generate_report_btn': {
      AppLanguage.english: 'Generate Report',
      AppLanguage.hindi: 'रिपोर्ट जनरेट करें',
    },
    'report_coming_soon': {
      AppLanguage.english: 'Report generation is coming soon!',
      AppLanguage.hindi: 'रिपोर्ट निर्माण सुविधा शीघ्र ही आ रही है!',
    },
    'incident_specific_db_json': {
      AppLanguage.english: 'Incident Specific Database JSON',
      AppLanguage.hindi: 'मामला विशिष्ट डेटाबेस JSON',
    },
    'copy_json': {
      AppLanguage.english: 'Copy JSON',
      AppLanguage.hindi: 'JSON कॉपी करें',
    },
    'json_copied_toast': {
      AppLanguage.english: 'Incident specific JSON copied to clipboard!',
      AppLanguage.hindi: 'मामला विशिष्ट JSON क्लिपबोर्ड पर कॉपी हो गया!',
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

    // Add Observation Sheet
    'add_observation_single': {
      AppLanguage.english: 'Add Observation',
      AppLanguage.hindi: 'अवलोकन जोड़ें',
    },
    'officer_remarks_transcript': {
      AppLanguage.english: 'Officer Remarks / Transcript *',
      AppLanguage.hindi: 'अधिकारी की टिप्पणी / प्रतिलेख *',
    },
    'enter_observation_hint': {
      AppLanguage.english: 'Enter observation transcript or tap microphone to dictate...',
      AppLanguage.hindi: 'अवलोकन विवरण दर्ज करें या बोलने के लिए माइक टैप करें...',
    },
    'evidence_attachments': {
      AppLanguage.english: 'Evidence Attachments',
      AppLanguage.hindi: 'साक्ष्य संलग्नक',
    },
    'add_evidence': {
      AppLanguage.english: 'Add Evidence',
      AppLanguage.hindi: 'साक्ष्य जोड़ें',
    },
    'no_evidence_attached': {
      AppLanguage.english: 'No evidence attached yet. Click "Add Evidence" to attach photos or video clips.',
      AppLanguage.hindi: 'अभी तक कोई साक्ष्य संलग्न नहीं है। फोटो या वीडियो जोड़ने के लिए "साक्ष्य जोड़ें" पर क्लिक करें।',
    },
    'select_evidence_type': {
      AppLanguage.english: 'Select Evidence Type',
      AppLanguage.hindi: 'साक्ष्य का प्रकार चुनें',
    },
    'capture_photo': {
      AppLanguage.english: 'Capture Photo',
      AppLanguage.hindi: 'फोटो खींचें',
    },
    'take_photo_camera': {
      AppLanguage.english: 'Take a photo using camera',
      AppLanguage.hindi: 'कैमरे से फोटो लें',
    },
    'record_video': {
      AppLanguage.english: 'Record Video',
      AppLanguage.hindi: 'वीडियो रिकॉर्ड करें',
    },
    'record_video_clip': {
      AppLanguage.english: 'Record a video clip',
      AppLanguage.hindi: 'एक वीडियो क्लिप रिकॉर्ड करें',
    },
    'click_picture': {
      AppLanguage.english: 'Click Picture',
      AppLanguage.hindi: 'फोटो खींचें',
    },
    'choose_from_device': {
      AppLanguage.english: 'Choose from device (picture, video, audio)',
      AppLanguage.hindi: 'डिवाइस से चुनें (चित्र, वीडियो, ऑडियो)',
    },
    'enter_observation_or_evidence': {
      AppLanguage.english: 'Please enter an observation transcript or add evidence.',
      AppLanguage.hindi: 'कृपया एक अवलोकन विवरण दर्ज करें या साक्ष्य जोड़ें।',
    },
    'observation_added': {
      AppLanguage.english: 'Observation added successfully!',
      AppLanguage.hindi: 'अवलोकन सफलतापूर्वक जोड़ा गया!',
    },
    'add_victim_btn': {
      AppLanguage.english: 'Add Victim',
      AppLanguage.hindi: 'पीड़ित जोड़ें',
    },
    'add_witness_btn': {
      AppLanguage.english: 'Add Witness',
      AppLanguage.hindi: 'गवाह जोड़ें',
    },
    'no_victims_recorded': {
      AppLanguage.english: 'No victims recorded',
      AppLanguage.hindi: 'कोई पीड़ित दर्ज नहीं है',
    },
    'no_witnesses_recorded': {
      AppLanguage.english: 'No witnesses recorded',
      AppLanguage.hindi: 'कोई गवाह दर्ज नहीं है',
    },
    'add_statement': {
      AppLanguage.english: 'Add Statement',
      AppLanguage.hindi: 'बयान दर्ज करें',
    },
    'statement_for': {
      AppLanguage.english: 'Add Statement for',
      AppLanguage.hindi: 'के लिए बयान दर्ज करें',
    },
    'name': {
      AppLanguage.english: 'Name',
      AppLanguage.hindi: 'नाम',
    },
    'age': {
      AppLanguage.english: 'Age',
      AppLanguage.hindi: 'आयु',
    },
    'gender': {
      AppLanguage.english: 'Gender',
      AppLanguage.hindi: 'लिंग',
    },
    'phone': {
      AppLanguage.english: 'Phone Number',
      AppLanguage.hindi: 'फ़ोन नंबर',
    },
    'address': {
      AppLanguage.english: 'Address',
      AppLanguage.hindi: 'पता',
    },
    'role': {
      AppLanguage.english: 'Role',
      AppLanguage.hindi: 'भूमिका',
    },
    'occupation': {
      AppLanguage.english: 'Occupation',
      AppLanguage.hindi: 'व्यवसाय',
    },
    'male': {
      AppLanguage.english: 'Male',
      AppLanguage.hindi: 'पुरुष',
    },
    'female': {
      AppLanguage.english: 'Female',
      AppLanguage.hindi: 'महिला',
    },
    'other_gender': {
      AppLanguage.english: 'Other',
      AppLanguage.hindi: 'अन्य',
    },
    'name_required': {
      AppLanguage.english: 'Name is required',
      AppLanguage.hindi: 'नाम आवश्यक है',
    },
    'age_required': {
      AppLanguage.english: 'Age is required',
      AppLanguage.hindi: 'आयु आवश्यक है',
    },
    'gender_required': {
      AppLanguage.english: 'Gender is required',
      AppLanguage.hindi: 'लिंग चुनना आवश्यक है',
    },
    'victim_added': {
      AppLanguage.english: 'Victim added successfully!',
      AppLanguage.hindi: 'पीड़ित सफलतापूर्वक जोड़ा गया!',
    },
    'witness_added': {
      AppLanguage.english: 'Witness added successfully!',
      AppLanguage.hindi: 'गवाह सफलतापूर्वक जोड़ा गया!',
    },
    'statement_added': {
      AppLanguage.english: 'Statement recorded successfully!',
      AppLanguage.hindi: 'बयान सफलतापूर्वक दर्ज किया गया!',
    },
    'add_suspect_btn': {
      AppLanguage.english: 'Add Suspect',
      AppLanguage.hindi: 'संदिग्ध जोड़ें',
    },
    'no_suspects_recorded': {
      AppLanguage.english: 'No suspects recorded',
      AppLanguage.hindi: 'कोई संदिग्ध दर्ज नहीं है',
    },
    'suspect_added': {
      AppLanguage.english: 'Suspect added successfully!',
      AppLanguage.hindi: 'संदिग्ध सफलतापूर्वक जोड़ा गया!',
    },
    'suspect_status': {
      AppLanguage.english: 'Status',
      AppLanguage.hindi: 'स्थिति',
    },
    'no_officer_observations_logged': {
      AppLanguage.english: 'No officer observations logged.',
      AppLanguage.hindi: 'कोई अधिकारी अवलोकन दर्ज नहीं किया गया।',
    },
    'person_name_hint': {
      AppLanguage.english: 'e.g. Arjun Mehta',
      AppLanguage.hindi: 'जैसे: अर्जुन मेहता',
    },
    'suspect_name_hint': {
      AppLanguage.english: 'e.g. Vikas Verma',
      AppLanguage.hindi: 'जैसे: विकास वर्मा',
    },
    'age_hint': {
      AppLanguage.english: 'e.g. 34',
      AppLanguage.hindi: 'जैसे: 34',
    },
    'phone_hint': {
      AppLanguage.english: '+91-9812345678',
      AppLanguage.hindi: '+91-9812345678',
    },
    'address_hint': {
      AppLanguage.english: 'e.g. A-204, Sector 62, Noida',
      AppLanguage.hindi: 'जैसे: ए-204, सेक्टर 62, नोएडा',
    },
    'witness_occupation_hint': {
      AppLanguage.english: 'e.g. Shop Owner',
      AppLanguage.hindi: 'जैसे: दुकान मालिक',
    },
    'victim_role_hint': {
      AppLanguage.english: 'e.g. Owner',
      AppLanguage.hindi: 'जैसे: मालिक',
    },
    'suspect_status_hint': {
      AppLanguage.english: 'e.g. Detained, At Large, Arrested',
      AppLanguage.hindi: 'जैसे: हिरासत में, फरार, गिरफ्तार',
    },
    'enter_statement_hint': {
      AppLanguage.english: 'Enter statement transcript or tap microphone to dictate...',
      AppLanguage.hindi: 'बयान ट्रांसक्रिप्ट दर्ज करें या बोलने के लिए माइक टैप करें...',
    },
    'yrs': {
      AppLanguage.english: 'Yrs',
      AppLanguage.hindi: 'वर्ष',
    },
    'valid_age': {
      AppLanguage.english: 'Valid age',
      AppLanguage.hindi: 'मान्य आयु दर्ज करें',
    },
    'edit_statement': {
      AppLanguage.english: 'Edit Statement',
      AppLanguage.hindi: 'बयान संपादित करें',
    },
    'edit_observation': {
      AppLanguage.english: 'Edit Observation',
      AppLanguage.hindi: 'अवलोकन संपादित करें',
    },
    'delete_statement': {
      AppLanguage.english: 'Delete Statement',
      AppLanguage.hindi: 'बयान हटाएं',
    },
    'delete_observation': {
      AppLanguage.english: 'Delete Observation',
      AppLanguage.hindi: 'अवलोकन हटाएं',
    },
    'delete_statement_confirm': {
      AppLanguage.english: 'Are you sure you want to delete this statement? This action cannot be undone.',
      AppLanguage.hindi: 'क्या आप निश्चित रूप से इस बयान को हटाना चाहते हैं? यह कार्रवाई पूर्ववत नहीं की जा सकती।',
    },
    'delete_observation_confirm': {
      AppLanguage.english: 'Are you sure you want to delete this observation? This action cannot be undone.',
      AppLanguage.hindi: 'क्या आप निश्चित रूप से इस अवलोकन को हटाना चाहते हैं? यह कार्रवाई पूर्ववत नहीं की जा सकती।',
    },
    'statement_updated': {
      AppLanguage.english: 'Statement updated successfully!',
      AppLanguage.hindi: 'बयान सफलतापूर्वक अद्यतन किया गया!',
    },
    'observation_updated': {
      AppLanguage.english: 'Observation updated successfully!',
      AppLanguage.hindi: 'अवलोकन सफलतापूर्वक अद्यतन किया गया!',
    },
    'statement_deleted': {
      AppLanguage.english: 'Statement deleted successfully!',
      AppLanguage.hindi: 'बयान सफलतापूर्वक हटा दिया गया!',
    },
    'observation_deleted': {
      AppLanguage.english: 'Observation deleted successfully!',
      AppLanguage.hindi: 'अवलोकन सफलतापूर्वक हटा दिया गया!',
    },
    'transcript_label': {
      AppLanguage.english: 'Transcript',
      AppLanguage.hindi: 'विवरण / ट्रांसक्रिप्ट',
    },
    'recorded_statements': {
      AppLanguage.english: 'Recorded Statements',
      AppLanguage.hindi: 'दर्ज किए गए बयान',
    },
    'no_recorded_statements': {
      AppLanguage.english: 'No recorded statements.',
      AppLanguage.hindi: 'कोई दर्ज बयान नहीं है।',
    },
    'prototype_notice': {
      AppLanguage.english:
          'NOTICE: THIS IS A PROTOTYPE APPLICATION INTENDED EXCLUSIVELY FOR TESTING AND EVALUATION PURPOSES.',
      AppLanguage.hindi:
          'सूचना: यह एक प्रोटोटाइप आवेदन है जो केवल परीक्षण और मूल्यांकन के उद्देश्यों के लिए है।',
    },
    'no_active_incident_action_error': {
      AppLanguage.english:
          'No active investigation found. Please start a new incident first.',
      AppLanguage.hindi:
          'कोई सक्रिय जांच नहीं मिली। कृपया पहले एक नया मामला दर्ज करें।',
    },

    // Officer Profile Setup & Edit Modal Translations
    'officer_identification': {
      AppLanguage.english: 'OFFICER IDENTIFICATION',
      AppLanguage.hindi: 'अधिकारी पहचान',
    },
    'setup_officer_profile': {
      AppLanguage.english: 'Setup Officer Profile',
      AppLanguage.hindi: 'अधिकारी प्रोफ़ाइल सेट करें',
    },
    'edit_officer_profile': {
      AppLanguage.english: 'Edit Officer Profile',
      AppLanguage.hindi: 'अधिकारी प्रोफ़ाइल संपादित करें',
    },
    'mandatory_profile_desc': {
      AppLanguage.english: 'Please complete all required fields to proceed into the application.',
      AppLanguage.hindi: 'आवेदन में आगे बढ़ने के लिए कृपया सभी आवश्यक फ़ील्ड भरें।',
    },
    'edit_profile_desc': {
      AppLanguage.english: 'Update your official profile details.',
      AppLanguage.hindi: 'अपनी आधिकारिक प्रोफ़ाइल जानकारी अद्यतन करें।',
    },
    'full_name_required': {
      AppLanguage.english: 'Full Name *',
      AppLanguage.hindi: 'पूरा नाम *',
    },
    'designation_required': {
      AppLanguage.english: 'Designation *',
      AppLanguage.hindi: 'पद / पदनाम *',
    },
    'police_station_required': {
      AppLanguage.english: 'Police Station *',
      AppLanguage.hindi: 'थाना / पुलिस स्टेशन *',
    },
    'district_required': {
      AppLanguage.english: 'District *',
      AppLanguage.hindi: 'ज़िला *',
    },
    'state_required': {
      AppLanguage.english: 'State *',
      AppLanguage.hindi: 'राज्य *',
    },
    'badge_number_required': {
      AppLanguage.english: 'Badge / Service Number *',
      AppLanguage.hindi: 'बैज / सेवा संख्या *',
    },
    'contact_phone_required': {
      AppLanguage.english: 'Contact Phone *',
      AppLanguage.hindi: 'संपर्क फोन *',
    },
    'save_and_continue': {
      AppLanguage.english: 'Save & Continue',
      AppLanguage.hindi: 'सहेजें और आगे बढ़ें',
    },
    'field_required_error': {
      AppLanguage.english: 'This field is required',
      AppLanguage.hindi: 'यह फ़ील्ड आवश्यक है',
    },
    'hint_full_name': {
      AppLanguage.english: 'e.g. Rahul Sharma',
      AppLanguage.hindi: 'जैसे: राहुल शर्मा',
    },
    'hint_designation': {
      AppLanguage.english: 'e.g. Sub Inspector',
      AppLanguage.hindi: 'जैसे: उप निरीक्षक (सब इंस्पेक्टर)',
    },
    'hint_police_station': {
      AppLanguage.english: 'e.g. Sector 18, Noida',
      AppLanguage.hindi: 'जैसे: सेक्टर 18, नोएडा',
    },
    'hint_district': {
      AppLanguage.english: 'e.g. Gautam Budh Nagar',
      AppLanguage.hindi: 'जैसे: गौतम बुद्ध नगर',
    },
    'hint_state': {
      AppLanguage.english: 'e.g. Uttar Pradesh',
      AppLanguage.hindi: 'जैसे: उत्तर प्रदेश',
    },
    'hint_badge_number': {
      AppLanguage.english: 'e.g. UP-GBN-8821',
      AppLanguage.hindi: 'जैसे: UP-GBN-8821',
    },
    'hint_phone': {
      AppLanguage.english: 'e.g. +91-9876543210',
      AppLanguage.hindi: 'जैसे: +91-9876543210',
    },
    'edit_victim_btn': {
      AppLanguage.english: 'Edit Victim',
      AppLanguage.hindi: 'पीड़ित के विवरण संपादित करें',
    },
    'edit_witness_btn': {
      AppLanguage.english: 'Edit Witness',
      AppLanguage.hindi: 'गवाह के विवरण संपादित करें',
    },
    'edit_suspect_btn': {
      AppLanguage.english: 'Edit Suspect',
      AppLanguage.hindi: 'संदिग्ध के विवरण संपादित करें',
    },
    'victim_updated': {
      AppLanguage.english: 'Victim details updated successfully!',
      AppLanguage.hindi: 'पीड़ित के विवरण सफलतापूर्वक अद्यतन किए गए!',
    },
    'witness_updated': {
      AppLanguage.english: 'Witness details updated successfully!',
      AppLanguage.hindi: 'गवाह के विवरण सफलतापूर्वक अद्यतन किए गए!',
    },
    'suspect_updated': {
      AppLanguage.english: 'Suspect details updated successfully!',
      AppLanguage.hindi: 'संदिग्ध के विवरण सफलतापूर्वक अद्यतन किए गए!',
    },
    'victim_added_title': {
      AppLanguage.english: 'New Victim Added',
      AppLanguage.hindi: 'नया पीड़ित जोड़ा गया',
    },
    'witness_added_title': {
      AppLanguage.english: 'New Witness Added',
      AppLanguage.hindi: 'नया गवाह जोड़ा गया',
    },
    'suspect_added_title': {
      AppLanguage.english: 'New Suspect Added',
      AppLanguage.hindi: 'नया संदिग्ध जोड़ा गया',
    },
    'victim_statement_title': {
      AppLanguage.english: 'Victim Statement',
      AppLanguage.hindi: 'पीड़ित का बयान',
    },
    'witness_statement_title': {
      AppLanguage.english: 'Witness Statement',
      AppLanguage.hindi: 'गवाह का बयान',
    },
    'suspect_statement_title': {
      AppLanguage.english: 'Suspect Statement',
      AppLanguage.hindi: 'संदिग्ध का बयान',
    },
  };


  String text(String key) {
    final map = _translations[key];
    if (map == null) return key;
    return map[language] ?? map[AppLanguage.english] ?? key;
  }
}
