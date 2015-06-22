
console.log 'wtf'

tabUrl = ''

popupOpen = false

checkForUrlHourInterval = 16

checkForUrl_Persistent_ChromeNotification_HourInterval = 3 # (max of 5 notification items)

last_periodicCleanup = 0 # timestamp

CLEANUP_INTERVAL = 3 * 3600000 # three hours

queryThrottleSeconds = 2

serviceQueryTimestamps = {}

maxUrlResultsStoredInLocalStorage = 800 # they're deleted after they've expired anyway - so this likely won't be reached by user

kiwi_urlsResultsCache = {}  
  # < url >:
  
    # < serviceName >: {
    #   forUrl: url
    #   timestamp:
    #   service_PreppedResults: 
    # }

tempResponsesStore = {}
  
  # results: 
  
    # < serviceName > :
    #   timestamp:
    #   service_PreppedResults:
    #   forUrl: url
  
  # forUrl:
  
  

popupParcel = {}
# proactively set if each services' preppedResults are ready.
  # will be set with available results if queried by popup.
  # {
    # forUrl:
    
    # allPreppedResults:
    
    # kiwi_servicesInfo:
    
    # kiwi_alerts:
    
    # kiwi_userPreferences:
  # }I

# tlds = [
#   '.com','.fr','.de','.co.uk',
#   '.net','.int','.edu','.gov','.mil','.co','.io',
#   '.au','.br','.cn','.dk','.es','.fi','.gb','.gr','.hk','.in','.it','.is','.jp','.ke','.no','.nl','.vn'
# ]

defaultUserPreferences = {
  
  fontSize: .8
  researchMode: 'on'
  autoOffAtUTCmilliTimestamp: null
  autoOffTimerType: 'always' # 'custom','always','20','60'
  autoOffTimerValue: null
   # to mitigate encryptedblacklist
  # extension badge - 
    # "block"
    
    # ~~~>
    
    # "on"
    # "off"
  
  
  
  # into ~~~>
    # research mode - off on(auto)/off(a la carte) - auto-off - timing-ish-module
  
  
  
    # suggested values to all users
  urlSubstring_blacklist: [
      'facebook.com'
    # ,
    #   'youtube.com'
    ,
      'news.ycombinator.com'
    ,
      'reddit.com'
    ,
      'https://www.google.com'
    ,
      'http://www.google.com'
    ,
      'docs.google'
    ,
      'drive.google'
    ,
      'accounts.google'
    ,
      'chrome://'
    ,
      '.slack.com/'
    ,
      '//t.co'
    ,
      '//bit.ly'
    ,
      '//goo.gl'
    ,
      '//mail.google'
    ,
      '//mail.yahoo.com'
    ,
      'hotmail.com'
    ,
      'outlook.com'
    # ,
    #   'twitter.com'
  ]
  
    
}

defaultServicesInfo = [
    
    name:"hackerNews"
    title: "Hacker News"
    abbreviation: "H"
    
    queryApi:"https://hn.algolia.com/api/v1/search?restrictSearchableAttributes=url&query="
    broughtToYouByTitle:"Algolia Hacker News API"
    broughtToYouByURL:"https://hn.algolia.com/api"
    
    permalinkBase: 'https://news.ycombinator.com/item?id='
    userPageBaselink: 'https://news.ycombinator.com/user?id='
    
    active: true
    
    notableConditions:
      hoursSincePosted: 5 # an exact match is less than 5 hours old
      num_comments: 10  # an exact match has 10 comments
    
    updateBadgeOnlyWithExactMatch: true
  ,
  
    name:"reddit"
    title: "Reddit"
    abbreviation: "R"
    
    queryApi:"https://www.reddit.com/submit.json?url="
    
    broughtToYouByTitle:"Reddit API"
    
    broughtToYouByURL:"https://github.com/reddit/reddit/wiki/API"
    
    permalinkBase: 'https://www.reddit.com'
    
    userPageBaselink: 'https://www.reddit.com/user/'
    
    active: true
    
    notableConditions:
      hoursSincePosted: 5 # an exact match is less than 5 hours old
      num_comments: 30   # an exact match has 30 comments
    
    updateBadgeOnlyWithExactMatch: true
    
    
  # {
  #   <voat, lobste.rs, metafilter, layervault -- get on this! ping me @spencenow if an API surfaces>  :D
  # },
  
]

