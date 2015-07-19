
#console.log 'wtf'

tabUrl = ''

tabTitleObject = null

popupOpen = false

checkForUrlHourInterval = 16

checkForUrl_Persistent_ChromeNotification_HourInterval = 3 # (max of 5 notification items)

last_periodicCleanup = 0 # timestamp

CLEANUP_INTERVAL = 3 * 3600000 # three hours

queryThrottleSeconds = 3 # to respect the no-more-than 30/min stiplation for Reddit's api

serviceQueryTimestamps = {}

maxUrlResultsStoredInLocalStorage = 800 # they're deleted after they've expired anyway - so this likely won't be reached by user

kiwi_urlsResultsCache = {}  
  # < url >:
    # < serviceName >: {
    #   forUrl: url
    #   timestamp:
    #   service_PreppedResults: 
    #   urlBlocked:
    # }

kiwi_customSearchResults = {}  # stores temporarily so if they close popup, they'll still have results
      # maybe it won't clear until new result -- "see last search"
  
  # queryString
  # servicesSearchesRequested = responsePackage.servicesToSearch
  # servicesSearched
    # <serviceName>
      # results

kiwi_autoOffClearInterval = null

kiwi_reddit_token_refresh_interval = null
  # timestamp: 
  # intervalId: 
  

tempResponsesStore = {}
  # forUrl: < url >
  # results: 
    # < serviceName > :
    #   timestamp:
    #   service_PreppedResults:
    #   forUrl: url


randomishDeviceId = ->   # to be held in localStorage
  randomClientLength = getRandom(21,29)
  
  characterCounter = 0 
  
  randomString = ""
  
  while characterCounter <= randomClientLength
    characterCounter++
    
    randomASCIIcharcode = getRandom(33,125)
    #console.log randomASCIIcharcode
    randomString += String.fromCharCode(randomASCIIcharcode)
  
  return randomString
  

requestRedditOathToken = (kiwi_reddit_oauth) ->
  currentTime = Date.now()
  queryObj = 
    type: "POST"
    
      # data:'grant_type=https%3A%2F%2Foauth.reddit.com%2Fgrants%2Finstalled_client&device_id=MsZCo%5E)%3B%5D!M2y%2BbdTA2.po&'
      # // data: 'grant_type=' + encodeURIComponent('https://oauth.reddit.com/grants/installed_client') + '&device_id=' + encodeURIComponent('MsZCo^);]!M2y+bdTA2.po'), 
    data: {
        grant_type: "https://oauth.reddit.com/grants/installed_client"
        device_id: kiwi_reddit_oauth.device_id
      }
    
    url: 'https://www.reddit.com/api/v1/access_token'
    headers: { 
      'Authorization':    'Basic ' + btoa(kiwi_reddit_oauth.client_id + ":") # UjEwTnh2U1JPeVYwOVE6
      'Content-Type':     'application/x-www-form-urlencoded'
      'X-Requested-With': 'csrf suck it ' + getRandom(1,10000000)
    }
    cache: false
    async: true
    success: (data) ->
      #console.debug data
      # {access_token: "-i9YlrxIjXkl8HTXfdFgJ4eVp6RE", token_type: "bearer", expires_in: 3600, scope: "*"}
      if data.access_token? and data.expires_in? and data.token_type == "bearer"
        
        #console.log 'response from reddit!'
        
        token_lifespan_timestamp = currentTime + data.expires_in * 1000
        setObj = {}
        setObj['kiwi_reddit_oauth'] =
          token: data.access_token
          token_type: 'bearer'
          token_lifespan_timestamp: token_lifespan_timestamp
          client_id: kiwi_reddit_oauth.client_id
          device_id: kiwi_reddit_oauth.device_id
        
        chrome.storage.local.set(setObj, (data) ->
          
          setTimeout_forRedditRefresh(token_lifespan_timestamp, setObj.kiwi_reddit_oauth)
          
        )
        
    fail: (data) ->
      #console.log 'reddit failed to authenticate client, try again in 5 min'
      setTimeout( ->
        requestRedditOathToken(kiwi_reddit_oauth)
      , 1000 * 60 * 5
      )
      
  $.ajax( queryObj )
  

# authenticate with Reddit's OAUTH2, so we can be a good webizen
chrome.storage.local.get(null, (allItemsInLocalStorage) ->
  currentTime = Date.now()
  
  setObj = {}
  setObj['kiwi_reddit_oauth'] =
    token: null
    token_type: null
    token_lifespan_timestamp: null
    client_id: "R10NxvSROyV09Q"
    device_id: randomishDeviceId()
    
  
  if !allItemsInLocalStorage.kiwi_reddit_oauth? or !allItemsInLocalStorage.kiwi_reddit_oauth.token?
    
    #console.log "2 setObj['kiwi_reddit_oauth'] ="
    
    chrome.storage.local.set(setObj, (data) ->
      
      requestRedditOathToken(setObj.kiwi_reddit_oauth)
      
    )
    
  else if (allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp? and 
      currentTime > allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp) or
      !allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp?
    
    #console.log "3 setObj['kiwi_reddit_oauth'] ="
    
    requestRedditOathToken(setObj.kiwi_reddit_oauth)
    
  else if allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp? and allItemsInLocalStorage.kiwi_reddit_oauth?
    
    #console.log "4 setObj['kiwi_reddit_oauth'] ="
    
    token_timestamp = allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp
    
    if !kiwi_reddit_token_refresh_interval? or kiwi_reddit_token_refresh_interval.timestamp != token_timestamp
      
      setTimeout_forRedditRefresh(token_timestamp, allItemsInLocalStorage.kiwi_reddit_oauth)
      
)


setTimeout_forRedditRefresh = (token_timestamp, kiwi_reddit_oauth) ->
  currentTime = Date.now()
  if kiwi_reddit_token_refresh_interval? and kiwi_reddit_token_refresh_interval.timestamp?
    clearTimeout(kiwi_reddit_token_refresh_interval.intervalId)
  
  timeoutDelay = token_timestamp - currentTime
  
  timeoutIntervalId = setTimeout( -> 
      requestRedditOathToken(kiwi_reddit_oauth)
    , timeoutDelay )
  
  kiwi_reddit_token_refresh_interval =
    timestamp: token_timestamp
    intervalId: timeoutIntervalId


# go ahead and start to load search api for GNews
if google? 
  google.load('search', '1');


newsSearch = null

onGoogleLoad = ->
  newsSearch = new google.search.NewsSearch();
  newsSearch.setNoHtmlGeneration();

google.setOnLoadCallback(onGoogleLoad);

popupParcel = {}
# proactively set if each services' preppedResults are ready.
  # will be set with available results if queried by popup.
  # {
    # forUrl:
    # allPreppedResults:
    # kiwi_servicesInfo:
    # kiwi_alerts:
    # kiwi_userPreferences:
  # }

# tlds = [
#   '.com','.fr','.de','.co.uk',
#   '.net','.int','.edu','.gov','.mil','.co','.io',
#   '.au','.br','.cn','.dk','.es','.fi','.gb','.gr','.hk','.in','.it','.is','.jp','.ke','.no','.nl','.vn'
# ]

defaultUserPreferences = {
  
  fontSize: .8
  researchModeOnOff: 'on'
  autoOffAtUTCmilliTimestamp: null
  autoOffTimerType: 'always' # 'custom','always','20','60'
  autoOffTimerValue: null
  
  sortByPref: 'attention' # 'recency'   # "attention" means 'comments' if story, 'points' if comment, 'clusterUrl' if news
  
    # suggested values to all users
  urlSubstring_blacklists: 
    anyMatch: [
      'facebook.com'
      
      'news.ycombinator.com'
      'reddit.com'
      
      'imgur.com'
      
      'www.google.com'
      'docs.google'
      'drive.google'
      'accounts.google'
      '.slack.com/'
      '//t.co'
      '//bit.ly'
      '//goo.gl'
      '//mail.google'
      '//mail.yahoo.com'
      'hotmail.com'
      'outlook.com'
      
      'chrome://'
      'chrome-extension://'
      
      'chrome-devtools://'  # hardcoded block
    ]
    endingIn: [
      #future - ending in:
      'youtube.com' # /
    ]
    unless: [
      #unless 
      ['twitter.com/','/status/'] # unless /status/
    # ,
    #   'twitter.com'
    ] 
  
}

is_url_blocked = (blockedLists, url) ->
  if blockedLists.anyMatch?
    for urlSubstring in blockedLists.anyMatch
      if url.indexOf(urlSubstring) != -1
        return true
        
  if blockedLists.endingIn?
    for urlSubstring in blockedLists.endingIn
      if url.indexOf(urlSubstring) == url.length - urlSubstring.length
        return true
        
      urlSubstring += '/'
      if url.indexOf(urlSubstring) == url.length - urlSubstring.length
        return true
    
  if blockedLists.unless?
    for urlSubstringArray in blockedLists.unless
      if url.indexOf(urlSubstringArray[0]) != -1
        
        if url.indexOf(urlSubstringArray[1]) == -1
          return true
  
  return false
    
