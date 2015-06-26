
console.log 'wtf'

tabUrl = ''

popupOpen = false

researchMode = true # if false, will only check tabUrl against recent top results from HN, Reddit

checkForUrlHourInterval = 16

checkForUrl_Persistent_ChromeNotification_HourInterval = 3 # (max of 5 notification items)

last_periodicCleanup = 0 # timestamp

CLEANUP_INTERVAL = 3 * 3600000 # three hours

maxUrlResultsStoredInLocalStorage = 800 # they're deleted after they've expired anyway - so this likely won't be reached by user

urlsResultsCache = {}  
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
    
    # servicesInfo:
    
    # alerts:
    
    # userPrefs:
  # }I
  
defaultUserPreferences = {
  
    urlSubstring_blacklist: [
      'www.facebook.',
      'news.ycombinator.',
      'www.google.',
      'chrome://'
    ],
    
    researchMode: true
    
  }

defaultServicesInfo = [
  
  {
    name:"reddit"
    title: "Reddit"
    abbreviation: "R"
    
    queryApi:"https://www.reddit.com/submit.json?url="
    broughtToYouByTitle:"Reddit API"
    broughtToYouByURL:"https://github.com/reddit/reddit/wiki/API"
    
    active: true
    
    conditionsForCaps:
      hoursSincePosted: 5 # an exact match is less than 5 hours old
      num_comments: 30   # an exact match has 30 comments
    
    updateBadgeOnlyWithExactMatch: true
  },
  
  {
    name:"hackerNews"
    title: "Hacker News"
    abbreviation: "H"
    
    queryApi:"https://hn.algolia.com/api/v1/search?restrictSearchableAttributes=url&query="
    broughtToYouByTitle:"Algolia Hacker News API"
    broughtToYouByURL:"https://hn.algolia.com/api"
    
    active: true
    
    conditionsForCaps:
      hoursSincePosted: 5 # an exact match is less than 5 hours old
      num_comments: 10  # an exact match has 10 comments
    
    updateBadgeOnlyWithExactMatch: true
  },
  
  
  # {
  #   <product hunt, lobste.rs, metafilter, layervault -- get on this! ping me @spencenow if an API surfaces>  :D
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



chrome.extension.onConnect.addListener((port) ->
  
  if port.name is 'kiwi_fromBackgroundToPopup'
    
    port.onMessage.addListener( (dataFromPopup) ->
      
      if !dataFromPopup.msg?
        return false
      
      switch dataFromPopup.msg
        
        # when 'post_refreshQuery'
          
        when 'kiwiPP_post_addAlert'
          
          popupOpen = true
          
        when 'kiwiPP_post_refreshQuery'
          
          popupOpen = true
          
        when 'kiwiPP_request_popupParcel'
          
          console.log " when 'kiwiPP_request_popupParcel' "
          
          popupOpen = true
          
          console.log dataFromPopup.forUrl
          console.log tabUrl
          if dataFromPopup.forUrl is tabUrl
            # console.log popupParcel.forUrl
            # console.log tabUrl
            if popupParcel? and popupParcel.forUrl is tabUrl
              console.log 'parcel is ready for tabUrl' + tabUrl
              
              parcel = {}
          
              parcel.msg = 'kiwiPP_popupParcel_ready'
              parcel.forUrl = tabUrl
              parcel.popupParcel = popupParcel
              
              sendParcel(parcel)
            else
              console.log 'parcel is Not ready for tabUrl, must be set' + tabUrl
              
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
    console.debug allItemsInLocalStorage
    
    
    
    if !allItemsInSyncedStorage['kiwi_servicesInfo']?
        # we set the defaults in localStorage if servicesInfo doesn't exist in localStorage 
      chrome.storage.sync.set({'kiwi_servicesInfo': defaultServicesInfo}, (servicesInfo) ->
        getUrlResults_to_refreshBadgeIcon(allItemsInLocalStorage, allItemsInSyncedStorage['kiwi_servicesInfo'], currentUrl)
      )
      
    else
      getUrlResults_to_refreshBadgeIcon(allItemsInLocalStorage, allItemsInSyncedStorage['kiwi_servicesInfo'], currentUrl)
    
  )
  
getUrlResults_to_refreshBadgeIcon = (allItemsInLocalStorage, servicesInfo, currentUrl) ->
  
  console.log 'yolo 2  getUrlResults_to_refreshBadgeIcon'
  
  currentTime = Date.now()
  
  if allItemsInLocalStorage['kiwi_urlsResultsCache']?
    
    if allItemsInLocalStorage['kiwi_urlsResultsCache'][currentUrl]?
      
      # start off by instantly updating UI with what we know
      refreshBadge(servicesInfo, allItemsInLocalStorage['kiwi_urlsResultsCache'][currentUrl])
      
      for service in servicesInfo
        if allItemsInLocalStorage['kiwi_urlsResultsCache'][currentUrl][service.name]?
          if (currentTime - allItemsInLocalStorage['kiwi_urlsResultsCache'][currentUrl][service.name].timestamp) > checkForUrlHourInterval * 3600000
            
            check_updateServiceResults(servicesInfo, currentUrl, allItemsInLocalStorage['kiwi_urlsResultsCache'])  
            return 0
          
        else
          check_updateServiceResults(servicesInfo, currentUrl, allItemsInLocalStorage['kiwi_urlsResultsCache'])  
          return 0
      
      # for urls that are being visited a second time, 
      # all recent results present kiwi_urlsResultsCache (for all services)
      # we set tempResponsesStore before setting popupParcel
      
      tempResponsesStore.forUrl = currentUrl
      tempResponsesStore.services = allItemsInLocalStorage['kiwi_urlsResultsCache'][currentUrl]
      
      if popupOpen
        sendPopupParcel = true
      else
        sendPopupParcel = false
      
      _set_popupParcel(tempResponsesStore.services, currentUrl, sendPopupParcel)
      
          
    else
      # this url has not been checked
      check_updateServiceResults(servicesInfo, currentUrl, allItemsInLocalStorage['kiwi_urlsResultsCache'])
      
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
        
    if changedBool
      chrome.storage.local.set({'kiwi_urlsResultsCache': urlsResultsCache}, ->
        console.log('urls results cache before update ')
        console.debug debugResultsCache_beforeUpdate
        
        console.log('urls results cache after update ')
        console.debug urlsResultsCache
        
        console.log 'tempResponsesStore.services[service.name]'
        console.debug tempResponsesStore.services[service.name]
      )
      
  else
    urlsResultsCache[previousUrl] = {}
    urlsResultsCache[previousUrl] = tempResponsesStore.services
      
    chrome.storage.local.set({'kiwi_urlsResultsCache': urlsResultsCache}, ->
        console.log 'this was the first .set of urlsResults cache'
        console.log 'for url ' + previousUrl
        console.log 'console.debug urlsResultsCache'
        console.debug urlsResultsCache
      )
    
    

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
  
_set_popupParcel = (setWith_urlResults, forUrl, sendPopupParcel) ->
  
  console.log 'trying to set popupParcel, forUrl tabUrl'
  console.log forUrl
  console.log tabUrl
  # tabUrl
  
  if forUrl != tabUrl
    console.log "_set_popupParcel request for old url"
    return false
  
  
  setObj_popupParcel = {}
  
  setObj_popupParcel.forUrl = tabUrl
  
  chrome.storage.sync.get(null, (allItemsInLocalStorage) -> 
    
    
    if !allItemsInSyncedStorage['kiwi_userPreferences']?
      setObj_popupParcel.userPrefs = defaultUserPreferences
      
    else
      setObj_popupParcel.userPrefs = allItemsInSyncedStorage['kiwi_userPreferences']
    
    
    
    if !allItemsInSyncedStorage['kiwi_servicesInfo']?
      setObj_popupParcel.servicesInfo = defaultServicesInfo
      
    else
      setObj_popupParcel.servicesInfo = allItemsInSyncedStorage['kiwi_servicesInfo']
    
    
    
    
    
    if !allItemsInSyncedStorage['kiwi_alerts']?
    
      setObj_popupParcel.alerts = []
    else
      setObj_popupParcel.alerts = allItemsInSyncedStorage['kiwi_alerts']
      
    
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
    
    refreshBadge(servicesInfo, tempResponsesStore.services)
    
    if Object.keys(tempResponsesStore.services).length is numberOfActiveServices and numberOfActiveServices != 0
      
      chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
      
        # get a fresh copy of urls results and reset with updated info
        chrome.storage.local.get(null, (allItemsInLocalStorage) ->
          console.log 'trying to save all'
          
          if !allItemsInLocalStorage['kiwi_urlsResultsCache']?
            
            allItemsInLocalStorage['kiwi_urlsResultsCache'] = {}
          
          
          _save_url_results(allItemsInSyncedStorage['kiwi_servicesInfo'], tempResponsesStore, allItemsInLocalStorage['kiwi_urlsResultsCache'])
          
          
        )  
      )
      
      if popupOpen
        sendPopupParcel = true
      else
        sendPopupParcel = false
      
      _set_popupParcel(tempResponsesStore.services, responsePackage.forUrl, sendPopupParcel)

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
          
          if forUrl == preppedResult.url
            preppedResult.kiwi_exact_match = true
          else
            preppedResult.kiwi_exact_match = false
            
          preppedResult.kiwi_created_at = preppedResult.created_utc
          
          matchedListings.push preppedResult
      
    return matchedListings
      
    
  hackerNews: (resultsObj, forUrl) ->
    
    matchedListings = []
    
    if resultsObj.nbHits? and resultsObj.nbHits > 0 and resultsObj.hits? and resultsObj.hits.length is resultsObj.nbHits
      
      for hit in resultsObj.hits
        
        listingKeys = ["points","num_comments","objectID","author","created_at","title","url","created_at_i"]
        preppedResult = _.pick(hit, listingKeys)
        
        preppedResult.kiwi_created_at = preppedResult.created_at_i
        
        if forUrl == preppedResult.url
            preppedResult.kiwi_exact_match = true
          else
            preppedResult.kiwi_exact_match = false
        
        matchedListings.push preppedResult
      
    return matchedListings




refreshBadge = (servicesInfo, resultsObjForCurrentUrl) ->
  console.log 'yolo 8'
  console.debug resultsObjForCurrentUrl
  badgeText = ''
  # icon badges typically only have room for 5 characters
  
  currentTime = Date.now()
  
  updateCount = 0
  for service, index in servicesInfo
    if resultsObjForCurrentUrl[service.name]
      if resultsObjForCurrentUrl[service.name].service_PreppedResults.length > 0
        
        
        exactMatch = false
        noteworthy = false
        for listing in resultsObjForCurrentUrl[service.name].service_PreppedResults
          if listing.kiwi_exact_match
            exactMatch = true
            if listing.num_comments? and listing.num_comments >= service.conditionsForCaps.num_comments
              noteworthy = true
              break
              
            if (currentTime - listing.kiwi_created_at) < service.conditionsForCaps.hoursSincePosted * 3600000
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
    
    if !allItemsInLocalStorage.kiwi_urlsResultsCache? or Object.keys(allItemsInLocalStorage.kiwi_urlsResultsCache).length is 0
      console.log 'wtf ba'
      # nothing to (potentially) clean up!
      initialize_callback(tab, allItemsInLocalStorage)
      
    else
      console.log 'wtf bb'
      # allItemsInLocalStorage.kiwi_urlsResultsCache
      
      cull_kiwi_urlsResultsCache = _.extend {}, allItemsInLocalStorage.kiwi_urlsResultsCache
      
      for url, urlServiceResults of cull_kiwi_urlsResultsCache
        for serviceKey, serviceResults of urlServiceResults
          if currentTime - serviceResults.timestamp > checkForUrlHourInterval
            delete allItemsInLocalStorage.kiwi_urlsResultsCache[url]
      
      if Object.keys(allItemsInLocalStorage.kiwi_urlsResultsCache).length > maxUrlResultsStoredInLocalStorage
        
        # you've been surfing! wow
        
        num_results_to_delete = Object.keys(allItemsInLocalStorage.kiwi_urlsResultsCache).length - maxUrlResultsStoredInLocalStorage
        
        deletedCount = 0
        
        cull_kiwi_urlsResultsCache = _.extend {}, allItemsInLocalStorage.kiwi_urlsResultsCache
        
        for url, urlServiceResults of cull_kiwi_urlsResultsCache
          if deleteCount >= num_results_to_delete
            break
          
          if url != tab.url
            
            delete allItemsInLocalStorage.kiwi_urlsResultsCache[url]
            
            deletedCount++
        
        chrome.storage.local.set({'kiwi_urlsResultsCache':allItemsInLocalStorage.kiwi_urlsResultsCache}, ->
            
          initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
          
        )
      else
        initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
    
  else
    console.log 'wtf c'
    initialize_callback(tab, allItemsInLocalStorage, allItemsInSyncedStorage)
  

lastInitUrl = ''

initIfNewURL = ->
  
  console.log 'wtf 1'
  
  
  popupOpen = false
  
  
  # chrome.tabs.getSelected(null,(tab) ->
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) ->
    
    if tabs.length > 0 and tabs[0].url?
        
      if tabs[0].url.indexOf('chrome-devtools://') != 0
      
        tabUrl = tabs[0].url
        
      else if lastInitUrl != ''
        tabUrl = lastInitUrl
      
      else 
        console.log 'chrome-devtools:// has been the only url visited so far'
        return 0  
      
      if lastInitUrl != tabUrl
        lastInitUrl = tabUrl
        
        console.log 'popupParcel 123123'
        console.debug popupParcel
        
        updateBadgeText('')
        
        chrome.storage.sync.get(null, (allItemsInSyncedStorage) ->
          
          chrome.storage.local.get(null, (allItemsInLocalStorage) -> #useful for switching window contexts
            
            periodicCleanup(tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage, (tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage) ->
              
              console.log 'in initialize callback'
              
              if !allItemsInSyncedStorage['kiwi_userPreferences']?
                chrome.storage.sync.set({'kiwi_userPreferences':defaultUserPreferences}, ->
                  for urlSubstring in defaultUserPreferences.urlSubstring_blacklist
                    if tabUrl.indexOf(urlSubstring) != -1
                      # user is not interested in results for this url
                      return false
                )
              else
                for urlSubstring in allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklist
                  if tabUrl.indexOf(urlSubstring) != -1
                    # user is not interested in results for this url
                    return false
              
              if !allItemsInLocalStorage.persistentUrl? or allItemsInLocalStorage.persistentUrl != tabUrl
                
                chrome.storage.local.set({'persistentUrl': tabUrl}, ->)
                
              
              console.log 'wtf 3 ' + tabUrl
              if ( document.readyState != 'complete')
                
                currentUrl = tabUrl
                
                console.log 'wtf 3a'
                $(document).ready( -> 
                  
                  initialize(currentUrl)
                  
                )
                
              else
                console.log 'wtf 3b'
                
                initialize(tabUrl)
                 
            )
          )
        )
  )
  
  