# lastQueryTimestamp # to throttle




returnNumberOfActiveServices = (servicesInfo) ->
  
  numberOfActiveServices = 0
  for service in servicesInfo
    if service.active
      numberOfActiveServices++
  return numberOfActiveServices
      
      
      
  # allItemsInLocalStorage:  
    
    # only gets set if there's a response (even w/o results) from all services
      # otherwise, badge will update but no cache set.
      

    
    # persistent_urlResultsCheck = {
      
      # < url >: 
        # {
        #   url: url
        #   timestamp:
        #   servicesResults: 
          # if another url pops up. update again
        # }
    # }


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
    
# popupParcel

    # viewPreference: null # could be results, alerts, preferences

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
    
    port.onMessage.addListener( (dataFromPopup) ->
      
      if !dataFromPopup.msg?
        return false
      
      switch dataFromPopup.msg
        
        # when 'post_refreshQuery'
          
        when 'kiwiPP_post_addAlert'
          
          popupOpen = true
          
          
          
        when 'kiwiPP_post_save_a_la_carte'
          popupOpen = true
          _save_a_la_carte(dataFromPopup)    
        
        when 'kiwiPP_post_savePopupParcel'
          popupOpen = true
          
          _save_from_popupParcel(dataFromPopup.newPopupParcel, dataFromPopup.forUrl, dataFromPopup.refreshView)
          
          if kiwi_urlsResultsCache[tabUrl]?
            
            refreshBadge(dataFromPopup.newPopupParcel.kiwi_servicesInfo, kiwi_urlsResultsCache[tabUrl])
          
        when 'kiwiPP_post_refreshQuery'
          
          popupOpen = true
          
        when 'kiwiPP_request_popupParcel'
          
          console.log " when 'kiwiPP_request_popupParcel' "
          
          popupOpen = true
          
          console.log 'dataFromPopup.forUrl' + dataFromPopup.forUrl
          console.log 'tabUrl:' + tabUrl
          
          if dataFromPopup.forUrl is tabUrl
            # console.log popupParcel.forUrl
            # console.log tabUrl
            if popupParcel? and popupParcel.forUrl is tabUrl
              # console.log 'parcel is ready for tabUrl' + tabUrl
              console.log "popup parcel ready"
              
              parcel = {}
          
              parcel.msg = 'kiwiPP_popupParcel_ready'
              parcel.forUrl = tabUrl
              parcel.popupParcel = popupParcel
              
              sendParcel(parcel)
            else
              # console.log 'parcel is Not ready for tabUrl, must be set' + tabUrl
              
              console.log "popup parcel not ready"
              
              if !tempResponsesStore.services?
                _set_popupParcel({}, tabUrl, true)
              else
                _set_popupParcel(tempResponsesStore.services, tabUrl, true)
          
          # if tabUrl is serviceMatchObj.forUrl and serviceMatchObj.serviceMatch is false
          #   messageMainView_noServiceMatch(tabUrl)
            
          # else if Object.keys(popupParcel).length > 0 and tabUrl is dataFromPopup.forUrl
          #   sendObj = 
          #     'popupParcel': popupParcel 
          #     'forUrl':tabUrl
          #     'msg':'popupParcel_ready'
          #   sendParcel(sendObj)
            
          # else if tabUrl is dataFromPopup.forUrl
          #   sendObj = 
          #     'msg':'popupParcel_pending'
          #     'forUrl':tabUrl
          #   sendParcel(sendObj)
          # else
          #   messageMainView_noServiceMatch(tabUrl)
          
    )
)



initialize = (currentUrl) ->
  console.log 'yolo 1 ' + currentUrl
  
  
  
  
   # to prevent repeated api requests - we check to see if we have an up-to-date version in local storage
  chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
    
    console.log 'console.debug allItemsInLocalStorage'
    console.debug allItemsInSyncedStorage
    
    
    if !allItemsInSyncedStorage['kiwi_servicesInfo']?
        # we set the defaults in localStorage if servicesInfo doesn't exist in localStorage 
      chrome.storage.sync.set({'kiwi_servicesInfo': defaultServicesInfo}, (servicesInfo) ->
        getUrlResults_to_refreshBadgeIcon(defaultServicesInfo, currentUrl)
      )
      
    else
      getUrlResults_to_refreshBadgeIcon(allItemsInSyncedStorage['kiwi_servicesInfo'], currentUrl)
  )
  