defaultServicesInfo = [
    
    name:"hackerNews"
    title: "Hacker News"
    abbreviation: "H"
    
    queryApi:"https://hn.algolia.com/api/v1/search?restrictSearchableAttributes=url&query="
    broughtToYouByTitle:"Algolia Hacker News API"
    broughtToYouByURL:"https://hn.algolia.com/api"
    
    permalinkBase: 'https://news.ycombinator.com/item?id='
    userPageBaselink: 'https://news.ycombinator.com/user?id='
    
    submitTitle: 'Be the first to submit on Hacker News!'
    submitUrl: 'https://news.ycombinator.com/submit'
    
    active: 'on'
    
    
    notableConditions:
      hoursSincePosted: 4 # an exact match is less than 5 hours old
      num_comments: 10  # an exact match has 10 comments
    
    updateBadgeOnlyWithExactMatch: true
    
    customSearchApi: "https://hn.algolia.com/api/v1/search?query="
    customSearchTags__convention: {'string':'&tags=','delimeter':','}
    customSearchTags:
      story:
        title: "stories"
        string: "story"
        include: true
      commentPolls:
        title: "comments or polls"
        string:"(comment,poll,pollopt)"
        include: false
      showHnAskHn:
        title: "Show HN or Ask HN"
        string:"(show_hn,ask_hn)"
        include: false
        
      
    # customSearch
    # queryApi  https://hn.algolia.com/api/v1/search?query=
      # tags= filter on a specific tag. Available tags:
      # story
      # comment
      # poll
      # pollopt
      # show_hn
      # ask_hn
      # front_page
      # author_:USERNAME
      # story_:ID
      
      # author_pg,(story,poll)   filters on author=pg AND (type=story OR type=poll).
  ,
  
    name:"reddit"
    title: "Reddit"
    abbreviation: "R"
    
    queryApi:"https://www.reddit.com/submit.json?url="
    
    broughtToYouByTitle:"Reddit API"
    
    broughtToYouByURL:"https://github.com/reddit/reddit/wiki/API"
    
    permalinkBase: 'https://www.reddit.com'
    
    userPageBaselink: 'https://www.reddit.com/user/'
    
    submitTitle: 'Be the first to submit on Reddit!'
    submitUrl: 'https://www.reddit.com/submit'
    
    active: 'on'
    
    notableConditions:
      hoursSincePosted: 1 # an exact match is less than 5 hours old
      num_comments: 30   # an exact match has 30 comments
    
    updateBadgeOnlyWithExactMatch: true
    
    customSearchApi: "https://www.reddit.com/search.json?q="
    
    customSearchTags: {}
    
  ,
    
    name:"gnews"
    title: "Google News"
    abbreviation: "G"
    
    broughtToYouByTitle:"Google News Search"
    
    broughtToYouByURL:"https://developers.google.com/news-search/v1/devguide"
    
    permalinkBase: ''
    userPageBaselink: ''
    
    active: 'on'
    
    
    submitTitle: null
    submitUrl: null
      
    notableConditions:
      numberOfRelatedItemsWithClusterURL: 2 # (or more)
      
      numberOfStoriesFoundWithinTheHoursSincePostedLimit: 4 # (or more)
    
      hoursSincePosted: 3
    customSearchTags: {} 
    
  # {
  #   <voat, lobste.rs, metafilter, layervault -- get on this! ping me @spencenow if an API surfaces>  :D
  # },
  
]

# lastQueryTimestamp # to throttle




returnNumberOfActiveServices = (servicesInfo) ->
  
  numberOfActiveServices = 0
  for service in servicesInfo
    if service.active == 'on'
      numberOfActiveServices++
  return numberOfActiveServices

sendParcel = (parcel) ->
  outPort = chrome.extension.connect({name: "kiwi_fromBackgroundToPopup"})
  
  if !parcel.msg? or !parcel.forUrl?
    return false
  
  switch parcel.msg
    when 'kiwiPP_popupParcel_ready'
      
      # refreshBadge(parcel.popupParcel)
      
      outPort.postMessage(parcel)
      
    # when 'kiwi_alertAddResponse' -> new popup parcel ^^
    # 'kiwi_userPreferencesResponse' -> again, new popup parcel, with viewPreference
    
    
_save_a_la_carte = (parcel) ->
  
  setObj = {}
  setObj[parcel.keyName] = parcel.newValue
  
  chrome.storage[parcel.localOrSync].set(setObj, (data) ->
    if parcel.refreshView?
      _set_popupParcel(tempResponsesStore.services, tabUrl, true, parcel.refreshView)
    else
      _set_popupParcel(tempResponsesStore.services, tabUrl, false)
  )


chrome.extension.onConnect.addListener((port) ->
  
  if port.name is 'kiwi_fromBackgroundToPopup'
    popupOpen = true
    
    port.onMessage.addListener( (dataFromPopup) ->
      
      if !dataFromPopup.msg?
        return false
      
      switch dataFromPopup.msg
        
        when 'kiwiPP_post_customSearch'
          #console.log 'when kiwiPP_post_customSearch1'
          #console.debug dataFromPopup
          # dataFromPopup.servicesToSearch
          
          if dataFromPopup.customSearchRequest? and dataFromPopup.customSearchRequest.queryString? and
              dataFromPopup.customSearchRequest.queryString != ''
            
            # if kiwi_customSearchResults? and kiwi_customSearchResults.queryString? and
            #     kiwi_customSearchResults.queryString == dataFromPopup.customSearchRequest.queryString
            #   return 0
            #console.log 'when kiwiPP_post_customSearch2'
            
            chrome.storage.sync.get(null, (allItemsInSyncedStorage) -> 
              
              if allItemsInSyncedStorage['kiwi_servicesInfo']?
                # #console.log 'when kiwiPP_post_customSearch3'
                for serviceInfoObject in allItemsInSyncedStorage['kiwi_servicesInfo']
                  
                  #console.log 'when kiwiPP_post_customSearch4 for ' + serviceInfoObject.name
                  if dataFromPopup.customSearchRequest.servicesToSearch[serviceInfoObject.name]?
                    
                    if serviceInfoObject.name is 'gnews'
                      dispatchGnewsQuery__customSearch(dataFromPopup.customSearchRequest.queryString, dataFromPopup.customSearchRequest.servicesToSearch, serviceInfoObject, allItemsInSyncedStorage['kiwi_servicesInfo'])
                    else if serviceInfoObject.customSearchApi? and serviceInfoObject.customSearchApi != ''
                      dispatchQuery__customSearch(dataFromPopup.customSearchRequest.queryString, dataFromPopup.customSearchRequest.servicesToSearch, serviceInfoObject, allItemsInSyncedStorage['kiwi_servicesInfo'])
                    
            )
            
            
              
          
        when 'kiwiPP_researchUrlOverrideButton'
          # #console.log "when 'kiwiPP_researchUrlOverrideButton'"
          initIfNewURL(true,true)
          
        when 'kiwiPP_clearAllURLresults'
          # #console.log "when 'kiwiPP_clearAllURLresults'"
          updateBadgeText('')
          kiwi_urlsResultsCache = {}
          tempResponsesStore = {}
          _set_popupParcel({}, tabUrl, true)
          
          
        
        when 'kiwiPP_refreshSearchQuery'
          kiwi_customSearchResults = {}
          
          if tempResponsesStore.forUrl == tabUrl
            
            _set_popupParcel(tempResponsesStore.services, tabUrl, true)
          
          else if kiwi_urlsResultsCache[tabUrl]?
            
            _set_popupParcel(kiwi_urlsResultsCache[tabUrl], tabUrl, true)
            
          else
            _set_popupParcel({}, tabUrl, true)
          
        when 'kiwiPP_refreshURLresults'
          if kiwi_urlsResultsCache? and kiwi_urlsResultsCache[tabUrl]?
            delete kiwi_urlsResultsCache[tabUrl]
            
          tempResponsesStore = {}
          initIfNewURL(true)
          
        when 'kiwiPP_reset_timer'
          
          dataFromPopup.kiwi_userPreferences['autoOffAtUTCmilliTimestamp'] = setAutoOffTimer(true,
              dataFromPopup.kiwi_userPreferences.autoOffAtUTCmilliTimestamp, 
              dataFromPopup.kiwi_userPreferences.autoOffTimerValue,
              dataFromPopup.kiwi_userPreferences.autoOffTimerType,
              dataFromPopup.kiwi_userPreferences.researchModeOnOff
            )
          
          parcel =
            refreshView: 'userPreferences'
            keyName: 'kiwi_userPreferences'
            newValue: dataFromPopup.kiwi_userPreferences
            localOrSync: 'sync'
          
          _save_a_la_carte(parcel)
          
        when 'kiwiPP_post_save_a_la_carte'
          _save_a_la_carte(dataFromPopup)    
        
        when 'kiwiPP_post_savePopupParcel'
          #console.log "when 'kiwiPP_post_savePopupParcel'"
          
          
          _save_from_popupParcel(dataFromPopup.newPopupParcel, dataFromPopup.forUrl, dataFromPopup.refreshView)
          
          if kiwi_urlsResultsCache[tabUrl]?
            
            refreshBadge(dataFromPopup.newPopupParcel.kiwi_servicesInfo, kiwi_urlsResultsCache[tabUrl])
          
          
        when 'kiwiPP_request_popupParcel'
          
          #console.log " when 'kiwiPP_request_popupParcel' "
          #console.log 'dataFromPopup.forUrl' + dataFromPopup.forUrl
          #console.log 'tabUrl:' + tabUrl
          
          if dataFromPopup.forUrl is tabUrl
            # #console.log popupParcel.forUrl
            # #console.log tabUrl
            
            preppedResponsesInPopupParcel = 0
            if popupParcel? and popupParcel.allPreppedResults? 
              #console.log 'popupParcel.allPreppedResults? '
              #console.debug popupParcel.allPreppedResults
              
              for serviceName, service of popupParcel.allPreppedResults
                if service.service_PreppedResults?
                  preppedResponsesInPopupParcel += service.service_PreppedResults.length
            
            preppedResponsesInTempResponsesStore = 0
            if tempResponsesStore? and tempResponsesStore.services? 
              #console.log 'tempResponsesStore.services? '
              #console.debug tempResponsesStore.services
              for serviceName, service of tempResponsesStore.services
                preppedResponsesInTempResponsesStore += service.service_PreppedResults.length
            
            newResultsBool = false
            
            if tempResponsesStore.forUrl == tabUrl and preppedResponsesInTempResponsesStore != preppedResponsesInPopupParcel
              newResultsBool = true
            
            if popupParcel? and popupParcel.forUrl is tabUrl and newResultsBool == false
              #console.log "popup parcel ready"
              
              parcel = {}
          
              parcel.msg = 'kiwiPP_popupParcel_ready'
              parcel.forUrl = tabUrl
              parcel.popupParcel = popupParcel
              
              sendParcel(parcel)
            else
              # #console.log 'parcel is Not ready for tabUrl, must be set' + tabUrl
              
              #console.log "popup parcel not ready"
              
              if !tempResponsesStore.services? or tempResponsesStore.forUrl != tabUrl
                _set_popupParcel({}, tabUrl, true)
              else
                _set_popupParcel(tempResponsesStore.services, tabUrl, true)
          
    )
)