chrome.tabs.onActivated.addListener( initIfNewURL )

chrome.tabs.onUpdated.addListener( initIfNewURL )

chrome.windows.onFocusChanged.addListener( initIfNewURL )





  






# cacheResults = (servicesCache, servicesFull, serviceName, currentTime, callback) ->
  
  
  # minimum markdown, clears after a day.
  
# cacheService = (servicesCache, servicesFull, serviceName, currentTime, callback) ->
#   if  !servicesCache[serviceName]?
#     servicesCache[serviceName] = {}
#     servicesCache[serviceName].canonicalTimestamp = currentTime
#     servicesCache[serviceName].canonical = {}
#     if servicesFull[serviceName].service.links?
#       servicesCache[serviceName].canonical.links = servicesFull[serviceName].service.links
#     if servicesFull[serviceName].service.twitter?
#       servicesCache[serviceName].canonical.twitter = servicesFull[serviceName].service.twitter
    
#     servicesCache[serviceName].decisionPoints = {}
#     servicesCache[serviceName].sharedTotalResults = []
    
#   else if ((currentTime - servicesCache[serviceName].canonicalTimestamp) < 86400000) # just refresh the canonical attributes
#     servicesCache[serviceName].canonicalTimestamp = currentTime
#     servicesCache[serviceName].canonical = {}
#     if servicesFull[serviceName].service.links?
#       servicesCache[serviceName].canonical.links = servicesFull[serviceName].service.links
#     if servicesFull[serviceName].service.twitter?
#       servicesCache[serviceName].canonical.twitter = servicesFull[serviceName].service.twitter
  