getUrlResults_to_refreshBadgeIcon = (servicesInfo, currentUrl) ->
  
  console.log 'yolo 2  getUrlResults_to_refreshBadgeIcon'
  
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
      console.log 'console.debug tempResponsesStore.services'
      console.debug tempResponsesStore.services
      _set_popupParcel(tempResponsesStore.services, currentUrl, sendPopupParcel)
      
          
    else
      # this url has not been checked
      check_updateServiceResults(servicesInfo, currentUrl, kiwi_urlsResultsCache)
        
  else
    # no urls have been checked
    
    check_updateServiceResults(servicesInfo, currentUrl, null)


_save_url_results = (servicesInfo, tempResponsesStore, urlsResultsCache) ->
  console.log 'yolo 3'
  
  debugResultsCache_beforeUpdate = _.extend {}, urlsResultsCache
  
  previousUrl = tempResponsesStore.forUrl
  
  if urlsResultsCache[previousUrl]? 
    changedBool = false
      # these will always be at least as recent as what's in the store. 
    for service in servicesInfo
      
      if tempResponsesStore.services[service.name]?
        changedBool = true
        urlsResultsCache[previousUrl][service.name] =
          forUrl: previousUrl
          timestamp: tempResponsesStore.services[service.name].timestamp
          service_PreppedResults: tempResponsesStore.services[service.name].service_PreppedResults
        
    # if changedBool
    #   chrome.storage.local.set({'kiwi_urlsResultsCache': urlsResultsCache}, ->
    #     console.log('urls results cache before update ')
    #     console.debug debugResultsCache_beforeUpdate
        
    #     console.log('urls results cache after update ')
    #     console.debug urlsResultsCache
        
    #     console.log 'tempResponsesStore.services[service.name]'
    #     console.debug tempResponsesStore.services[service.name]
    #   )
      
  else
    urlsResultsCache[previousUrl] = {}
    urlsResultsCache[previousUrl] = tempResponsesStore.services
    
    
      
    # chrome.storage.local.set({'kiwi_urlsResultsCache': urlsResultsCache}, ->
    #     console.log 'this was the first .set of urlsResults cache'
    #     console.log 'for url ' + previousUrl
    #     console.log 'console.debug urlsResultsCache'
    #     console.debug urlsResultsCache
    #   )
    
    
check_updateServiceResults = (servicesInfo, currentUrl, urlsResultsCache = null) ->
  console.log 'yolo 4'
  # if any results from previous tab have not been set, set them.
  if urlsResultsCache? and Object.keys(tempResponsesStore).length > 0
    previousResponsesStore = _.extend {}, tempResponsesStore
    _urlsResultsCache = _.extend {}, urlsResultsCache
    
    _save_url_results(servicesInfo, previousResponsesStore, _urlsResultsCache)
  
  # refresh tempResponsesStore for new url
  tempResponsesStore.forUrl = currentUrl
  tempResponsesStore.services = {}
  
  currentTime = Date.now()
  
  if !urlsResultsCache?
    urlsResultsCache = {}
  if !urlsResultsCache[currentUrl]?
    urlsResultsCache[currentUrl] = {}
  
  console.log 'about to check for dispatch query'
  console.debug urlsResultsCache[currentUrl]
  console.log 'current time'
  console.log currentTime
  # console.log 'urlsResultsCache[currentUrl][service.name].timestamp'
  # console.log urlsResultsCache[currentUrl][service.name].timestamp
  
  # check on a service-by-service basis (so we don't requery all services just b/c one api/service is down)
  for service in servicesInfo
    if urlsResultsCache[currentUrl][service.name]?
      if (currentTime - urlsResultsCache[currentUrl][service.name].timestamp) > checkForUrlHourInterval * 3600000
        dispatchQuery(service, currentUrl, servicesInfo)
    else
      dispatchQuery(service, currentUrl, servicesInfo)
    
    