initialize = (currentUrl) ->
  #console.log 'yolo 1 ' + currentUrl
  
   # to prevent repeated api requests - we check to see if we have an up-to-date version in local storage
  chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
    
    if !allItemsInSyncedStorage['kiwi_servicesInfo']?
        # we set the defaults in localStorage if servicesInfo doesn't exist in localStorage 
      chrome.storage.sync.set({'kiwi_servicesInfo': defaultServicesInfo}, (servicesInfo) ->
        getUrlResults_to_refreshBadgeIcon(defaultServicesInfo, currentUrl)
      )
      
    else
      getUrlResults_to_refreshBadgeIcon(allItemsInSyncedStorage['kiwi_servicesInfo'], currentUrl)
  )
  
getUrlResults_to_refreshBadgeIcon = (servicesInfo, currentUrl) ->
  
  #console.log 'yolo 2  getUrlResults_to_refreshBadgeIcon'
  
  currentTime = Date.now()
  
  if Object.keys(kiwi_urlsResultsCache).length > 0
    
    if kiwi_urlsResultsCache[currentUrl]?
      
      # start off by instantly updating UI with what we know
      refreshBadge(servicesInfo, kiwi_urlsResultsCache[currentUrl])
      
      for service in servicesInfo
        if kiwi_urlsResultsCache[currentUrl][service.name]?
          
          if (currentTime - kiwi_urlsResultsCache[currentUrl][service.name].timestamp) > checkForUrlHourInterval * 3600000
            
            check_updateServiceResults(servicesInfo, currentUrl, kiwi_urlsResultsCache)  
            return 0
          
        else
          check_updateServiceResults(servicesInfo, currentUrl, kiwi_urlsResultsCache)  
          return 0
      
      # for urls that are being visited a second time, 
      # all recent results present kiwi_urlsResultsCache (for all services)
      # we set tempResponsesStore before setting popupParcel
      
      tempResponsesStore.forUrl = currentUrl
      tempResponsesStore.services = kiwi_urlsResultsCache[currentUrl]
      
      if popupOpen
        sendPopupParcel = true
      else
        sendPopupParcel = false
      #console.log '#console.debug tempResponsesStore.services'
      #console.debug tempResponsesStore.services
      _set_popupParcel(tempResponsesStore.services, currentUrl, sendPopupParcel)
      
          
    else
      # this url has not been checked
      #console.log '# this url has not been checked'
      check_updateServiceResults(servicesInfo, currentUrl, kiwi_urlsResultsCache)
        
  else
    
    #console.log '# no urls have been checked'
    check_updateServiceResults(servicesInfo, currentUrl, null)


_save_customSearch_results = (servicesInfo, tempResponsesStore, _urlsResultsCache) ->
  #console.log 'yolo 3'
  
  
  urlsResultsCache = _.extend {}, _urlsResultsCache
  previousUrl = tempResponsesStore.forUrl
  
  if urlsResultsCache[previousUrl]? 
    
      # these will always be at least as recent as what's in the store. 
    for service in servicesInfo
      
      if tempResponsesStore.services[service.name]?
        
        urlsResultsCache[previousUrl][service.name] =
          forUrl: previousUrl
          timestamp: tempResponsesStore.services[service.name].timestamp
          service_PreppedResults: tempResponsesStore.services[service.name].service_PreppedResults
       
      
  else
    urlsResultsCache[previousUrl] = {}
    urlsResultsCache[previousUrl] = tempResponsesStore.services
    
  return urlsResultsCache

_save_url_results = (servicesInfo, tempResponsesStore, _urlsResultsCache) ->
  #console.log 'yolo 3'
  
  urlsResultsCache = _.extend {}, _urlsResultsCache
  previousUrl = tempResponsesStore.forUrl
  
  if urlsResultsCache[previousUrl]? 
    
      # these will always be at least as recent as what's in the store. 
    for service in servicesInfo
      
      if tempResponsesStore.services[service.name]?
        
        urlsResultsCache[previousUrl][service.name] =
          forUrl: previousUrl
          timestamp: tempResponsesStore.services[service.name].timestamp
          service_PreppedResults: tempResponsesStore.services[service.name].service_PreppedResults
    
      
  else
    urlsResultsCache[previousUrl] = {}
    urlsResultsCache[previousUrl] = tempResponsesStore.services
    
  return urlsResultsCache
  


__randomishStringPadding = ->
  randomPaddingLength = getRandom(2,4)
      
  characterCounter = 0 
  
  paddingString = ""
  
  while characterCounter <= randomPaddingLength
    
    randomLatinKeycode = getRandom(33,265)
    String.fromCharCode(randomLatinKeycode)
    
    paddingString += String.fromCharCode(randomLatinKeycode)
    characterCounter++
  
  return paddingString

_save_historyBlob = (kiwi_urlsResultsCache, tabUrl) ->
  
  tabUrl_hashWordArray = CryptoJS.SHA512(tabUrl)
  tabUrl_hash = tabUrl_hashWordArray.toString(CryptoJS.enc.Latin1)
  
  chrome.storage.local.get(null, (allItemsInLocalStorage) ->  
    
    historyString = reduceHashByHalf(tabUrl_hash)
    paddedHistoryString = __randomishStringPadding() + historyString
    
    
    if allItemsInLocalStorage.kiwi_historyBlob? and typeof allItemsInLocalStorage.kiwi_historyBlob == 'string' and
        allItemsInLocalStorage.kiwi_historyBlob.indexOf(historyString) < 15000 and allItemsInLocalStorage.kiwi_historyBlob.indexOf(historyString) != -1
      
      
      
      #console.log '# already exists in history blob ' + allItemsInLocalStorage.kiwi_historyBlob.indexOf(historyString)
      
      return 0
      
    else
    
      if !allItemsInLocalStorage.kiwi_historyBlob?
          # if it doesn't exist, then we need end padding
        paddedHistoryString = paddedHistoryString + __randomishStringPadding()
        
        # in periodic cleanup - if in last 1000, snip and add to front
        
      if allItemsInLocalStorage['kiwi_historyBlob']?
        newKiwi_historyBlob = paddedHistoryString + allItemsInLocalStorage['kiwi_historyBlob']
      else
        newKiwi_historyBlob = paddedHistoryString
    
    
    
      # we cap the size of the history blob at 17000 characters
    if allItemsInLocalStorage.kiwi_historyBlob? and  allItemsInLocalStorage.kiwi_historyBlob.indexOf(historyString) > 17000
      newKiwi_historyBlob = newKiwi_historyBlob.substring(0,15500)
    
    
    
    chrome.storage.local.set({'kiwi_historyBlob': newKiwi_historyBlob}, ->
        #console.log 'successfully set for ' + tabUrl
        #console.log 'successfully set for ' + tabUrl_hash
        #console.log 'paddedHistoryString ' + paddedHistoryString
      )
  )
      

check_updateServiceResults = (servicesInfo, currentUrl, urlsResultsCache = null) ->
  #console.log 'yolo 4'
  # if any results from previous tab have not been set, set them.
  if urlsResultsCache? and Object.keys(tempResponsesStore).length > 0
    previousResponsesStore = _.extend {}, tempResponsesStore
    _urlsResultsCache = _.extend {}, urlsResultsCache
    
    kiwi_urlsResultsCache = _save_url_results(servicesInfo, previousResponsesStore, _urlsResultsCache)
    
    _save_historyBlob(kiwi_urlsResultsCache, previousResponsesStore.forUrl)
    
  # refresh tempResponsesStore for new url
  tempResponsesStore.forUrl = currentUrl
  tempResponsesStore.services = {}
  
  currentTime = Date.now()
  
  if !urlsResultsCache?
    urlsResultsCache = {}
  if !urlsResultsCache[currentUrl]?
    urlsResultsCache[currentUrl] = {}
  
  # #console.log 'about to check for dispatch query'
  # #console.debug urlsResultsCache[currentUrl]
  
  # check on a service-by-service basis (so we don't requery all services just b/c one api/service is down)
  for service in servicesInfo
    # #console.log 'for service in servicesInfo'
    # #console.debug service
    
    if service.active == 'on'
      if urlsResultsCache[currentUrl][service.name]?
        if (currentTime - urlsResultsCache[currentUrl][service.name].timestamp) > checkForUrlHourInterval * 3600000
          if service.name == "gnews" # because, gnews HAS to be different. good lord
            dispatchGnewsQuery(service, currentUrl, servicesInfo)
          else
            dispatchQuery(service, currentUrl, servicesInfo)
      else
        if service.name == "gnews" # because, gnews HAS to be different. good lord
          dispatchGnewsQuery(service, currentUrl, servicesInfo)
        else
          dispatchQuery(service, currentUrl, servicesInfo)