#   chrome.storage.local.set({'servicesCache': servicesCache}, ->
#     callback(servicesCache)
#   )

# clearServiceCache = (serviceName) ->
#   chrome.storage.local.get('servicesCache', (_r) ->
    
#     if !_r.servicesCache? or Object.keys(_r.servicesCache).length is 0 or !_r.servicesCache[serviceName]?
#       return false
#     else
#       delete _r.servicesCache[serviceName]
      
#       chrome.storage.local.set({'servicesCache': _r.servicesCache}, ->
#         chrome.tabs.getSelected(null,(tab) ->
#           setObj = {}
#           setObj.msg = 'popupParcel_ready'
#           setObj.forUrl = tabUrl
#           if popupParcel?
#             setObj.popupParcel = popupParcel
#             setObj.popupParcel.pointsToVoteOn = popupParcel.servicesFull[serviceName].service.pointsData
#             setObj.popupParcel.nullOrCachedServices = _r.servicesCache
#             popupParcel = setObj.popupParcel
#             sendParcel(setObj)
#         )
#       )
#   )  

# updateServicesIndex = (currentUrl) ->
  
#   timestamp = Date.now()
  
#   console.log 'in updateServicesIndex'
    
#   servicesIndex
    
#   $.ajax('', { success: (servicesIndex) ->
    
