class EventSearchApiModel {
  SearchMetadata? _searchMetadata;

  SearchParameters? _searchParameters;

  SearchInformation? _searchInformation;

  List<EventsResults> _eventsResults = [];

  var eventsData;



  EventSearchApiModel.fromJson(json) {
    print(json);
    _searchMetadata = SearchMetadata(json['search_metadata']);
    _searchParameters = SearchParameters(json['search_parameters']);
    _searchInformation = SearchInformation(json['search_information']);
    eventsData = json["events_results"];
    List<EventsResults> temp = [];
    for (int i = 0; i < json["events_results"].length; i++) {
      EventsResults eventsData = EventsResults(json["events_results"][i]);
      temp.add(eventsData);
    }
    _eventsResults = temp;

  }

  EventSearchApiModel.withError(String s) {
    print(s);
  }

  get search_metadata => _searchMetadata;

  get search_parameters => _searchParameters;

  get search_information => _searchInformation;

  get events => _eventsResults;
}

class SearchParameters {
  var _q;
  var _engine;

  SearchParameters(json) {
    _q = json['q'];
    _engine = json['engine'];
  }

  get q => _q;

  get engine => _engine;
}

class SearchInformation {
  var _eventsResultsState;

  SearchInformation(json) {
    _eventsResultsState = json['events_results_state'];
  }

  get eventsResultsState => _eventsResultsState;
}

class SearchMetadata {
  var _id;
  var _status;
  var _jsonEndpoint;
  var _createdAt;
  var _processedAt;
  var _googleEventsUrl;
  var _rawHtmlFile;
  var _totalTimeTaken;

  SearchMetadata(json) {
    _id = json['id'];
    _status = json['status'];
    _jsonEndpoint = json['json_endpoint'];
    _createdAt = json['created_at'];
    _processedAt = json['processed_at'];
    _googleEventsUrl = json['google_events_url'];
    _rawHtmlFile = json['raw_html_file'];
    _totalTimeTaken = json['total_time_taken'];
  }

  get id => _id;

  get status => _status;

  get jsonEndpoint => _jsonEndpoint;

  get createdAt => _createdAt;

  get processedAt => _processedAt;

  get googleEventsUrl => _googleEventsUrl;

  get rawHtmlFile => _rawHtmlFile;

  get totalTimeTaken => _totalTimeTaken;
}

class EventsResults {
  var _title;
  late EventsDate _date;
  var _address;
  var _link;
  late EventLocationMap _eventLocationMap;
  var _description;
  var _ticketInfo;
  var _venue;
  var _thumbnail;

  EventsResults(json) {
    _title = json['title'];

    _date = EventsDate({"start_date":"24-11-2022","when":"Fri"});
    // _date = EventsDate(json['date']);
    _address = json['address'];
    _link = json['link'];
    if(json['event_location_map']!=null){
    _eventLocationMap = EventLocationMap(json['event_location_map']);
    }

    _description = json['description'];
    if (json['ticket_info'] != null) {
      _ticketInfo = [];
      json['ticket_info'].forEach((v) {
        _ticketInfo.add(TicketInfo(v));
      });
    }
    _venue = json['venue'];
    _thumbnail = json['thumbnail'];
  }

  get title => _title;

  EventsDate get date => _date;

  get address => _address;

  get link => _link;

  EventLocationMap get eventLocationMap => _eventLocationMap;

  get description => _description;

  get ticketInfo => _ticketInfo;

  get venue => _venue;

  get thumbnail => _thumbnail;
}

class EventLocationMap {
  var _image;
  var _link;
  var _serpapi_link;

  EventLocationMap(json) {
    _image = json['image'];
    _link = json['link'];
    _serpapi_link = json['serpapi_link'];
  }

  get image => _image;

  get link => _link;

  get serpapi_link => _serpapi_link;
}

class EventsDate {
  var _startDate;
  var _when;

  EventsDate(json) {
    _startDate = json['start_date'];
    _when = json['when'];
  }

  get startDate => _startDate;

  get when => _when;
}

class TicketInfo {
  var _source;
  var _link;
  var _linkType;

  TicketInfo(json) {
    _source = json['source'];
    _link = json['link'];
    _linkType = json['link_type'];
  }

  get source => _source;

  get link => _link;

  get linkType => _linkType;
}