dispatchGnewsQuery = (service_info, currentUrl, servicesInfo) ->
  #console.log 'yolo 5 ~ - gnews '
  #console.debug service_info
  
  currentTime = Date.now()
  
  if newsSearch? and tabTitleObject? and tabTitleObject.forUrl == currentUrl and 
      tabTitleObject.tabTitle != null and tabTitleObject.tabTitle != ""
      # because we depend on externally loaded libraries 
      # the extension will *ignore* gnews if its deprecated loader api is slow (or down) for the day
      # please google, allow your search api to be downloaded a la carte. either way - thanks! :)
  
    # self imposed rate limiting per api
    if !serviceQueryTimestamps[service_info.name]?
      serviceQueryTimestamps[service_info.name] = currentTime
    else
      if (currentTime - serviceQueryTimestamps[service_info.name]) < queryThrottleSeconds * 1000
        #wait a couple seconds before querying service
        #console.log 'too soon on dispatch, waiting a couple seconds'
        setTimeout(->
            if currentUrl == tabUrl # if they've tabbed away, don't bother
                # (although this check exists within dispatchGnewsQuery as well)
              dispatchGnewsQuery(service_info, currentUrl, servicesInfo) 
          , 2000
        )
        return 0
      else
        serviceQueryTimestamps[service_info.name] = currentTime
    
    
    # // Set searchComplete as the callback function when a search is 
    # // complete.  The newsSearch object will have results in it.
    newsSearch.setSearchCompleteCallback( @,  () ->
      
      if _.isArray(newsSearch.results)
        results = newsSearch.results
      else
        results = []
      
      responsePackage =
        forUrl: currentUrl
        servicesInfo: servicesInfo
        serviceName: service_info.name
        queryResult: results
      setPreppedServiceResults(responsePackage, servicesInfo)
       
    )
    newsSearch.execute(tabTitleObject.tabTitle);

dispatchQuery = (service_info, currentUrl, servicesInfo) ->
  #console.log 'yolo 5 ~ for ' + service_info.name
  
  currentTime = Date.now()
  
  # self imposed rate limiting per api
  if !serviceQueryTimestamps[service_info.name]?
    serviceQueryTimestamps[service_info.name] = currentTime
  else
    if (currentTime - serviceQueryTimestamps[service_info.name]) < queryThrottleSeconds * 1000
      #wait a couple seconds before querying service
      #console.log 'too soon on dispatch, waiting a couple seconds'
      setTimeout(->
          dispatchQuery(service_info, currentUrl, servicesInfo) 
        , 2000
      )
      return 0
    else
      serviceQueryTimestamps[service_info.name] = currentTime
  
  
  
  chrome.storage.local.get(null, (allItemsInLocalStorage) ->
    queryObj = {
      type: "GET"
      url: service_info.queryApi + encodeURIComponent(currentUrl)
      success: (queryResult) ->
        #console.log 'response yoyoyo'
        #console.debug queryResult
        responsePackage =
          
          forUrl: currentUrl
          
          servicesInfo: servicesInfo
          
          serviceName: service_info.name
          
          queryResult: queryResult
        
        #console.log 'responsePackage'
        #console.debug responsePackage
        
        setPreppedServiceResults(responsePackage, servicesInfo)
    }
    if service_info.name is 'reddit' and allItemsInLocalStorage.kiwi_reddit_oauth? 
      #console.log 'we are trying with oauth!'
      #console.debug allItemsInLocalStorage.kiwi_reddit_oauth
      queryObj.headers =
        'Authorization': "'bearer " + allItemsInLocalStorage.kiwi_reddit_oauth + "'"
    
    $.ajax( queryObj )
  )
   
dispatchGnewsQuery__customSearch = (customSearchQuery, servicesToSearch, service_info, servicesInfo) ->
  #console.log 'yolo 5 ~ - CUSTOM gnews'
  
  currentTime = Date.now()
  
  if newsSearch?
  
    # self imposed rate limiting per api
    if !serviceQueryTimestamps[service_info.name]?
      serviceQueryTimestamps[service_info.name] = currentTime
    else
      if (currentTime - serviceQueryTimestamps[service_info.name]) < queryThrottleSeconds * 1000
        #wait a couple seconds before querying service
        #console.log 'too soon on dispatch, waiting a couple seconds'
        setTimeout(->
            if currentUrl == tabUrl # if they've tabbed away, don't bother
                # (although this check exists within dispatchGnewsQuery as well)
              dispatchGnewsQuery__customSearch(service_info, customSearchQuery, servicesInfo) 
          , queryThrottleSeconds * 1000
        )
        return 0
      else
        serviceQueryTimestamps[service_info.name] = currentTime
    
    
    # // Set searchComplete as the callback function when a search is 
    # // complete.  The newsSearch object will have results in it.
    newsSearch.setSearchCompleteCallback( @,  () ->
      #console.log ' google #console.debug(newsSearch);'
      #console.debug(newsSearch);
      if _.isArray(newsSearch.results)
        results = newsSearch.results
      else
        results = []
      
      responsePackage =
        
        servicesInfo: servicesInfo
        servicesToSearch: servicesToSearch
        customSearchQuery: customSearchQuery
        serviceName: service_info.name
        queryResult: results
      setPreppedServiceResults__customSearch(responsePackage, servicesInfo)
       
    )
    newsSearch.execute(customSearchQuery);   
  
dispatchQuery__customSearch = (customSearchQuery, servicesToSearch, service_info, servicesInfo) ->
  #console.log 'yolo 5 ~ for CUSTOM ' + service_info.name
  #console.debug servicesToSearch
  
  currentTime = Date.now()
  
  # self imposed rate limiting per api
  if !serviceQueryTimestamps[service_info.name]?
    serviceQueryTimestamps[service_info.name] = currentTime
  else
    if (currentTime - serviceQueryTimestamps[service_info.name]) < queryThrottleSeconds * 1000
      
      #wait a couple seconds before querying service
      #console.log 'too soon on dispatch, waiting a couple seconds'
      setTimeout(->
          dispatchQuery__customSearch(customSearchQuery, servicesToSearch, service_info, servicesInfo) 
        , 2000
      )
      return 0
    else
      serviceQueryTimestamps[service_info.name] = currentTime
  
  
  
  queryUrl = service_info.customSearchApi + encodeURIComponent(customSearchQuery)
  
  if servicesToSearch[service_info.name].customSearchTags? and Object.keys(servicesToSearch[service_info.name].customSearchTags).length > 0
    
    for tagIdentifier, tagObject of servicesToSearch[service_info.name].customSearchTags
      
      queryUrl = queryUrl + service_info.customSearchTags__convention.string + service_info.customSearchTags[tagIdentifier].string
      
      #console.log 'asd;lfkjaewo;ifjae; '
      #console.log queryUrl
      # tagObject might one day accept special parameters like author name, etc
      
      
  chrome.storage.local.get(null, (allItemsInLocalStorage) ->
    queryObj = {
      type: "GET"
      url: queryUrl
      success: (queryResult) ->
        #console.log 'response yoyoyo'
        #console.debug queryResult
        responsePackage =
          
          servicesInfo: servicesInfo
          
          serviceName: service_info.name
          
          queryResult: queryResult
          
          servicesToSearch: servicesToSearch
          
          customSearchQuery: customSearchQuery
        
        #console.log 'responsePackage'
        #console.debug responsePackage
        
        setPreppedServiceResults__customSearch(responsePackage, servicesInfo)
    }
    if service_info.name is 'reddit' and allItemsInLocalStorage.kiwi_reddit_oauth? 
      #console.log 'we are trying with oauth!'
      #console.debug allItemsInLocalStorage.kiwi_reddit_oauth
      queryObj.headers =
        'Authorization': "'bearer " + allItemsInLocalStorage.kiwi_reddit_oauth + "'"
    
    $.ajax( queryObj )
  )
  
  
  # proactively set if all service_PreppedResults are ready.
    # will be set with available results if queried by popup.
  
  # the popup should always have enough to render with a properly set popupParcel.
setPreppedServiceResults__customSearch = (responsePackage, servicesInfo) ->
  #console.log 'yolo 6'
  
  currentTime = Date.now()
  
  for serviceObj in servicesInfo
    if serviceObj.name == responsePackage.serviceName
      serviceInfo = serviceObj
  
  
          # responsePackage =
          #   servicesInfo: servicesInfo
          #   serviceName: service_info.name
          #   queryResult: queryResult
          #   servicesToSearch: servicesToSearch  
          #   customSearchQuery: customSearchQuery
          
  # kiwi_customSearchResults = {}  # stores temporarily so if they close popup, they'll still have results
      # maybe it won't clear until new result -- "see last search"
    # queryString
    # servicesSearchesRequested = responsePackage.servicesToSearch
    # servicesSearched
      # <serviceName>
        # results
  
  # even if there are zero matches returned, that counts as a proper query response
  service_PreppedResults = parseResults[responsePackage.serviceName](responsePackage.queryResult, responsePackage.customSearchQuery, serviceInfo, true)
  
  if kiwi_customSearchResults? and kiwi_customSearchResults.queryString? and 
      kiwi_customSearchResults.queryString == responsePackage.customSearchQuery
    kiwi_customSearchResults.servicesSearched[responsePackage.serviceName] = {}
    kiwi_customSearchResults.servicesSearched[responsePackage.serviceName].results = service_PreppedResults
  else
    kiwi_customSearchResults = {}
    kiwi_customSearchResults.queryString = responsePackage.customSearchQuery
    kiwi_customSearchResults.servicesSearchesRequested = responsePackage.servicesToSearch
    kiwi_customSearchResults.servicesSearched = {}
    kiwi_customSearchResults.servicesSearched[responsePackage.serviceName] = {}
    kiwi_customSearchResults.servicesSearched[responsePackage.serviceName].results = service_PreppedResults
    
  
  #console.log 'yolo 6 results service_PreppedResults'
  #console.debug service_PreppedResults
  
  #console.log 'numberOfActiveServices'
  #console.debug returnNumberOfActiveServices(servicesInfo)
  
  numberOfActiveServices = Object.keys(responsePackage.servicesToSearch).length
  
  completedQueryServicesArray = []
  
  
  #number of completed responses
  if kiwi_customSearchResults.queryString == responsePackage.customSearchQuery
    for serviceName, service of kiwi_customSearchResults.servicesSearched
      completedQueryServicesArray.push(serviceName)
    
  completedQueryServicesArray = _.uniq(completedQueryServicesArray)
  
  #console.log 'completedQueryServicesArray.length '
  #console.log completedQueryServicesArray.length
  
  if completedQueryServicesArray.length is numberOfActiveServices and numberOfActiveServices != 0
    
      # NO LONGER STORING URL CACHE IN LOCALSTORAGE - BECAUSE : INFORMATION LEAKAGE / BROKEN EXTENSION SECURITY MODEL
        # get a fresh copy of urls results and reset with updated info
        # chrome.storage.local.get(null, (allItemsInLocalStorage) ->
          # #console.log 'trying to save all'
          # if !allItemsInLocalStorage['kiwi_urlsResultsCache']?
          #   allItemsInLocalStorage['kiwi_urlsResultsCache'] = {}
    
    #console.log 'yolo 6 _save_ results(servicesInfo, tempRes -- for ' + serviceInfo.name
    
    if kiwi_urlsResultsCache[tabUrl]?
      _set_popupParcel(kiwi_urlsResultsCache[tabUrl], tabUrl, true)
    else
      _set_popupParcel({}, tabUrl, true)
    
  # else
  #   #console.log 'yolo 6 not finished ' + serviceInfo.name
  #   _set_popupParcel(tempResponsesStore.services, responsePackage.forUrl, false)
    