#     # console.log 'services json: remove from production'
#     # console.debug(servicesIndex);
    
    
#     serviceNamesArray = Object.keys(servicesIndex)
    
#     getVanity = (name) ->
#       fragments = name.split('-')
#       if fragments.length is 1
#         return fragments[0]
#       else
#         return fragments[fragments.length - 2]  
    
#     vanityHash = {}
    
#     for name in serviceNamesArray
#       vanityHash[getVanity(name)] = name
    
#     setObj = 
#       vanityHash: vanityHash
#       timestamp: timestamp
    
#     chrome.storage.local.set({'services': setObj}, (services) ->
      
#       reactor.dispatchEvent('deliverServiceResult', {'services':setObj,'forUrl':currentUrl})
      
#     )
    
#   })

# updateMainViewData = (pointsToVoteOn, nullOrCachedServices, servicesFull, serviceName, forUrl) -> 
  
#   popupParcel = 
#     'pointsToVoteOn': pointsToVoteOn
#     'nullOrCachedServices': nullOrCachedServices
#     'servicesFull': servicesFull
#     'serviceName': serviceName
  
  
#   if popupOpen
#     sendObj = 
#       'popupParcel': popupParcel 
#       'forUrl': forUrl
#       'msg':'popupParcel_ready'
    
#     sendParcel(sendObj)
    