dispatchQuery = (service_info, currentUrl, servicesInfo) ->
  console.log 'yolo 5'
  
  currentTime = Date.now()
  
  if !serviceQueryTimestamps[service_info.name]?
    serviceQueryTimestamps[service_info.name] = currentTime
  else
    if (currentTime - serviceQueryTimestamps[service_info.name]) < queryThrottleSeconds * 1000
      #wait a couple seconds before querying service
      console.log 'too soon on dispatch, waiting a couple seconds'
      setTimeout(->
            dispatchQuery(service_info, currentUrl, servicesInfo) 
        , 2000
      )
      return 0
    else
      serviceQueryTimestamps[service_info.name] = currentTime
  
  
  queryUrl = service_info.queryApi + encodeURIComponent(currentUrl)
  console.log 'yolo 5 ' + queryUrl
  
  $.ajax( queryUrl, { success: (queryResult) ->
    
    responsePackage =
      
      forUrl: currentUrl
      
      servicesInfo: servicesInfo
      
      serviceName: service_info.name
      
      queryResult: queryResult
    
    console.log 'responsePackage'
    console.debug responsePackage
    
    setPreppedServiceResults(responsePackage, servicesInfo)
  })

  
  # proactively set if all service_PreppedResults are ready.
    # will be set with available results if queried by popup.
  
  # the popup should always have enough to render with a properly set popupParcel.

_save_from_popupParcel = (_popupParcel, forUrl, updateToView) ->
  popupParcel = {}
  
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
              
            )
        )
    )
  

_set_popupParcel = (setWith_urlResults, forUrl, sendPopupParcel, renderView = null) ->
  
  console.log 'trying to set popupParcel, forUrl tabUrl'
  console.log forUrl
  console.log tabUrl
  # tabUrl
  if setWith_urlResults != {}
    if forUrl != tabUrl
      console.log "_set_popupParcel request for old url"
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
      
    
    if !setWith_urlResults?
      console.log '_set_popupParcel called with undefined responses (not supposed to happen, ever)'
      return 0
    else
      setObj_popupParcel.allPreppedResults = setWith_urlResults
    
    popupParcel = setObj_popupParcel
    console.debug popupParcel
    if sendPopupParcel
      
      parcel = {}
      
      parcel.msg = 'kiwiPP_popupParcel_ready'
      parcel.forUrl = tabUrl
      parcel.popupParcel = setObj_popupParcel
      
      sendParcel(parcel)
    
  )
  
setPreppedServiceResults = (responsePackage, servicesInfo) ->
  console.log 'yolo 6'
  currentTime = Date.now()
  
  if tabUrl == responsePackage.forUrl  # if false, then do nothing (user's probably switched to new tab)
    
    # even if there are zero matches returned, that counts as a proper query response
    service_PreppedResults = parseResults[responsePackage.serviceName](responsePackage.queryResult, responsePackage.forUrl)
    
    tempResponsesStore.services[responsePackage.serviceName] =
      timestamp: currentTime
      service_PreppedResults: service_PreppedResults
      forUrl: responsePackage.forUrl
    
    console.log 'yolo 6 results service_PreppedResults'
    console.debug service_PreppedResults
    console.log 'Object.keys(tempResponsesStore.services).length'
    console.debug Object.keys(tempResponsesStore.services).length
    console.log 'numberOfActiveServices'
    console.debug returnNumberOfActiveServices(servicesInfo)
    
    numberOfActiveServices = returnNumberOfActiveServices(servicesInfo)
    
    if Object.keys(tempResponsesStore.services).length is numberOfActiveServices and numberOfActiveServices != 0
      
      chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
      
        # NO LONGER STORING URL CACHE IN LOCALSTORAGE - BECAUSE 1.) INFORMATION LEAKAGE, 2.) SLOWER
          # get a fresh copy of urls results and reset with updated info
          # chrome.storage.local.get(null, (allItemsInLocalStorage) ->
            # console.log 'trying to save all'
            # if !allItemsInLocalStorage['kiwi_urlsResultsCache']?
            #   allItemsInLocalStorage['kiwi_urlsResultsCache'] = {}
            
          
          _save_url_results(allItemsInSyncedStorage['kiwi_servicesInfo'], tempResponsesStore, kiwi_urlsResultsCache)
          
          
        
      )
      
      if popupOpen
        sendPopupParcel = true
      else
        sendPopupParcel = false
      
      _set_popupParcel(tempResponsesStore.services, responsePackage.forUrl, sendPopupParcel)
      refreshBadge(servicesInfo, tempResponsesStore.services)
    else
      _set_popupParcel(tempResponsesStore.services, responsePackage.forUrl, false)
      refreshBadge(servicesInfo, tempResponsesStore.services)