_set_popupParcel = (setWith_urlResults, forUrl, sendPopupParcel, renderView = null, oldUrl = false) ->
  
  #console.log 'trying to set popupParcel, forUrl tabUrl' + forUrl + tabUrl
  # tabUrl
  if setWith_urlResults != {}
    if forUrl != tabUrl
      #console.log "_set_popupParcel request for old url"
      return false
  
  setObj_popupParcel = {}
  
  setObj_popupParcel.forUrl = tabUrl
  
  
  chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
    
    if !allItemsInSyncedStorage['kiwi_userPreferences']?
      setObj_popupParcel.kiwi_userPreferences = defaultUserPreferences
      
    else
      setObj_popupParcel.kiwi_userPreferences = allItemsInSyncedStorage['kiwi_userPreferences']
    
    if !allItemsInSyncedStorage['kiwi_servicesInfo']?
      setObj_popupParcel.kiwi_servicesInfo = defaultServicesInfo
      
    else
      setObj_popupParcel.kiwi_servicesInfo = allItemsInSyncedStorage['kiwi_servicesInfo']
    
    if renderView != null
      setObj_popupParcel.view = renderView
    
    
    if !allItemsInSyncedStorage['kiwi_alerts']?
    
      setObj_popupParcel.kiwi_alerts = []
      
    else
      setObj_popupParcel.kiwi_alerts = allItemsInSyncedStorage['kiwi_alerts']
      
    setObj_popupParcel.kiwi_customSearchResults = kiwi_customSearchResults
    
    if !setWith_urlResults?
      #console.log '_set_popupParcel called with undefined responses (not supposed to happen, ever)'
      return 0
    else
      setObj_popupParcel.allPreppedResults = setWith_urlResults
    
    if tabUrl == forUrl
      setObj_popupParcel.tabInfo = {} 
      setObj_popupParcel.tabInfo.tabUrl = tabUrl
      setObj_popupParcel.tabInfo.tabTitle = tabTitleObject.tabTitle
    else 
      setObj_popupParcel.tabInfo = null
    
    setObj_popupParcel.urlBlocked = false
    
    isUrlBlocked = is_url_blocked(allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklists, tabUrl)
    if isUrlBlocked == true
      setObj_popupParcel.urlBlocked = true
    
    if oldUrl is true
      setObj_popupParcel.oldUrl = true
    else
      setObj_popupParcel.oldUrl = false
    
    popupParcel = setObj_popupParcel
    
    #console.debug popupParcel
    
    if sendPopupParcel
      
      parcel = {}
      
      parcel.msg = 'kiwiPP_popupParcel_ready'
      parcel.forUrl = tabUrl
      
      parcel.popupParcel = setObj_popupParcel
      
      sendParcel(parcel)
    
  )
  



setPreppedServiceResults = (responsePackage, servicesInfo) ->
  #console.log 'yolo 6'
  currentTime = Date.now()
  
  if tabUrl == responsePackage.forUrl  # if false, then do nothing (user's probably switched to new tab)
    
    for serviceObj in servicesInfo
      if serviceObj.name == responsePackage.serviceName
        serviceInfo = serviceObj
    # serviceInfo = servicesInfo[responsePackage.serviceName]
    
    
    # even if there are zero matches returned, that counts as a proper query response
    service_PreppedResults = parseResults[responsePackage.serviceName](responsePackage.queryResult, responsePackage.forUrl, serviceInfo)
    
    tempResponsesStore.services[responsePackage.serviceName] =
      
      timestamp: currentTime
      service_PreppedResults: service_PreppedResults
      forUrl: responsePackage.forUrl
    
    #console.log 'yolo 6 results service_PreppedResults'
    #console.debug service_PreppedResults
    
    #console.log 'numberOfActiveServices'
    #console.debug returnNumberOfActiveServices(servicesInfo)
    
    numberOfActiveServices = returnNumberOfActiveServices(servicesInfo)
    
    completedQueryServicesArray = []
    
    #number of completed responses
    if tempResponsesStore.forUrl == tabUrl
      for serviceName, service of tempResponsesStore.services
        completedQueryServicesArray.push(serviceName)
        
    if kiwi_urlsResultsCache[tabUrl]?
      for serviceName, service of kiwi_urlsResultsCache[tabUrl]
        completedQueryServicesArray.push(serviceName)
      
    completedQueryServicesArray = _.uniq(completedQueryServicesArray)
    
    #console.log 'completedQueryServicesArray.length '
    #console.log completedQueryServicesArray.length
    
    if completedQueryServicesArray.length is numberOfActiveServices and numberOfActiveServices != 0
      
        # NO LONGER STORING URL CACHE IN LOCALSTORAGE - BECAUSE 1.) INFORMATION LEAKAGE, 2.) SLOWER
          # get a fresh copy of urls results and reset with updated info
          # chrome.storage.local.get(null, (allItemsInLocalStorage) ->
            # #console.log 'trying to save all'
            # if !allItemsInLocalStorage['kiwi_urlsResultsCache']?
            #   allItemsInLocalStorage['kiwi_urlsResultsCache'] = {}
      
      #console.log 'yolo 6 _save_url_results(servicesInfo, tempRes -- for ' + serviceInfo.name
      
      kiwi_urlsResultsCache = _save_url_results(servicesInfo, tempResponsesStore, kiwi_urlsResultsCache)
      
      _save_historyBlob(kiwi_urlsResultsCache, tabUrl)
      
      if popupOpen
        sendPopupParcel = true
        #console.log 'yolo 6 sendPopupParcel = true'
      else
        sendPopupParcel = false
        #console.log 'yolo 6 sendPopupParcel = false'
      
      _set_popupParcel(kiwi_urlsResultsCache[tabUrl], responsePackage.forUrl, sendPopupParcel)
      refreshBadge(servicesInfo, kiwi_urlsResultsCache[tabUrl])
      
    else
      #console.log 'yolo 6 not finished ' + serviceInfo.name
      _set_popupParcel(tempResponsesStore.services, responsePackage.forUrl, false)
      refreshBadge(servicesInfo, tempResponsesStore.services)





    
  
  