#   else
    
#     refreshBadge(popupParcel)
    




  
# serviceMatchObj = {
#   # forUrl: 
#   # serviceMatch: <bool>
# }

  
    
    
# servicesReady = (servicesIndex, forUrl) ->
  
#     # before querying backend for fullService, check if service is in the servicesIndex and not in local storage)
#   currentTime = Date.now()
  
#   COMfrags = forUrl.split('.com') # until tosdr/eff explicitly say TOS apply to other TLDs (co.uk, .cn, etc - i'll only let a few in)
  
#   if forUrl.indexOf('wikipedia.org') != -1
#     COMfrags = forUrl.split('.org')
  
  
#   if COMfrags.length > 1
#     DOTfrags = COMfrags[COMfrags.length - 2].split('.')
    
#     domainPreTLD = DOTfrags[DOTfrags.length - 1]
#     protocolFRAGS = domainPreTLD.split('//')
#     domainName = protocolFRAGS[protocolFRAGS.length - 1]
#     # console.log 'console.log domainName'
#     # console.log domainName
    
#     if servicesIndex.vanityHash[domainName]?
      
#       serviceMatchObj =
#         forUrl: forUrl
#         serviceMatch: true
      
#       # chrome.storage.local.get(['servicesFull'], (servicesFullResult) ->
        
#       chrome.storage.local.get(null, (allItems) ->
        