#returns an array of 'preppedResults' for url - just the keys we care about from the query-response
parseResults =
  
  reddit: (resultsObj, forUrl) ->
    
    matchedListings = []
    console.log 'reddit: (resultsObj) ->'
    console.debug resultsObj
    if resultsObj.kind? and resultsObj.kind == "Listing" and resultsObj.data? and 
        resultsObj.data.children? and resultsObj.data.children.length > 0
      
      for child in resultsObj.data.children
        
        if child.data?
          
          listingKeys = ["subreddit",'url',"score","over_18","author","hidden","downs","permalink","created","title","created_utc","ups","num_comments"]
          
          preppedResult = _.pick(child.data, listingKeys)
            
          preppedResult.kiwi_created_at = preppedResult.created_utc * 1000 # to normalize to JS's Date.now() millisecond UTC timestamp
          
          preppedResult.kiwi_exact_match = _exact_match_url_check(forUrl, preppedResult.url)
          
          preppedResult.kiwi_score = preppedResult.score
          
          preppedResult.kiwi_permaId = preppedResult.permalink
          
          matchedListings.push preppedResult
      
    return matchedListings
      
    
  hackerNews: (resultsObj, forUrl) ->
    
    matchedListings = []
    
    if resultsObj.nbHits? and resultsObj.nbHits > 0 and resultsObj.hits? and resultsObj.hits.length is resultsObj.nbHits
      
      for hit in resultsObj.hits
        
        listingKeys = ["points","num_comments","objectID","author","created_at","title","url","created_at_i"]
        preppedResult = _.pick(hit, listingKeys)
        
        preppedResult.kiwi_created_at = preppedResult.created_at_i * 1000 # to normalize to JS's Date.now() millisecond UTC timestamp
        
        preppedResult.kiwi_exact_match = _exact_match_url_check(forUrl, preppedResult.url)
        
        preppedResult.kiwi_score = preppedResult.points
        
        preppedResult.kiwi_permaId = preppedResult.objectID
        
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
  
  console.log 'yolo 8'
  console.debug resultsObjForCurrentUrl
  console.debug servicesInfo
  
  badgeText = ''
  # icon badges typically only have room for 5 characters
  
  currentTime = Date.now()
  
  if Object.keys(resultsObjForCurrentUrl).length == 0
    chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->     
      if allItemsInSyncedStorage['kiwi_userPreferences']? and allItemsInSyncedStorage['kiwi_userPreferences'].researchMode == 'off'
        badgeText = 'off'
        updateBadgeText(badgeText); return 0;
      else if defaultUserPreferences.researchMode == 'off'
        badgeText = 'off'
        updateBadgeText(badgeText); return 0;
    )
  
  
  updateCount = 0
  for service, index in servicesInfo
    if resultsObjForCurrentUrl[service.name]
      if resultsObjForCurrentUrl[service.name].service_PreppedResults.length > 0
        
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
          
        if updateCount != 0
          badgeText += " "
        
        if noteworthy
          badgeText += service.abbreviation
        else
          badgeText += service.abbreviation.toLowerCase()
        updateCount++
  console.log 'yolo 8 ' + badgeText
  
  if badgeText != ''
    updateBadgeText(badgeText)
  
  

updateBadgeText = (text) ->
  
  chrome.browserAction.setBadgeText({'text':text.toString()})