#returns an array of 'preppedResults' for url - just the keys we care about from the query-response
parseResults =
  
  reddit: (resultsObj, searchQueryString, serviceInfo, customSearchBool = false) ->
    
    matchedListings = []
    #console.log 'reddit: (resultsObj) ->'
    #console.debug resultsObj
    if resultsObj.kind? and resultsObj.kind == "Listing" and resultsObj.data? and 
        resultsObj.data.children? and resultsObj.data.children.length > 0
      
      for child in resultsObj.data.children
        
        if child.data?
          
          listingKeys = ["subreddit",'url',"score",'domain','gilded',"over_18","author","hidden","downs","permalink","created","title","created_utc","ups","num_comments"]
          
          preppedResult = _.pick(child.data, listingKeys)
          
          preppedResult.kiwi_created_at = preppedResult.created_utc * 1000 # to normalize to JS's Date.now() millisecond UTC timestamp
          
          if customSearchBool is false
            preppedResult.kiwi_exact_match = _exact_match_url_check(searchQueryString, preppedResult.url)
          else
            preppedResult.kiwi_exact_match = true
          
          preppedResult.kiwi_score = preppedResult.score
          
          preppedResult.kiwi_permaId = preppedResult.permalink
          
          matchedListings.push preppedResult
      
    return matchedListings
      
    
  hackerNews: (resultsObj, searchQueryString, serviceInfo, customSearchBool = false) ->
    
    matchedListings = []
    #console.log ' hacker news #console.debug resultsObj'
    #console.debug resultsObj
    # if resultsObj.nbHits? and resultsObj.nbHits > 0 and resultsObj.hits? and resultsObj.hits.length is resultsObj.nbHits
    if resultsObj.hits?
      for hit in resultsObj.hits
        
        listingKeys = ["points","num_comments","objectID","author","created_at","title","url","created_at_i"
              "story_text","comment_text","story_id","story_title","story_url"
            ]
        preppedResult = _.pick(hit, listingKeys)
        
        preppedResult.kiwi_created_at = preppedResult.created_at_i * 1000 # to normalize to JS's Date.now() millisecond UTC timestamp
        
        if customSearchBool is false
          preppedResult.kiwi_exact_match = _exact_match_url_check(searchQueryString, preppedResult.url)
        else
          preppedResult.kiwi_exact_match = true
        
        preppedResult.kiwi_score = preppedResult.points
        
        preppedResult.kiwi_permaId = preppedResult.objectID
        
        matchedListings.push preppedResult
      
    return matchedListings
  
  gnews: (resultsObj, searchQueryString, serviceInfo, customSearchBool = false) ->
    
    if customSearchBool == false
      forUrl = searchQueryString
      matchedListings = []
      #console.log 'gnews: (resultsObj) ->'
      #console.debug resultsObj
      
      for child in resultsObj
        
        
        listingKeys = ['clusterUrl','publisher','content','publishedDate','unescapedUrl','titleNoFormatting']
        
        preppedResult = _.pick(child, listingKeys)
        
        preppedResult.kiwi_created_at = Date.parse(preppedResult.publishedDate)
        
        preppedResult.kiwi_exact_match = false # impossible to know what's an exact match with gnews results
        
        preppedResult.kiwi_score = null
        
        preppedResult.kiwi_permaId = preppedResult.unescapedUrl
        
        if customSearchBool is false
              preppedResult.kiwi_exact_match = _exact_match_url_check(forUrl, preppedResult.url)
            else
              preppedResult.kiwi_exact_match = true
        preppedResult.kiwi_searchedFor = tabTitleObject.tabTitle
        
        if preppedResult.unescapedUrl != forUrl
          matchedListings.push preppedResult
          
        else if preppedResult.clusterUrl != ''
          matchedListings.push preppedResult
          
        
      currentTime = Date.now()
      
      # hacky, whatever
      noteworthy = false
      __numberOfStoriesFoundWithinTheHoursSincePostedLimit = 0
      __numberOfRelatedItemsWithClusterURL = 0
      
      for listing in matchedListings
        
          
        if listing.clusterUrl? and listing.clusterUrl != ''
          __numberOfRelatedItemsWithClusterURL++
          
        if (currentTime - listing.kiwi_created_at) < serviceInfo.notableConditions.hoursSincePosted * 3600000
          __numberOfStoriesFoundWithinTheHoursSincePostedLimit++
          
      
      if __numberOfStoriesFoundWithinTheHoursSincePostedLimit >= serviceInfo.notableConditions.numberOfStoriesFoundWithinTheHoursSincePostedLimit
        noteworthy = true
        
      if __numberOfRelatedItemsWithClusterURL >= serviceInfo.notableConditions.numberOfRelatedItemsWithClusterURL
        noteworthy = true
        
      if noteworthy
        matchedListings[0].kiwi_exact_match = true
      
      
      #console.log '#console.debug __numberOfStoriesFoundWithinTheHoursSincePostedLimit
      #console.debug serviceInfo.notableConditions.numberOfStoriesFoundWithinTheHoursSincePostedLimit'
      #console.debug __numberOfRelatedItemsWithClusterURL
      #console.debug serviceInfo.notableConditions.numberOfRelatedItemsWithClusterURL
      
      return matchedListings
    else
      matchedListings = []
      #console.log 'gnews: (resultsObj) ->'
      #console.debug resultsObj
      
      for child in resultsObj
        
        listingKeys = ['clusterUrl','publisher','content','publishedDate','unescapedUrl','titleNoFormatting']
        
        preppedResult = _.pick(child, listingKeys)
        
        preppedResult.kiwi_created_at = Date.parse(preppedResult.publishedDate)
        
        preppedResult.kiwi_exact_match = false # impossible to know what's an exact match with gnews results
        
        preppedResult.kiwi_score = null
        
        preppedResult.kiwi_permaId = preppedResult.unescapedUrl
        
        preppedResult.kiwi_searchedFor = searchQueryString
        
        preppedResult.kiwi_exact_match = false
        
        matchedListings.push preppedResult
        
      return matchedListings

_exact_match_url_check = (forUrl, preppedResultUrl) ->
  
  kiwi_exact_match = false
  
  modifications = [
    
      name: 'trailingSlash'
      modify: (tOrF, forUrl) ->
        
        if tOrF is 't'
          if forUrl[forUrl.length - 1] != '/'
            trailingSlashURL = forUrl + '/'
          else
            trailingSlashURL = forUrl
          return trailingSlashURL
        else
          if forUrl[forUrl.length - 1] == '/'
            noTrailingSlashURL = forUrl.substr(0,forUrl.length - 1)
          else
            noTrailingSlashURL = forUrl
          return noTrailingSlashURL
        # if forUrl[forUrl.length - 1] == '/'
  #   noTrailingSlashURL = forUrl.substr(0,forUrl.length - 1)
        
      existsTest: (forUrl) ->
        if forUrl[forUrl.length - 1] == '/'
          return 't'
        else
          return 'f'
    ,
      name: 'www'
      modify: (tOrF, forUrl) ->
        if tOrF is 't'
          protocolSplitUrlArray = forUrl.split('://')
          if protocolSplitUrlArray[1].indexOf('www.') != 0
            protocolSplitUrlArray[1] = 'www.' + protocolSplitUrlArray[1]
            WWWurl = protocolSplitUrlArray.join('://')
          else
            WWWurl = forUrl
          return WWWurl
        else
          wwwSplitUrlArray = forUrl.split('www.')
          if wwwSplitUrlArray.length is 2
            noWWWurl = wwwSplitUrlArray.join('')
            
          else if wwwSplitUrlArray.length > 2
            noWWWurl = wwwSplitUrlArray.shift() 
            noWWWurl += wwwSplitUrlArray.shift()
            noWWWurl += wwwSplitUrlArray.join('www.')
          else
            noWWWurl = forUrl
          return noWWWurl
      existsTest: (forUrl) ->
        if forUrl.split('//www.').length > 0
          return 't'
        else
          return 'f'
    ,
      name:'http'
      existsTest: (forUrl) ->
        if forUrl.indexOf('http://') is 0
          return 't'
        else
          return 'f'
      modify: (tOrF, forUrl) ->
        if tOrF is 't'
          if forUrl.indexOf('https://') == 0
            HTTPurl = 'http://' + forUrl.substr(8, forUrl.length - 1)
          else
            HTTPurl = forUrl
        else
          if forUrl.indexOf('http://') == 0
            HTTPSurl = 'https://' + forUrl.substr(7, forUrl.length - 1)
          else
            HTTPSurl = forUrl
          
    ]
  
  modPermutations = {}
  
  forUrlUnmodded = ''
  for mod in modifications
    forUrlUnmodded += mod.existsTest(forUrl)
  
  modPermutations[forUrlUnmodded] = forUrl
  
  existStates = ['t','f']
  for existState in existStates
    
    for mod, index in modifications
      checkArray = []
      for m in modifications
        checkArray.push existState
      
      forUrl_ = modifications[index].modify(existState, forUrl)
      
      for existState_ in existStates
        
        checkArray[index] = existState_
        
        for mod_, index_ in modifications
          
          if index != index_
            
            for existState__ in existStates
              
              checkArray[index_] = existState__
              checkString = checkArray.join('')
              
              if !modPermutations[checkString]?
                altUrl = forUrl_
                for existState_Char, cSindex in checkString
                  altUrl = modifications[cSindex].modify(existState_Char, altUrl)
                
                modPermutations[checkString] = altUrl
                
  kiwi_exact_match = false
  if preppedResultUrl == forUrl
    kiwi_exact_match = true
  for modKey, moddedUrl of modPermutations
    
    if preppedResultUrl == moddedUrl
      kiwi_exact_match = true
  
  return kiwi_exact_match

refreshBadge = (servicesInfo, resultsObjForCurrentUrl) ->
  
  # #console.log 'yolo 8'
  # #console.debug resultsObjForCurrentUrl
  # #console.debug servicesInfo
  
  # icon badges typically only have room for 5 characters
  
  currentTime = Date.now()
  
  abbreviationLettersArray = []
  
  for service, index in servicesInfo
    # if resultsObjForCurrentUrl[service.name]
    if service.name == "gnews"
      if resultsObjForCurrentUrl[service.name]? and resultsObjForCurrentUrl[service.name].service_PreppedResults.length > 0
        
        noteworthy = false
        # hacky - we did the notable check in parseResults, so that we can pass that info to popup too
        if resultsObjForCurrentUrl[service.name].service_PreppedResults[0].kiwi_exact_match == true
          noteworthy = true
        
        if noteworthy
          abbreviationLettersArray.push service.abbreviation
        
    else
      if resultsObjForCurrentUrl[service.name]? and resultsObjForCurrentUrl[service.name].service_PreppedResults.length > 0
        
        exactMatch = false
        noteworthy = false
        for listing in resultsObjForCurrentUrl[service.name].service_PreppedResults
          if listing.kiwi_exact_match
            exactMatch = true
            if listing.num_comments? and listing.num_comments >= service.notableConditions.num_comments
              noteworthy = true
              break
            if (currentTime - listing.kiwi_created_at) < service.notableConditions.hoursSincePosted * 3600000
              noteworthy = true
              break
        
        
        if service.updateBadgeOnlyWithExactMatch and exactMatch = false
          break
        
        #console.log service.name + ' noteworthy ' + noteworthy
        
        if noteworthy
          abbreviationLettersArray.push service.abbreviation
        else
          abbreviationLettersArray.push service.abbreviation.toLowerCase()
        #console.debug abbreviationLettersArray
        
  
  
   # if Object.keys(resultsObjForCurrentUrl).length == 0
  badgeText = ''
  if abbreviationLettersArray.length == 0
    chrome.storage.sync.get(null, (allItemsInSyncedStorage) -> 
      if allItemsInSyncedStorage['kiwi_userPreferences']? and allItemsInSyncedStorage['kiwi_userPreferences'].researchModeOnOff == 'off'
        badgeText = 'off'
      else if defaultUserPreferences.researchModeOnOff == 'off'
        badgeText = 'off'
      
      # \/\/\/\/ this is supposed to happen in initIfNewUrl \/\/\/\/
      # for urlSubstring in allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklists
      #   if tabUrl.indexOf(urlSubstring) != -1
      #     # user is not interested in results for this url
      #     updateBadgeText('block')
      #     #console.log '# user is not interested in results for this url: ' + tabUrl
      #     return 0 # we return before initializing script
    )
  else
    
    badgeText = abbreviationLettersArray.join(" ")
    
  #console.log 'yolo 8 ' + badgeText
  
  updateBadgeText(badgeText)
  
  