#         # console.log 'before we update services'
#         # console.debug allItems
        
#         if allItems['servicesFull']?
          
#           if allItems['servicesFull'][servicesIndex.vanityHash[domainName]]? and 
#               (currentTime - allItems['servicesFull'][servicesIndex.vanityHash[domainName]].timestamp) < 22100000
#             serviceMatchObj =
#               forUrl: forUrl
#               serviceMatch: true
#             servicesIndexAndServicesFullReady(servicesIndex, allItems['servicesFull'], servicesIndex.vanityHash[domainName], forUrl)
            
#           else
            
#             updateService(allItems['servicesFull'], servicesIndex.vanityHash[domainName], forUrl, servicesIndexAndServicesFullReady, servicesIndex)
#         else
#           servicesFullObj = {}
#           updateService(servicesFullObj, servicesIndex.vanityHash[domainName], forUrl, servicesIndexAndServicesFullReady, servicesIndex)
#       )
      
#     else
      
#       serviceMatchObj =
#         forUrl: forUrl
#         serviceMatch: false  
      
#       if popupOpen
        
#         messageMainView_noServiceMatch(tabUrl)
        
#   else
      
#     serviceMatchObj =
#       forUrl: forUrl
#       serviceMatch: false  
    
#     if popupOpen
      
#       messageMainView_noServiceMatch(tabUrl)
      
      











# cacheUserVote = (userAgreedBool, serviceName, pointId) ->
#   currentTime = Date.now()
  
  
#   chrome.storage.local.get('servicesFull', (response) ->
    
#     if !response.servicesFull? or Object.keys(response.servicesFull).length is 0
#       return false
    
#     servicesFull = response.servicesFull
    
#     # console.log 'servicesFull[serviceName]?'
#     # console.log servicesFull[serviceName]?
#     # console.log 'servicesFull[serviceName].service.pointsData[pointId]?'
#     # console.log servicesFull[serviceName].service.pointsData[pointId]?
    
#     if servicesFull[serviceName]? and servicesFull[serviceName].service.pointsData[pointId]?
      
#       chrome.storage.local.get('servicesCache', (_r) ->
        
#         if !_r.servicesCache? or Object.keys(_r.servicesCache).length is 0 or !_r.servicesCache[serviceName]? or 
#             ((currentTime - _r.servicesCache[serviceName].canonicalTimestamp) < 86400000)
          
#           if !_r.servicesCache?
#             servicesCache = {}
#           else
#             servicesCache = _r.servicesCache
#           cacheService( servicesCache , servicesFull, serviceName, currentTime, (_servicesCache) ->
            
#             cacheDecisionPoint(_servicesCache, servicesFull, serviceName, userAgreedBool, pointId, currentTime, (__servicesCache, _serviceName, _pointId) ->
              
#               getPointsToVoteOn(servicesFull, serviceName, (pointsToVoteOn, nullOrCachedServices) ->
                
#                 setObj = {}
                
#                 setObj.msg = 'popupParcel_ready'
#                 setObj.forUrl = tabUrl
#                 setObj.popupParcel =
#                   'serviceName': _serviceName
#                   'pointId': _pointId
#                   'forUrl': tabUrl
#                   'servicesFull': servicesFull
#                   'pointsToVoteOn':pointsToVoteOn
#                   'nullOrCachedServices': nullOrCachedServices
                
#                 popupParcel = setObj.popupParcel
                
#                 sendParcel(setObj)
                
#               )
#             )
#           )
          
          
#         else
        
#           cacheDecisionPoint(_r.servicesCache, servicesFull, serviceName, userAgreedBool, pointId, currentTime, (__servicesCache, _serviceName, _pointId) ->
            
#             getPointsToVoteOn(servicesFull, serviceName, (pointsToVoteOn, nullOrCachedServices) ->
              
#               setObj = {}
              
#               setObj.msg = 'popupParcel_ready'
#               setObj.forUrl = tabUrl
#               setObj.popupParcel =
#                 'serviceName': _serviceName
#                 'pointId': _pointId
#                 'forUrl': tabUrl
#                 'servicesFull': servicesFull
#                 'pointsToVoteOn':pointsToVoteOn
#                 'nullOrCachedServices': nullOrCachedServices
              