periodicCleanup = (tab, allItemsInLocalStorage, allItemsInSyncedStorage, initialize_callback) ->
  console.log 'wtf a'
  currentTime = Date.now()
  
  
  if(last_periodicCleanup < (currentTime - CLEANUP_INTERVAL))
    
    last_periodicCleanup = currentTime
    
    console.log 'wtf b'
    # delete any results older than checkForUrlHourInterval 
    
    if Object.keys(kiwi_urlsResultsCache).length is 0
      console.log 'wtf ba'
      # nothing to (potentially) clean up!
      initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
      
    else
      console.log 'wtf bb'
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
    console.log 'wtf c'
    initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
  



initIfNewURL = ->
  
  console.log 'wtf 1'
  _this = @
  
  
  popupOpen = false
  
  
  # chrome.tabs.getSelected(null,(tab) ->
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) ->
    
    if tabs.length > 0 and tabs[0].url?
        
      if tabs[0].url.indexOf('chrome-devtools://') != 0
      
        tabUrl = tabs[0].url
      
      else 
        _set_popupParcel({}, tabUrl, false)
        console.log 'chrome-devtools:// has been the only url visited so far'
        return 0  
      
      tabUrl_hashWordArray = CryptoJS.SHA512(tabUrl)
      tabUrl_hash = tabUrl_hashWordArray.toString(CryptoJS.enc.Base64)
            
      chrome.storage.local.get(null, (allItemsInLocalStorage) ->     
        
        if !allItemsInLocalStorage.persistentUrlHash? or allItemsInLocalStorage.persistentUrlHash != tabUrl_hash
          
          updateBadgeText('')
          
          
            #useful for switching window contexts
          chrome.storage.local.set({'persistentUrlHash': tabUrl_hash}, ->)
      
          
          console.log 'popupParcel 123123'
          console.debug popupParcel
          
        
          chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
            
            console.log 'allItemsInSyncedStorage123'
            console.debug allItemsInSyncedStorage
            if allItemsInSyncedStorage.kiwi_userPreferences?
              if allItemsInSyncedStorage.kiwi_userPreferences.researchMode is 'off'
                updateBadgeText('off')
                
                console.log 'console.debug kiwi_urlsResultsCache'
                console.debug kiwi_urlsResultsCache
                
                # showing cached responses
                if tabUrl == tempResponsesStore.forUrl
                  if kiwi_urlsResultsCache[tabUrl]?
                    _set_popupParcel(kiwi_urlsResultsCache[tabUrl],tabUrl,false);
                    if allItemsInSyncedStorage['kiwi_servicesInfo']?
                      refreshBadge(allItemsInSyncedStorage['kiwi_servicesInfo'], kiwi_urlsResultsCache[tabUrl])
                    
                return 0;
            
            
            periodicCleanup(tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage, (tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage) ->
              
              console.log 'in initialize callback'
              
              if !allItemsInSyncedStorage['kiwi_userPreferences']?
                
                  
                # defaultUserPreferences 
                
                console.log "console.debug allItemsInSyncedStorage['kiwi_userPreferences']"
                console.debug allItemsInSyncedStorage['kiwi_userPreferences']
                chrome.storage.sync.set({'kiwi_userPreferences':defaultUserPreferences}, ->
                  
                    
                  for urlSubstring in defaultUserPreferences.urlSubstring_blacklist
                    if tabUrl.indexOf(urlSubstring) != -1
                      # user is not interested in results for this url
                      updateBadgeText('block')
                      console.log '# user is not interested in results for this url: ' + tabUrl
                      
                      _set_popupParcel({}, tabUrl, false)
                      
                      return 0 # we return before initializing script
                    
                  initialize(tabUrl)
                )
              else
                console.log "allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklist"
                console.debug allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklist
                
                
                for urlSubstring in allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklist
                  if tabUrl.indexOf(urlSubstring) != -1
                    # user is not interested in results for this url
                    updateBadgeText('block')
                    console.log '# user is not interested in results for this url: ' + tabUrl
                    _set_popupParcel({}, tabUrl, false)
                    return 0 # we return before initializing script
                    
                initialize(tabUrl)
                 
            )
          )
        )
  )
  
  


chrome.tabs.onActivated.addListener( initIfNewURL )

chrome.tabs.onUpdated.addListener( initIfNewURL )

chrome.windows.onFocusChanged.addListener( initIfNewURL )