updateBadgeText = (text) ->
  
  chrome.browserAction.setBadgeText({'text':text.toString()})


periodicCleanup = (tab, allItemsInLocalStorage, allItemsInSyncedStorage, initialize_callback) ->
  #console.log 'wtf a'
  currentTime = Date.now()
  
  
  if(last_periodicCleanup < (currentTime - CLEANUP_INTERVAL))
    
    last_periodicCleanup = currentTime
    
    #console.log 'wtf b'
    # delete any results older than checkForUrlHourInterval 
    
    if Object.keys(kiwi_urlsResultsCache).length is 0
      #console.log 'wtf ba'
      # nothing to (potentially) clean up!
      initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
      
    else
      #console.log 'wtf bb'
      # allItemsInLocalStorage.kiwi_urlsResultsCache
      
      cull_kiwi_urlsResultsCache = _.extend {}, kiwi_urlsResultsCache
      
      for url, urlServiceResults of cull_kiwi_urlsResultsCache
        for serviceKey, serviceResults of urlServiceResults
          if currentTime - serviceResults.timestamp > checkForUrlHourInterval
            delete kiwi_urlsResultsCache[url]
      
      if Object.keys(kiwi_urlsResultsCache).length > maxUrlResultsStoredInLocalStorage
        
        # you've been surfing! wow
        
        num_results_to_delete = Object.keys(kiwi_urlsResultsCache).length - maxUrlResultsStoredInLocalStorage
        
        deletedCount = 0
        
        cull_kiwi_urlsResultsCache = _.extend {}, kiwi_urlsResultsCache
        
        for url, urlServiceResults of cull_kiwi_urlsResultsCache
          if deleteCount >= num_results_to_delete
            break
          
          if url != tab.url
            
            delete kiwi_urlsResultsCache[url]
            
            deletedCount++
        
        # chrome.storage.local.set({'kiwi_urlsResultsCache':kiwi_urlsResultsCache}, ->
            
        initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
          
        # )
      else
        initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
    
  else
    #console.log 'wtf c'
    initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)

_save_from_popupParcel = (_popupParcel, forUrl, updateToView) ->
  
  formerResearchModeValue = null
  formerKiwi_servicesInfo = null
  former_autoOffTimerType = null
  former_autoOffTimerValue = null
  
  # #console.log '#console.debug popupParcel
  #  #console.debug _popupParcel'
  
  # #console.debug popupParcel
  # #console.debug _popupParcel
  
  if popupParcel? and popupParcel.kiwi_userPreferences? and popupParcel.kiwi_servicesInfo
    formerResearchModeValue = popupParcel.kiwi_userPreferences.researchModeOnOff
    formerKiwi_servicesInfo = popupParcel.kiwi_servicesInfo
    former_autoOffTimerType = popupParcel.kiwi_userPreferences.autoOffTimerType
    former_autoOffTimerValue = popupParcel.kiwi_userPreferences.autoOffTimerValue
  
  popupParcel = {}
  
  # #console.log ' asdfasdfasd formerKiwi_autoOffTimerType'
  # #console.log former_autoOffTimerType
  # #console.log _popupParcel.kiwi_userPreferences.autoOffTimerType
  # #console.log ' a;woeifjaw;ef formerKiwi_autoOffTimerValue'
  # #console.log former_autoOffTimerValue
  # #console.log _popupParcel.kiwi_userPreferences.autoOffTimerValue
  
  if formerResearchModeValue? and formerResearchModeValue == 'off' and 
      _popupParcel.kiwi_userPreferences? and _popupParcel.kiwi_userPreferences.researchModeOnOff == 'on' or 
      (former_autoOffTimerType != _popupParcel.kiwi_userPreferences.autoOffTimerType or
      former_autoOffTimerValue != _popupParcel.kiwi_userPreferences.autoOffTimerValue)
    
    resetTimerBool = true
  else
    resetTimerBool = false
  
  _autoOffAtUTCmilliTimestamp = setAutoOffTimer(resetTimerBool, _popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp, 
      _popupParcel.kiwi_userPreferences.autoOffTimerValue, _popupParcel.kiwi_userPreferences.autoOffTimerType, 
      _popupParcel.kiwi_userPreferences.researchModeOnOff)
  
  _popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp = _autoOffAtUTCmilliTimestamp
  
  chrome.storage.sync.set({'kiwi_userPreferences': _popupParcel.kiwi_userPreferences}, ->
      
      chrome.storage.sync.set({'kiwi_servicesInfo': _popupParcel.kiwi_servicesInfo}, ->
          
          chrome.storage.sync.set({'kiwi_alerts': _popupParcel.kiwi_alerts}, ->
              
              if updateToView?
                
                parcel = {}
                popupParcel = _popupParcel
                parcel.msg = 'kiwiPP_popupParcel_ready'
                parcel.forUrl = tabUrl
                parcel.popupParcel = _popupParcel
                
                sendParcel(parcel)
              
              #console.log 'in _save_from_popupParcel _popupParcel.forUrl ' + _popupParcel.forUrl
              #console.log 'in _save_from_popupParcel tabUrl ' + tabUrl
              if _popupParcel.forUrl == tabUrl
                
                
                
                if formerResearchModeValue? and formerResearchModeValue == 'off' and 
                    _popupParcel.kiwi_userPreferences? and _popupParcel.kiwi_userPreferences.researchModeOnOff == 'on'
                  
                  initIfNewURL(true); return 0
                else if formerKiwi_servicesInfo? 
                  # so if user turns on a service and saves - it will immediately begin new query
                  formerActiveServicesList = _.pluck(formerKiwi_servicesInfo, 'active')
                  newActiveServicesList = _.pluck(_popupParcel.kiwi_servicesInfo, 'active')
                  #console.log 'formerActiveServicesList = _.pluck(formerKiwi_servicesInfo)'
                  #console.debug formerActiveServicesList
                  #console.log 'newActiveServicesList = _.pluck(_popupParcel.kiwi_servicesInfo)'
                  #console.debug newActiveServicesList
                  
                  if !_.isEqual(formerActiveServicesList, newActiveServicesList)
                    initIfNewURL(true); return 0
                  else
                    refreshBadge(_popupParcel.kiwi_servicesInfo, _popupParcel.allPreppedResults); return 0
                else
                  refreshBadge(_popupParcel.kiwi_servicesInfo, _popupParcel.allPreppedResults); return 0
                
              
            )
        )
    )

setAutoOffTimer = (resetTimerBool, autoOffAtUTCmilliTimestamp, autoOffTimerValue, autoOffTimerType, researchModeOnOff) ->
  #console.log 'trying setAutoOffTimer 43234'
  
  if resetTimerBool and kiwi_autoOffClearInterval?
    #console.log 'clearing timout'
    clearTimeout(kiwi_autoOffClearInterval)
    kiwi_autoOffClearInterval = null
  
    
  currentTime = Date.now()
  
  new_autoOffAtUTCmilliTimestamp = null
  
  if researchModeOnOff == 'on'
    if autoOffAtUTCmilliTimestamp == null || resetTimerBool
      
        
      if autoOffTimerType == '20'
        new_autoOffAtUTCmilliTimestamp = currentTime + 20 * 60 * 1000
      else if autoOffTimerType == '60'
        new_autoOffAtUTCmilliTimestamp = currentTime + 60 * 60 * 1000
      else if autoOffTimerType == 'always'
        new_autoOffAtUTCmilliTimestamp = null
      else if autoOffTimerType == 'custom'
        new_autoOffAtUTCmilliTimestamp = currentTime + parseInt(autoOffTimerValue) * 60 * 1000
        #console.log 'setting custom new_autoOffAtUTCmilliTimestamp ' + new_autoOffAtUTCmilliTimestamp
        
    else
      
      new_autoOffAtUTCmilliTimestamp = autoOffAtUTCmilliTimestamp
      
      if !kiwi_autoOffClearInterval? and autoOffAtUTCmilliTimestamp > currentTime
        #console.log 'resetting timer timeout'
        
        kiwi_autoOffClearInterval = setTimeout( turnResearchModeOff, new_autoOffAtUTCmilliTimestamp - currentTime )
      
      #console.log ' setting 123 autoOffAtUTCmilliTimestamp ' + new_autoOffAtUTCmilliTimestamp
      
      return new_autoOffAtUTCmilliTimestamp
  else
    # it's already off - no need for timer
    new_autoOffAtUTCmilliTimestamp = null
    
    #console.log 'researchModeOnOff is off - resetting autoOff timestamp and clearInterval'
    
    if kiwi_autoOffClearInterval?
      clearTimeout(kiwi_autoOffClearInterval)
      kiwi_autoOffClearInterval = null
  
  #console.log ' setting 000 autoOffAtUTCmilliTimestamp ' + new_autoOffAtUTCmilliTimestamp
  
  if new_autoOffAtUTCmilliTimestamp != null
    #console.log 'setting timer timeout'
    kiwi_autoOffClearInterval = setTimeout( turnResearchModeOff, new_autoOffAtUTCmilliTimestamp - currentTime )
  
  return new_autoOffAtUTCmilliTimestamp
    
    