#               popupParcel = setObj.popupParcel
              
#               sendParcel(setObj)
#             )
#           )
#       )

#   )

# getPointsToVoteOn = (servicesFull, serviceName, callback) ->
  
#   service = servicesFull[serviceName].service
  
#   serviceApiPointsObject = _.extend {}, service.pointsData
  
#   chrome.storage.local.get('servicesCache', (response) ->
    
#     apiPointIds = Object.keys(servicesFull[serviceName].service.pointsData)
#     # console.log 'console.debug apiPointIds'
#     # console.debug apiPointIds
#     if response.servicesCache?
      
#       if response.servicesCache[serviceName]?
#         # console.log 'console.debug Object.keys(response.servicesCache[serviceName].decisionPoints)'
#         # console.debug Object.keys(response.servicesCache[serviceName].decisionPoints)
        
#         for pointId, decisionPoint of response.servicesCache[serviceName].decisionPoints
          
#           if pointId in apiPointIds
            
#             if checkIfCurrentVersionOfApiServicePointIsInServicesCache(serviceApiPointsObject, response.servicesCache[serviceName].decisionPoints, pointId)
              
#               delete serviceApiPointsObject[pointId]
              
#         callback(serviceApiPointsObject, response.servicesCache)
        
#       else
        
#         callback(serviceApiPointsObject, response.servicesCache)
        
#     else
#       callback(serviceApiPointsObject, null)
#   )

# checkIfCurrentVersionOfApiServicePointIsInServicesCache = (serviceApiPointsObject, cachedPoints, pointId) ->
#   # console.log 'serviceApiPointsObject'
#   # console.debug serviceApiPointsObject
  
#   # console.log 'console.debug cachedPoints'
#   # console.debug cachedPoints
  
#   _i = cachedPoints[pointId].length - 1
  
#     # meta check
#   if serviceApiPointsObject[pointId].meta? or cachedPoints[pointId][_i].canonical.meta?
#     if serviceApiPointsObject[pointId].meta? and cachedPoints[pointId][_i].canonical.meta?
#       if !_.isEqual(serviceApiPointsObject[pointId].meta, cachedPoints[pointId][_i].canonical.meta)
#         return false
#     else
#       return false
    
#     # source check
#   if serviceApiPointsObject[pointId].source? or cachedPoints[pointId][_i].canonical.source?
#     if serviceApiPointsObject[pointId].source? and cachedPoints[pointId][_i].canonical.source?
#       if !_.isEqual(serviceApiPointsObject[pointId].source, cachedPoints[pointId][_i].canonical.source)
#         return false
#     else
#       return false
    
#     # title check
#   if serviceApiPointsObject[pointId].title? or cachedPoints[pointId][_i].canonical.title?
#     if serviceApiPointsObject[pointId].title? and cachedPoints[pointId][_i].canonical.title?
#       if !_.isEqual(serviceApiPointsObject[pointId].title, cachedPoints[pointId][_i].canonical.title)
#         return false
#     else
#       return false
#   else if !cachedPoints[pointId][_i].canonical.title?
#     return false
    
#   if serviceApiPointsObject[pointId].tosdr.tldr? or cachedPoints[pointId][_i].canonical.tldr?
#     if serviceApiPointsObject[pointId].tosdr.tldr? and cachedPoints[pointId][_i].canonical.tldr?
#       if !_.isEqual(serviceApiPointsObject[pointId].tosdr.tldr, cachedPoints[pointId][_i].canonical.tldr)
#         return false
#     else
#       return false
#   else if !cachedPoints[pointId][_i].canonical.tldr?
#     return false
  
#   return true



# servicesIndexAndServicesFullReady = (servicesIndex, servicesFull, serviceName, forUrl) ->
  
#     # get votingHashObject for this service
  
#   # console.log 'in servicesIndexAndServicesFullReady'
#   # console.log 'console.debug servicesFull'
#   # console.debug servicesFull
  
  
#   if servicesFull[serviceName]?
#     serviceMatchObj =
#       forUrl: forUrl
#       serviceMatch: true
    