turnResearchModeOff = ->
  #console.log 'turning off research mode - in turnResearchModeOff'
  
  chrome.storage.sync.get(null, (allItemsInSyncedStorage) -> 
    
    if kiwi_urlsResultsCache[tabUrl]?
      urlResults = kiwi_urlsResultsCache[tabUrl]
    else
      urlResults = {}
    
    if allItemsInSyncedStorage.kiwi_userPreferences?
      
      allItemsInSyncedStorage.kiwi_userPreferences.researchModeOnOff = 'off'
      chrome.storage.sync.set({'kiwi_userPreferences':allItemsInSyncedStorage.kiwi_userPreferences}, ->
          _set_popupParcel(urlResults, tabUrl, true)
          if allItemsInSyncedStorage.kiwi_servicesInfo?
            refreshBadge(allItemsInSyncedStorage.kiwi_servicesInfo, urlResults)
          else
            #console.log 'weird, allItemsInSyncedStorage.kiwi_servicesInfo not set'
        )
      
    else
      defaultUserPreferences.researchModeOnOff = 'off'
      
      chrome.storage.sync.set({'kiwi_userPreferences':defaultUserPreferences}, ->
          
          _set_popupParcel(urlResults, tabUrl, true)
          
          if allItemsInSyncedStorage.kiwi_servicesInfo?
            
            refreshBadge(allItemsInSyncedStorage.kiwi_servicesInfo, urlResults)
            
        )
    
  )

  # a wise coder once told me "try to keep functions to 10 lines or less." yea, welcome to initIfNewURL! let me find my cowboy hat :D
initIfNewURL = (overrideSameURLCheck_popupOpen = false, overrideResearchModeOff = false) ->
  
  if typeof overrideSameURLCheck_popupOpen != 'boolean'
    # ^^ because the Chrome api tab listening functions were exec-ing callback with an integer argument
      # that has since been negated by nesting the callback, but why not leave the check here?
    overrideSameURLCheck_popupOpen = false
  
  # #console.log 'wtf 1 kiwi_urlsResultsCache ' + overrideSameURLCheck_popupOpen
  if overrideSameURLCheck_popupOpen # for when a user turns researchModeOnOff "on" or refreshes results from popup
    popupOpen = true
  else
    popupOpen = false
  
  currentTime = Date.now()
  
  # chrome.tabs.getSelected(null,(tab) ->
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) ->
    
    if tabs.length > 0 and tabs[0].url?
        
      if tabs[0].url.indexOf('chrome-devtools://') != 0
        
        tabUrl = tabs[0].url
        
        # we care about the title, because it's the best way to search google news
        if tabs[0].status == 'complete'
          title = tabs[0].title
          
          if title.length > 3 and title[0] == "(" and isNaN(title[1]) == false and title.indexOf(')') != -1 and
              title.indexOf(')') != title.length - 1
            
            title = title.slice(title.indexOf(')') + 1 , title.length).trim()
          
          tabTitleObject = 
            tabTitle: title
            forUrl: tabUrl
            
        else
          
          tabTitleObject = 
            tabTitle: null
            forUrl: tabUrl
        
      else 
        _set_popupParcel({}, tabUrl, false)
        #console.log 'chrome-devtools:// has been the only url visited so far'
        return 0  
      
      tabUrl_hashWordArray = CryptoJS.SHA512(tabUrl)
      tabUrl_hash = tabUrl_hashWordArray.toString(CryptoJS.enc.Latin1)
      
      chrome.storage.local.get(null, (allItemsInLocalStorage) ->
        
        # #console.log 'chrome.storage.local.get(null, (allItemsInLocalStorage) ->  '
          
        sameURLCheck = true
        
        historyString = reduceHashByHalf(tabUrl_hash)
        
        if !allItemsInLocalStorage.persistentUrlHash?
          allItemsInLocalStorage.persistentUrlHash = ''
        
        
        if overrideSameURLCheck_popupOpen == false and allItemsInLocalStorage['kiwi_historyBlob']? and 
            allItemsInLocalStorage['kiwi_historyBlob'].indexOf(historyString) != -1 and 
            (!kiwi_urlsResultsCache? or !kiwi_urlsResultsCache[tabUrl]?)
          
          #console.log ' trying to set as old 123412341241234 ' 
          
          updateBadgeText('old')
          sameURLCheck = true
          
          _set_popupParcel({}, tabUrl, false, null, true)
          
          
        else if (overrideSameURLCheck_popupOpen == false and !allItemsInLocalStorage.persistentUrlHash?) or 
            allItemsInLocalStorage.persistentUrlHash? and allItemsInLocalStorage.persistentUrlHash != tabUrl_hash
            
          sameURLCheck = false
          
        
        else if overrideSameURLCheck_popupOpen == true
          sameURLCheck = false
        
        #useful for switching window contexts
        chrome.storage.local.set({'persistentUrlHash': tabUrl_hash}, ->)
        
        if sameURLCheck == false          
          updateBadgeText('')
          #console.log '#console.debug kiwi_urlsResultsCache'
          #console.debug kiwi_urlsResultsCache
        
          chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
            
            #console.log 'allItemsInSyncedStorage123'
            #console.debug allItemsInSyncedStorage
            if allItemsInSyncedStorage.kiwi_userPreferences?
              
              if allItemsInSyncedStorage.kiwi_userPreferences.autoOffAtUTCmilliTimestamp?
                if currentTime > allItemsInSyncedStorage.kiwi_userPreferences.autoOffAtUTCmilliTimestamp 
                  #console.log 'timer is past due - turning off - in initifnewurl'
                  allItemsInSyncedStorage.kiwi_userPreferences.researchModeOnOff = 'off'
                  
              if allItemsInSyncedStorage.kiwi_userPreferences.researchModeOnOff is 'off' and overrideResearchModeOff == false
                updateBadgeText('off')
                
                #console.log '#console.debug kiwi_urlsResultsCache'
                #console.debug kiwi_urlsResultsCache
                
                # showing cached responses
                if tabUrl == tempResponsesStore.forUrl
                  #console.log 'if tabUrl == tempResponsesStore.forUrl'
                  #console.log tabUrl
                  #console.log tempResponsesStore.forUrl
                  if kiwi_urlsResultsCache[tabUrl]?
                    _set_popupParcel(kiwi_urlsResultsCache[tabUrl],tabUrl,false);
                    if allItemsInSyncedStorage['kiwi_servicesInfo']?
                      refreshBadge(allItemsInSyncedStorage['kiwi_servicesInfo'], kiwi_urlsResultsCache[tabUrl])
                else
                  #console.log '_set_popupParcel({},tabUrl,false);  '
                  _set_popupParcel({},tabUrl,false);  
                return 0;
            
            
            periodicCleanup(tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage, (tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage) ->
              
              #console.log 'in initialize callback'
              
              if !allItemsInSyncedStorage['kiwi_userPreferences']?
                
                # defaultUserPreferences 
                
                #console.log "#console.debug allItemsInSyncedStorage['kiwi_userPreferences']"
                #console.debug allItemsInSyncedStorage['kiwi_userPreferences']
                
                _autoOffAtUTCmilliTimestamp = setAutoOffTimer(false, defaultUserPreferences.autoOffAtUTCmilliTimestamp, 
                    defaultUserPreferences.autoOffTimerValue, defaultUserPreferences.autoOffTimerType, defaultUserPreferences.researchModeOnOff)
                
                defaultUserPreferences.autoOffAtUTCmilliTimestamp = _autoOffAtUTCmilliTimestamp
                
                setObj =
                  kiwi_servicesInfo: defaultServicesInfo
                  kiwi_userPreferences: defaultUserPreferences
                chrome.storage.sync.set(setObj, ->
                  
                  isUrlBlocked = is_url_blocked(defaultUserPreferences.urlSubstring_blacklists, tabUrl)
                  if isUrlBlocked == true and overrideResearchModeOff == false
                    
                    # user is not interested in results for this url
                    updateBadgeText('block')
                    #console.log '# user is not interested in results for this url: ' + tabUrl
                    
                    _set_popupParcel({}, tabUrl, true)  # trying to send, because options page
                    
                    return 0 # we return before initializing script
                    
                  initialize(tabUrl)
                )
              else
                #console.log "allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklists"
                #console.debug allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklists
                
                isUrlBlocked = is_url_blocked(allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklists, tabUrl)
                
                if isUrlBlocked == true and overrideResearchModeOff == false
                  
                  # user is not interested in results for this url
                  updateBadgeText('block')
                  #console.log '# user is not interested in results for this url: ' + tabUrl
                  _set_popupParcel({}, tabUrl, true)  # trying to send, because options page
                  
                  return 0 # we return before initializing script
                    
                initialize(tabUrl)
            )
          )
        
    )
  )

chrome.tabs.onActivated.addListener( -> 
    # nesting function because the Chrome api tab listening functions were exec-ing callback with an integer argument
    initIfNewURL()
  )

chrome.tabs.onUpdated.addListener((tabId , info) ->
    updateBadgeText('')
    if tabTitleObject? and tabTitleObject.forUrl == tabUrl and !tabTitleObject.tabTitle?
      if (info.status == "complete") 
        #console.log ' if (info.status == "complete") '
        #console.debug info
        initIfNewURL(true)
        return 0
    else
      initIfNewURL()
  )

chrome.windows.onFocusChanged.addListener( -> 
    # nesting function because the Chrome api tab listening functions were exec-ing callback with an integer argument
    initIfNewURL()
  )

# intial startup
if tabTitleObject == null
  initIfNewURL(true)


getRandom = (min, max) ->
  return min + Math.floor(Math.random() * (max - min + 1))


#make it less unique and shorter
reduceHashByHalf = (hash, reducedByAFactorOf = 1) ->
  
  reduceStringByHalf = (_string_) ->
    newShortenedString = ''
    for char, index in _string_
      if index % 2 is 0 and (_string_.length - 1 > index + 1)
        char = if char > _string_[index + 1] then char else _string_[index + 1]
        newShortenedString += char
    return newShortenedString
    
  finalHash = ''
  
  counter = 0
  
  while counter < reducedByAFactorOf
    hash = reduceStringByHalf(hash)
    counter++
    
  return hash
  