#     getPointsToVoteOn( servicesFull, serviceName, (pointsToVoteOn, nullOrCachedServices ) ->
        
        
#         # to prevent queries from previous tabs from mixing in with current tab
#       if forUrl is tabUrl
        
#         # console.log 'console.debug servicesIndex'
#         # console.debug servicesIndex
#         # console.log 'console.debug servicesFull'
#         # console.debug servicesFull
#         # console.log 'console.debug serviceName'
#         # console.debug serviceName
#         # console.log 'console.debug forUrl'
#         # console.debug forUrl
#         # console.log 'console.debug pointsToVoteOn'
#         # console.debug pointsToVoteOn
        
#         updateMainViewData(pointsToVoteOn, nullOrCachedServices, servicesFull, serviceName, forUrl)
        
#     )
  
#   else
#     serviceMatchObj =
#       forUrl: forUrl
#       serviceMatch: false
  

# messageMainView_noServiceMatch = (forUrl) ->
#   sendObj = 
#     'forUrl': forUrl
#     'msg':'noServiceMatch'
    
#   sendParcel(sendObj)


# cacheDecisionPoint = (servicesCache, servicesFull, serviceName, userAgreedBool, pointId, currentTime, callback) ->
  
#   if servicesCache[serviceName]? and servicesFull[serviceName]? and servicesFull[serviceName].service.pointsData[pointId]?
    
#     if !servicesCache[serviceName].decisionPoints[pointId]?
      
#       servicesCache[serviceName].decisionPoints[pointId] = []
    
#     rawPointData = servicesFull[serviceName].service.pointsData[pointId]
    
#     canonical = 
#       id: pointId
#       title: rawPointData.title
    
#     if rawPointData.tosdr? and rawPointData.tosdr.tldr?
#       canonical['tldr'] = rawPointData.tosdr.tldr
    
#     if rawPointData.meta?
#       canonical['meta'] = rawPointData.meta
      
#     if rawPointData.source?
#       canonical.source = rawPointData.source
    
#     if rawPointData.discussion?
#       canonical.discussion = rawPointData.discussion
    
#     setObj =
#       'canonical': canonical
#       'timestamp': currentTime
#       'voteAgree': userAgreedBool
#       'deleted': false
#       'shared': []
    
#     servicesCache[serviceName].decisionPoints[pointId].push setObj
    
#     chrome.storage.local.set({'servicesCache': servicesCache}, ->
      
#       callback(servicesCache, serviceName, pointId)
      
#     )


# updateServicesIndex = (currentUrl) ->
  
#   timestamp = Date.now()
  
  
#   # console.log 'in updateServicesIndex'
#   $.ajax('https://tosdr.org/index/services.json', { success: (servicesIndex) ->
#     # console.log 'services json: remove from production'
#     # console.debug(servicesIndex);
    
#      # fixing imperfect naming convention implementations
#     if servicesIndex['world-of-warcraft']?
#         # not a proper domain name
#       delete servicesIndex['world-of-warcraft']
    
#     if servicesIndex['microsoft-store']?
#         # not a proper domain name
#       servicesIndex['microsoftstore'] = servicesIndex['microsoft-store']
#       delete servicesIndex['microsoft-store']
    
#     if servicesIndex['apple-icloud']?
#         # not a proper domain name
#       servicesIndex['icloud'] = servicesIndex['apple-icloud']
#       delete servicesIndex['apple-icloud']
      
#     if servicesIndex['mint.com']?
#         # not a proper domain name
#       servicesIndex['mint'] = servicesIndex['mint.com']
#       delete servicesIndex['mint.com']
      
#     serviceNamesArray = Object.keys(servicesIndex)
    
#     getVanity = (name) ->
#       fragments = name.split('-')
#       if fragments.length is 1
#         return fragments[0]
#       else
#         return fragments[fragments.length - 2]  
    
#     vanityHash = {}
    
#     for name in serviceNamesArray
#       vanityHash[getVanity(name)] = name
    
#     setObj = 
#       vanityHash: vanityHash
#       timestamp: timestamp
    
#     chrome.storage.local.set({'services': setObj}, (services) ->
      
#       reactor.dispatchEvent('deliverServices', {'services':setObj,'forUrl':currentUrl})
      
#     )
    
#   }) 