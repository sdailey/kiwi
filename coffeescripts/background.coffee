
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

kiwi_userMessages = {
  "redditDown":
    "baseValue":"reddit's API is unavailable, so results may not appear from this service for some time"
    "name":"redditDown"
    "sentAndAcknowledgedInstanceObjects": []
      # {
      #   "sentTimestamp"
      #   "userAcknowledged": <timestamp>
      #   "urgencyLevel"
      # } ...
  "productHuntDown":
    "name":"productHuntDown"
    "baseValue":"Product Hunt's API has not been consistently available, so results may not reliably appear from this service."
    "sentAndAcknowledgedInstanceObjects": []
    
  "productHuntDown__customSearch":
    "name":"productHuntDown__customSearch"
    "baseValue":"Product Hunt's custom search API has not been consistently available, so results may not reliably appear from this service."
    "sentAndAcknowledgedInstanceObjects": []
      # {
      #   "timestamp"
      #   "userAcknowledged": <timestamp>
      #   "urgencyLevel"
      # } ...
      # {
      #   "timestamp"
      #   "userAcknowledged": <timestamp>
      #   "urgencyLevel"
      # } ...
      
  "hackerNewsDown":
    "name":"hackerNewsDown"
    "baseValue":"Hacker News' API has not been consistently available, so results may not reliably appear from this service."
    "sentAndAcknowledgedInstanceObjects": []
      # {
      #   "timestamp"
      #   "userAcknowledged": <timestamp>
      #   "urgencyLevel"
      # } ...
      
  "generalConnectionFailure":
    "name":"generalConnectionFailure"
    "baseValue":"There has been a network connection issue. Check your internet connection / try again in a few minutes :)"
    "sentAndAcknowledgedInstanceObjects": []
  
  
}

kiwi_autoOffClearInterval = null

kiwi_reddit_token_refresh_interval = null
  # timestamp: 
  # intervalId: 
  
kiwi_productHunt_token_refresh_interval = null
  # timestamp: 
  # intervalId:   

tempResponsesStore = {}
  # forUrl: < url >
  # results: 
    # < serviceName > :
    #   timestamp:
    #   service_PreppedResults:
    #   forUrl: url

popupParcel = {}
# proactively set if each services' preppedResults are ready.
  # will be set with available results if queried by popup.
  # {
    # forUrl:
    # allPreppedResults:
    # kiwi_servicesInfo:
    # kiwi_customSearchResults:
    # kiwi_alerts:
    # kiwi_userPreferences:
    # kiwi_unackedUserMessages:
      # unacknowledged user messages
  # }

# tlds = [
#   '.com','.fr','.de','.co.uk',
#   '.net','.int','.edu','.gov','.mil','.co','.io',
#   '.au','.br','.cn','.dk','.es','.fi','.gb','.gr','.hk','.in','.it','.is','.jp','.ke','.no','.nl','.vn'
# ]

defaultUserPreferences = {
  
  fontSize: .8
  researchModeOnOff: 'off'
  autoOffAtUTCmilliTimestamp: null
  autoOffTimerType: 'always' # 'custom','always','20','60'
  autoOffTimerValue: null
  
  installedTime: Date.now()
  
  sortByPref: 'attention' # 'recency'   # "attention" means 'comments' if story, 'points' if comment, 'clusterUrl' if news
    
  urlSubstring_whitelists:
    anyMatch: []
    beginsWith: []
    endingIn: []
    unless: [
      # ['twitter.com/','/status/'] # unless /status/
    ]
  
    # suggested values to all users  -- any can be overriden with the "Research this URL" button
      # unfortunately, because of Chrome's discouragement of storing sensitive 
      # user info with browser.storage, blacklists are fixed for now . see: https://news.ycombinator.com/item?id=9993030
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
      
      '/wp-admin'
      
      'chrome://'
      'chrome-extension://'
      
      'chrome-devtools://'  # hardcoded block
    ]
    beginsWith: [
      "about:"
      'chrome://'
    ]
    endingIn: [
      # - ending in: # (or with '/' at end)
      'youtube.com' 
    ]
    unless: [
      ['twitter.com/','/status/'] # unless /status/    # so that people checking their homepage doesn't count 
    ] 
}

defaultServicesInfo = [
    
    name:"hackerNews"
    title: "Hacker News"
    abbreviation: "H"
    
    queryApi:"https://hn.algolia.com/api/v1/search?restrictSearchableAttributes=url&query="
    
    broughtToYouByTitle:"Algolia Hacker News API"
    broughtToYouByURL:"https://hn.algolia.com/api"
    
    brandingImage: null
    brandingSlogan: null
    
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
    customSearchBroughtToYouByURL: null
    customSearchBroughtToYouByTitle: null
    
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
    
    conversationSite: true
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
      # author_<name>,(story,poll)   filters on author=<name> AND (type=story OR type=poll).
    
  ,
  
    name:"reddit"
    title: "reddit"
    abbreviation: "R"
    
    queryApi:"https://www.reddit.com/submit.json?url="
    
    
    broughtToYouByTitle:"Reddit API"
    
    broughtToYouByURL:"https://github.com/reddit/reddit/wiki/API"
    
    brandingImage: null
    brandingSlogan: null
    
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
    customSearchBroughtToYouByURL: null
    customSearchBroughtToYouByTitle: null
    
    conversationSite: true
  ,
  
    name:"productHunt"
    title: "Product Hunt"
    abbreviation: "P"
    
    queryApi:"https://api.producthunt.com/v1/posts/all?search[url]="
    
    broughtToYouByTitle:"Product Hunt API"
    
    broughtToYouByURL:"https://github.com/producthunt/producthunt-api/wiki/Product-Hunt-APIs"
    
    brandingImage: "product-hunt-logo-orange-240.png"
    brandingSlogan: null
    
    permalinkBase: 'https://producthunt.com/'
    
    userPageBaselink: 'https://www.producthunt.com/@'
    
    submitTitle: 'Be the first to submit to Product Hunt!'
    submitUrl: 'https://www.producthunt.com/tech/new'
    
    active: 'on'
    
    notableConditions:
      hoursSincePosted: 4 # an exact match is less than 5 hours old
      num_comments: 10   # an exact match has 30 comments
      
      # 'featured'
      
      
    updateBadgeOnlyWithExactMatch: true
    
      # uses Algolia index, not a typical rest api
    customSearchApi: ""
    customSearchTags: {}
    customSearchBroughtToYouByURL: "https://www.algolia.com/doc/javascript"
    customSearchBroughtToYouByTitle: "Algolia's Search API"
    
    conversationSite: true
  ,
    name:"gnews"
    title: "Google News"
    abbreviation: "G"
    
    broughtToYouByTitle:"Google News Search"
    
    broughtToYouByURL:"https://developers.google.com/news-search/v1/devguide"
    
    brandingImage: null
    brandingSlogan: "powered by Google"
    
    conversationSite: false
    
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
    
    customSearchBroughtToYouByURL: null
    customSearchBroughtToYouByTitle: null
    
    conversationSite: false
    
  # {
  #  < so many great communities out there! ping me @spencenow if an API surfaces. 
    # 2015-8-13 - producthunt has been implemented! holy crap this is cool! :D
  # },
  
]


send_kiwi_userMessage = (messageName, urgencyLevel, extraNote = null) ->
  
  currentTime = Date.now()
  sendMessageBool = true
  
  # messageName
  
  # if the same message has been sent in last five minutes, don't worry.
  
  messageObj = kiwi_userMessages[messageName]
  for sentInstance in messageObj.sentAndAcknowledgedInstanceObjects
    if sentInstance.userAcknowledged? and (currentTime - sentInstance.userAcknowledged < 1000 * 60 * 20)
      sendMessageBool = false
      
    else if !sentInstance.userAcknowledged?
      sendMessageBool = false
      
  
  if sendMessageBool is true
    
    
    kiwi_userMessages[messageName].sentAndAcknowledgedInstanceObjects.push {
      "sentTimestamp": currentTime
      "userAcknowledged": null # <timestamp>
    }
    
    if kiwi_urlsResultsCache[tabUrl]?
      
      _set_popupParcel(kiwi_urlsResultsCache[tabUrl], tabUrl, true)
        
    else if tempResponsesStore? and tempResponsesStore.forUrl == tabUrl        
      _set_popupParcel(tempResponsesStore.services, tabUrl, true)
      
    else
      _set_popupParcel({}, tabUrl, true)
    
    # # kiwi_userMessages = {
    # #   "redditDown":
    # #     "baseValue":"reddit's API is unavailable, so results may not appear from this service for some time"
    # #     "sentAndAcknowledgedInstanceObjects": []
    # #       # {
    # #       #   "sentTimestamp"
    # #       #   "userAcknowledged": null # <timestamp>
    # #       # } ...
    
    # # popupParcel = {}
    # # # proactively set if each services' preppedResults are ready.
    # #   # will be set with available results if queried by popup.
    # #   # {
    # #     # forUrl:
    # #     # allPreppedResults:
    # #     # kiwi_servicesInfo:
    # #     # kiwi_customSearchResults:
    # #     # kiwi_alerts:
    # #     # kiwi_userPreferences:
    # #     # kiwi_unackedUserMessages:
    
    # #       # unacknowledged user messages
    # #   # }
    
    # for messageName, messageObj of kiwi_userMessages
    #   for sentInstance in sentAndAcknowledgedInstanceObjects
    #     if sentInstance.userAcknowledged is null
    #       setObj_popupParcel.kiwi_userMessages.push messageObj
  
getRandom = (min, max) ->
  return min + Math.floor(Math.random() * (max - min + 1))


shuffle_array = (array) ->
  currentIndex = array.length;

  # // While there remain elements to shuffle...
  while (0 != currentIndex) 

    # // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    # // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  

  return array

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

temp__kiwi_reddit_oauth =
  token: null
  token_type: null
  token_lifespan_timestamp: null
  client_id: "" # your client id here
  device_id: randomishDeviceId()

temp__kiwi_productHunt_oauth =
  token: null
  token_type: null
  token_lifespan_timestamp: null
  
  client_id: "" # your client id here
  client_secret: "" # your secret id here

randomizeDefaultConversationSiteOrder = ->
  conversationSiteServices = []
  nonConversationSiteServices = []
  
  
  for service in defaultServicesInfo
    if service.conversationSite
      conversationSiteServices.push service
    else
      nonConversationSiteServices.push service
  
  newDefaultServices = []
  
  conversationSiteServices = shuffle_array(conversationSiteServices)
  defaultServicesInfo = conversationSiteServices.concat(nonConversationSiteServices)

randomizeDefaultConversationSiteOrder()

# ~~~ starting out with negotiating oAuth tokens and initializing necessary api objects ~~~ # 

setTimeout_forProductHuntRefresh = (token_timestamp, kiwi_productHunt_oauth, ignoreTimeoutDelayComparison = false) ->
  currentTime = Date.now()
  
  timeoutDelay = token_timestamp - currentTime
  
  if kiwi_productHunt_token_refresh_interval? and kiwi_productHunt_token_refresh_interval.timestamp? and ignoreTimeoutDelayComparison is false
    if timeoutDelay > kiwi_productHunt_token_refresh_interval.timestamp - currentTime
      # console.log 'patience, we will be trying again soon'
      return 0
      
  if kiwi_productHunt_token_refresh_interval? and kiwi_productHunt_token_refresh_interval.timestamp?
    clearTimeout(kiwi_productHunt_token_refresh_interval.intervalId)
  
  
  timeoutIntervalId = setTimeout( -> 
      requestProductHuntOauthToken(kiwi_productHunt_oauth)
    , timeoutDelay )
  
  kiwi_productHunt_token_refresh_interval =
    timestamp: token_timestamp
    intervalId: timeoutIntervalId

setTimeout_forRedditRefresh = (token_timestamp, kiwi_reddit_oauth, ignoreTimeoutDelayComparison = false) ->
  currentTime = Date.now()
  
  timeoutDelay = token_timestamp - currentTime
  
  if kiwi_reddit_token_refresh_interval? and kiwi_reddit_token_refresh_interval.timestamp? and ignoreTimeoutDelayComparison is false
    if timeoutDelay > kiwi_reddit_token_refresh_interval.timestamp - currentTime
      # console.log 'patience, we will be trying again soon'
      return 0
  
  if kiwi_reddit_token_refresh_interval? and kiwi_reddit_token_refresh_interval.timestamp?
    clearTimeout(kiwi_reddit_token_refresh_interval.intervalId)
  
  timeoutIntervalId = setTimeout( -> 
      requestRedditOathToken(kiwi_reddit_oauth)
    , timeoutDelay )
  
  kiwi_reddit_token_refresh_interval =
    timestamp: token_timestamp
    intervalId: timeoutIntervalId  

requestRedditOathToken = (kiwi_reddit_oauth) ->
  # console.log 'trying'
  currentTime = Date.now()
  queryObj = 
    type: "POST"
    
    data: {
      grant_type: "https://oauth.reddit.com/grants/installed_client"
      device_id: kiwi_reddit_oauth.device_id
    }
    
    url: 'https://www.reddit.com/api/v1/access_token'
    
    statusCode:
      0: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forRedditRefresh(tryAgainTimestamp, kiwi_reddit_oauth)
        send_kiwi_userMessage("redditDown")
        console.log('unavailable!2')
      
      504: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forRedditRefresh(tryAgainTimestamp, kiwi_reddit_oauth)
        send_kiwi_userMessage("redditDown")
        console.log('unavailable!2')
        
      503: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forRedditRefresh(tryAgainTimestamp, kiwi_reddit_oauth)
        send_kiwi_userMessage("redditDown")
        console.log('unavailable!2')
      502: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forRedditRefresh(tryAgainTimestamp, kiwi_reddit_oauth)
        send_kiwi_userMessage("redditDown")
        console.log('Fail!2')
      401: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forRedditRefresh(tryAgainTimestamp, kiwi_reddit_oauth)
        send_kiwi_userMessage("redditDown")
        console.log('unauthenticated2')
    
    headers: { 
      'Authorization':    'Basic ' + btoa(kiwi_reddit_oauth.client_id + ":") 
      'Content-Type':     'application/x-www-form-urlencoded'
      'X-Requested-With': 'csrf suck it ' + getRandom(1,10000000)
    }
    cache: false
    async: true
    success: (data) ->
      if data.access_token? and data.expires_in? and data.token_type == "bearer"
        # console.log 'response from reddit!'
        # console.debug data
        
        token_lifespan_timestamp = currentTime + data.expires_in * 1000
        setObj = {}
        setObj['kiwi_reddit_oauth'] =
          token: data.access_token
          token_type: 'bearer'
          token_lifespan_timestamp: token_lifespan_timestamp
          client_id: kiwi_reddit_oauth.client_id
          device_id: kiwi_reddit_oauth.device_id
        
        browser.storage.local.set(setObj, (data) ->
          
          setTimeout_forRedditRefresh(token_lifespan_timestamp, setObj.kiwi_reddit_oauth, true)
          
        )
        
    fail: (data) ->
      # console.log 'reddit failed to authenticate client, try again in 5 min'
      tryAgainTimestamp = currentTime + (1000 * 60 * 3)
      setTimeout_forRedditRefresh(tryAgainTimestamp, kiwi_reddit_oauth)
      send_kiwi_userMessage("generalConnectionFailure")
      # console.log('unauthenticated')
      
  $.ajax( queryObj )

requestProductHuntOauthToken = (kiwi_productHunt_oauth) ->
  currentTime = Date.now()
  queryObj = 
    
    type: "POST"
    
    data: {
      "client_id": kiwi_productHunt_oauth.client_id
      "client_secret": kiwi_productHunt_oauth.client_secret
      "grant_type" : "client_credentials"
    }
    
    statusCode:
      0: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forProductHuntRefresh(tryAgainTimestamp, kiwi_productHunt_oauth)
        send_kiwi_userMessage("productHuntDown")
        console.log('unavailable!3')
      504: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forProductHuntRefresh(tryAgainTimestamp, kiwi_productHunt_oauth)
        send_kiwi_userMessage("productHuntDown")
        console.log('unavailable!3')
      
      503: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forProductHuntRefresh(tryAgainTimestamp, kiwi_productHunt_oauth)
        send_kiwi_userMessage("productHuntDown")
        console.log('unavailable!3')
      502: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forProductHuntRefresh(tryAgainTimestamp, kiwi_productHunt_oauth)
        send_kiwi_userMessage("productHuntDown")
        console.log('Fail!3')
      401: ->
        tryAgainTimestamp = currentTime + (1000 * 60 * 3)
        setTimeout_forProductHuntRefresh(tryAgainTimestamp, kiwi_productHunt_oauth)
        send_kiwi_userMessage("productHuntDown")
        console.log('unauthenticated3')
          
    
    url: 'https://api.producthunt.com/v1/oauth/token'
    headers: {}
    cache: false
    # async: true
    complete: (data) ->
      
      # console.log 'yaya PH here'
      # console.debug data
      
      if data.responseJSON? and data.responseJSON.access_token? and data.responseJSON.expires_in? and data.responseJSON.token_type == "bearer"
        
        token_lifespan_timestamp = currentTime + data.responseJSON.expires_in * 1000
        setObj = {}
        setObj['kiwi_productHunt_oauth'] =
          token: data.responseJSON.access_token
          scope: "public"
          token_type: 'bearer'
          token_lifespan_timestamp: token_lifespan_timestamp
          client_id: kiwi_productHunt_oauth.client_id
          client_secret: kiwi_productHunt_oauth.client_secret
        
        browser.storage.local.set(setObj, (_data) ->
          # console.log ' set product hunt oauth'
          setTimeout_forProductHuntRefresh(token_lifespan_timestamp, setObj.kiwi_productHunt_oauth, true)
          
        )
        
    fail: (data) ->
      # console.log 'product hunt failed to authenticate client, try again in 3 min'
      tryAgainTimestamp = currentTime + (1000 * 60 * 3)
      send_kiwi_userMessage("generalConnectionFailure")
      setTimeout_forProductHuntRefresh(tryAgainTimestamp, kiwi_productHunt_oauth)
      
  $.ajax( queryObj )

# authenticate with Reddit's OAUTH2, so we can be a good webizen
browser.storage.local.get(null, (allItemsInLocalStorage) ->
  currentTime = Date.now()
  
  # console.log ' trying yo ' 
    
  if !allItemsInLocalStorage.kiwi_productHunt_oauth? or !allItemsInLocalStorage.kiwi_productHunt_oauth.token?
    # console.log 'ph oauth does not exist in localStorage'
    
    requestProductHuntOauthToken(temp__kiwi_productHunt_oauth)
  
  if !allItemsInLocalStorage.kiwi_productHunt_oauth? or !allItemsInLocalStorage.kiwi_productHunt_oauth.token?
    # do nothing
    
  else if (allItemsInLocalStorage.kiwi_productHunt_oauth.token_lifespan_timestamp? and 
      currentTime > allItemsInLocalStorage.kiwi_productHunt_oauth.token_lifespan_timestamp) or
      !allItemsInLocalStorage.kiwi_productHunt_oauth.token_lifespan_timestamp?
    
    #console.log "3 setObj['kiwi_productHunt_oauth'] ="
    
    requestProductHuntOauthToken(temp__kiwi_productHunt_oauth)
    
  else if allItemsInLocalStorage.kiwi_productHunt_oauth.token_lifespan_timestamp? and allItemsInLocalStorage.kiwi_productHunt_oauth?
    
    #console.log "4 setObj['kiwi_productHunt_oauth'] ="
    
    token_timestamp = allItemsInLocalStorage.kiwi_productHunt_oauth.token_lifespan_timestamp
    
    if !kiwi_productHunt_token_refresh_interval? or kiwi_productHunt_token_refresh_interval.timestamp != token_timestamp
      
      setTimeout_forProductHuntRefresh(token_timestamp, allItemsInLocalStorage.kiwi_productHunt_oauth)
    
  if !allItemsInLocalStorage.kiwi_reddit_oauth? or !allItemsInLocalStorage.kiwi_reddit_oauth.token?
    
    requestRedditOathToken(temp__kiwi_reddit_oauth)
  
  if !allItemsInLocalStorage.kiwi_reddit_oauth? or !allItemsInLocalStorage.kiwi_reddit_oauth.token?
    
    # do nothing
    
  else if (allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp? and 
      currentTime > allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp) or
      !allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp?
    
    #console.log "3 setObj['kiwi_reddit_oauth'] ="
    
    requestRedditOathToken(temp__kiwi_reddit_oauth)
    
  else if allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp? and allItemsInLocalStorage.kiwi_reddit_oauth?
    
    #console.log "4 setObj['kiwi_reddit_oauth'] ="
    
    token_timestamp = allItemsInLocalStorage.kiwi_reddit_oauth.token_lifespan_timestamp
    
    if !kiwi_reddit_token_refresh_interval? or kiwi_reddit_token_refresh_interval.timestamp != token_timestamp
      
      setTimeout_forRedditRefresh(token_timestamp, allItemsInLocalStorage.kiwi_reddit_oauth)
)





# go ahead and start to load search api for GNews
if google? 
  google.load('search', '1');


newsSearch = null

onGoogleLoad = ->
  newsSearch = new google.search.NewsSearch();
  newsSearch.setNoHtmlGeneration();

google.setOnLoadCallback(onGoogleLoad);



is_url_blocked = (blockedLists, url) ->
  return doesURLmatchSubstringLists(blockedLists, url)

is_url_whitelisted = (whiteLists, url) ->
  return doesURLmatchSubstringLists(whiteLists, url)


doesURLmatchSubstringLists = (urlSubstringLists, url) ->
  if urlSubstringLists.anyMatch?
    for urlSubstring in urlSubstringLists.anyMatch
      if url.indexOf(urlSubstring) != -1
        return true
  
  if urlSubstringLists.beginsWith?
    for urlSubstring in urlSubstringLists.beginsWith
      if url.indexOf(urlSubstring) == 0
        return true
  
  if urlSubstringLists.endingIn?
    for urlSubstring in urlSubstringLists.endingIn
      if url.indexOf(urlSubstring) == url.length - urlSubstring.length
        return true
        
      urlSubstring += '/'
      if url.indexOf(urlSubstring) == url.length - urlSubstring.length
        return true
    
  if urlSubstringLists.unless?
    for urlSubstringArray in urlSubstringLists.unless
      if url.indexOf(urlSubstringArray[0]) != -1
        
        if url.indexOf(urlSubstringArray[1]) == -1
          return true
  
  return false
    

# lastQueryTimestamp # to throttle




returnNumberOfActiveServices = (servicesInfo) ->
  
  numberOfActiveServices = 0
  for service in servicesInfo
    if service.active == 'on'
      numberOfActiveServices++
  return numberOfActiveServices

sendParcel = (parcel) ->
  outPort = browser.runtime.connect({name: "kiwi_fromBackgroundToPopup"})
  
  if !parcel.msg? or !parcel.forUrl?
    return false
  
  switch parcel.msg
    when 'kiwiPP_popupParcel_ready'
      
      outPort.postMessage(parcel)
      
    
    
_save_a_la_carte = (parcel) ->
  
  setObj = {}
  setObj[parcel.keyName] = parcel.newValue
  
  browser.storage[parcel.localOrSync].set(setObj, (data) ->
    if !tempResponsesStore? or !tempResponsesStore.services?
      tempResponsesStoreServices = {}
    else
      tempResponsesStoreServices = tempResponsesStore.services
    if parcel.refreshView?
      _set_popupParcel(tempResponsesStoreServices, tabUrl, true, parcel.refreshView)
    else
      _set_popupParcel(tempResponsesStoreServices, tabUrl, false)
  )


browser.runtime.onConnect.addListener((port) ->
  if port.name is 'kiwi_fromBackgroundToPopup'
    popupOpen = true
    
    port.onMessage.addListener( (dataFromPopup) ->
      
      if !dataFromPopup.msg?
        return false
      
      switch dataFromPopup.msg
        
        when 'kiwiPP_acknowledgeMessage'
          
          currentTime = Date.now()
          
          for sentInstance, index in kiwi_userMessages[dataFromPopup.messageToAcknowledge].sentAndAcknowledgedInstanceObjects
            if !sentInstance.userAcknowledged?
              kiwi_userMessages[dataFromPopup.messageToAcknowledge].sentAndAcknowledgedInstanceObjects[index] = currentTime
              
          if kiwi_urlsResultsCache[tabUrl]?
      
            _set_popupParcel(kiwi_urlsResultsCache[tabUrl], tabUrl, true)
              
          else if tempResponsesStore? and tempResponsesStore.forUrl == tabUrl        
            _set_popupParcel(tempResponsesStore.services, tabUrl, true)
            
          else
            _set_popupParcel({}, tabUrl, true)
          
        when 'kiwiPP_post_customSearch'
          # console.log 'when kiwiPP_post_customSearch1'
          # console.debug dataFromPopup
          # dataFromPopup.servicesToSearch
          
          if dataFromPopup.customSearchRequest? and dataFromPopup.customSearchRequest.queryString? and
              dataFromPopup.customSearchRequest.queryString != ''
            
            browser.storage.sync.get(null, (allItemsInSyncedStorage) -> 
              
              if allItemsInSyncedStorage['kiwi_servicesInfo']?
                #console.log 'when kiwiPP_post_customSearch3'
                for serviceInfoObject in allItemsInSyncedStorage['kiwi_servicesInfo']
                  
                  #console.log 'when kiwiPP_post_customSearch4 for ' + serviceInfoObject.name
                  if dataFromPopup.customSearchRequest.servicesToSearch[serviceInfoObject.name]?
                    
                    if serviceInfoObject.name is 'gnews'
                      dispatchGnewsQuery__customSearch(dataFromPopup.customSearchRequest.queryString, dataFromPopup.customSearchRequest.servicesToSearch, serviceInfoObject, allItemsInSyncedStorage['kiwi_servicesInfo'])
                    else if serviceInfoObject.name is 'productHunt'
                      dispatchProductHuntQuery__customSearch(dataFromPopup.customSearchRequest.queryString, dataFromPopup.customSearchRequest.servicesToSearch, serviceInfoObject, allItemsInSyncedStorage['kiwi_servicesInfo'])
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
          # console.log "when 'kiwiPP_post_save_a_la_carte'"
          _save_a_la_carte(dataFromPopup)    
        
        when 'kiwiPP_post_savePopupParcel'
          #console.log "when 'kiwiPP_post_savePopupParcel'"
          
          
          _save_from_popupParcel(dataFromPopup.newPopupParcel, dataFromPopup.forUrl, dataFromPopup.refreshView)
          
          if kiwi_urlsResultsCache[tabUrl]?
            
            refreshBadge(dataFromPopup.newPopupParcel.kiwi_servicesInfo, kiwi_urlsResultsCache[tabUrl])
          
          
        when 'kiwiPP_request_popupParcel'
          
          if dataFromPopup.forUrl is tabUrl
            
            preppedResponsesInPopupParcel = 0
            if popupParcel? and popupParcel.allPreppedResults? 
              
              for serviceName, service of popupParcel.allPreppedResults
                if service.service_PreppedResults?
                  preppedResponsesInPopupParcel += service.service_PreppedResults.length
            
            preppedResponsesInTempResponsesStore = 0
            if tempResponsesStore? and tempResponsesStore.services? 
              
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
              
              if !tempResponsesStore.services? or tempResponsesStore.forUrl != tabUrl
                _set_popupParcel({}, tabUrl, true)
              else
                _set_popupParcel(tempResponsesStore.services, tabUrl, true)
          
    )
)



initialize = (currentUrl) ->
  
  browser.storage.sync.get(null, (allItemsInSyncedStorage) ->
    
    if !allItemsInSyncedStorage['kiwi_servicesInfo']?
      
        # we set the defaults in localStorage if servicesInfo doesn't exist in localStorage 
      browser.storage.sync.set({'kiwi_servicesInfo': defaultServicesInfo}, (servicesInfo) ->
        getUrlResults_to_refreshBadgeIcon(defaultServicesInfo, currentUrl)
      )
      
    else
      
      getUrlResults_to_refreshBadgeIcon(allItemsInSyncedStorage['kiwi_servicesInfo'], currentUrl)
      
  )
  
getUrlResults_to_refreshBadgeIcon = (servicesInfo, currentUrl) ->
  
  currentTime = Date.now()
  
  if Object.keys(kiwi_urlsResultsCache).length > 0
    
     # to prevent repeated api requests - we check to see if we have up-to-date request results in local storage
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

_save_url_results = (servicesInfo, tempResponsesStore, _urlsResultsCache) ->
  
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
    
    paddingString += String.fromCharCode(randomLatinKeycode)
    characterCounter++
  
  return paddingString

_save_historyBlob = (kiwi_urlsResultsCache, tabUrl) ->
  
  tabUrl_hashWordArray = CryptoJS.SHA512(tabUrl)
  tabUrl_hash = tabUrl_hashWordArray.toString(CryptoJS.enc.Latin1)
  
  browser.storage.local.get(null, (allItemsInLocalStorage) ->  
    
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
        
        
      if allItemsInLocalStorage['kiwi_historyBlob']?
        newKiwi_historyBlob = paddedHistoryString + allItemsInLocalStorage['kiwi_historyBlob']
      else
        newKiwi_historyBlob = paddedHistoryString
    
    
    
      # we cap the size of the history blob at 17000 characters
    if allItemsInLocalStorage.kiwi_historyBlob? and  allItemsInLocalStorage.kiwi_historyBlob.indexOf(historyString) > 17000
      newKiwi_historyBlob = newKiwi_historyBlob.substring(0,15500)
    
    
    
    browser.storage.local.set({'kiwi_historyBlob': newKiwi_historyBlob}, ->
      
        # console.log 'historyString'
        # console.log historyString
        # console.log 'console.log paddedHistoryString'
        # console.log paddedHistoryString
        # console.log 'newKiwi_historyBlob'
        # console.log newKiwi_historyBlob
        
      )
  )
      

check_updateServiceResults = (servicesInfo, currentUrl, urlsResultsCache = null) ->
  
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
  
  browser.storage.local.get(null, (allItemsInLocalStorage) ->
    queryObj = {
      type: "GET"
      url: service_info.queryApi + encodeURIComponent(currentUrl)
      statusCode: {
        0: ->
          responsePackage = {
            forUrl: currentUrl,
            servicesInfo: servicesInfo,
            serviceName: service_info.name,
            queryResult: null
          };
          console.log('unavailable!4');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults(responsePackage, servicesInfo);
        504: ->
          responsePackage = {
            forUrl: currentUrl,
            servicesInfo: servicesInfo,
            serviceName: service_info.name,
            queryResult: null
          };
          console.log('unavailable!4');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults(responsePackage, servicesInfo);
        503: ->
          responsePackage = {
            forUrl: currentUrl,
            servicesInfo: servicesInfo,
            serviceName: service_info.name,
            queryResult: null
          };
          console.log('unavailable!4');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults(responsePackage, servicesInfo);
        
        502: ->
          responsePackage = {
            forUrl: currentUrl,
            servicesInfo: servicesInfo,
            serviceName: service_info.name,
            queryResult: null
          };
          console.log('Fail!4');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults(responsePackage, servicesInfo);
        
        401: ->
          responsePackage = {
            forUrl: currentUrl,
            servicesInfo: servicesInfo,
            serviceName: service_info.name,
            queryResult: null
          };
          console.log('unauthenticated4');
          setPreppedServiceResults(responsePackage, servicesInfo);
          
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
            
          if service_info.name is 'productHunt'
            tryAgainTimestamp = currentTime + (1000 * 60 * 2)
            setTimeout_forProductHuntRefresh(tryAgainTimestamp, temp__kiwi_productHunt_oauth)
          else if service_info.name is 'reddit'
            tryAgainTimestamp = currentTime + (1000 * 60 * 2)
            setTimeout_forRedditRefresh(tryAgainTimestamp, temp__kiwi_reddit_oauth)
        
      },
      success: (queryResult) ->
        #console.log 'response yoyoyo'
        #console.debug queryResult
        
        responsePackage =
          
          forUrl: currentUrl
          
          servicesInfo: servicesInfo
          
          serviceName: service_info.name
          
          queryResult: queryResult
        
        
        setPreppedServiceResults(responsePackage, servicesInfo)
    }
    
    if service_info.name is 'reddit' and allItemsInLocalStorage.kiwi_reddit_oauth? 
      # console.log 'we are trying with oauth!'
      # console.debug allItemsInLocalStorage.kiwi_reddit_oauth
      queryObj.headers =
        'Authorization': "'bearer " + allItemsInLocalStorage.kiwi_reddit_oauth.token + "'"
    else if service_info.name is 'reddit' and !allItemsInLocalStorage.kiwi_reddit_oauth?
      # console.log 'adfaeaefae'
      
      responsePackage = {
        forUrl: currentUrl,
        servicesInfo: servicesInfo,
        serviceName: service_info.name,
        queryResult: null
      };
      
      setPreppedServiceResults(responsePackage, servicesInfo)
      
      
      tryAgainTimestamp = currentTime + (1000 * 60 * 2)
      setTimeout_forRedditRefresh(tryAgainTimestamp, temp__kiwi_reddit_oauth)
      
      return 0
    
    # console.log 'name is ' + service_info.name
    # console.log 'trying for ' + service_info.queryApi + encodeURIComponent(currentUrl)
    
    if service_info.name is 'productHunt' and allItemsInLocalStorage.kiwi_productHunt_oauth? 
      # console.log 'trying PH with'
      # console.debug allItemsInLocalStorage.kiwi_productHunt_oauth
      queryObj.headers =
        'Authorization': "Bearer " + allItemsInLocalStorage.kiwi_productHunt_oauth.token
        'Accept': 'application/json'
        'Content-Type': 'application/json'
        # 'Origin':''
        # 'Host': 'api.producthunt.com'
        
    else if service_info.name is 'productHunt' and !allItemsInLocalStorage.kiwi_productHunt_oauth? 
      # console.log 'asdfasdfasdfdas'
      # call out and to a reset / refresh timer thingy
      responsePackage = {
        forUrl: currentUrl,
        servicesInfo: servicesInfo,
        serviceName: service_info.name,
        queryResult: null
      };
      
      setPreppedServiceResults(responsePackage, servicesInfo)
      
      tryAgainTimestamp = currentTime + (1000 * 60 * 2)
      setTimeout_forProductHuntRefresh(tryAgainTimestamp, temp__kiwi_productHunt_oauth)
      
      return 0
      
      
    $.ajax( queryObj )
  )
   
dispatchGnewsQuery__customSearch = (customSearchQuery, servicesToSearch, service_info, servicesInfo) ->
  
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
  
  
  
dispatchProductHuntQuery__customSearch = (customSearchQuery, servicesToSearch, service_info, servicesInfo) ->
  
  currentTime = Date.now()
  
  # console.log ' trying dispatchProductHuntQuery__customSearch '
  # if !algoliaPHclient? or !algoliaPHindex?
    # ^^ these are local resources, should always be present
  
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
  
  # # for custom string PH searches 
  algoliaPHclient = algoliasearch('0H4SMABBSG', '9670d2d619b9d07859448d7628eea5f3')
  algoliaPHindex = algoliaPHclient.initIndex('Post_production')
  
  algoliaPHindex.search(customSearchQuery, (err, content) ->
    # // err is either `null` or an `Error` object, with a `message` property
    # // content is either the result of the command or `undefined`

    if (err) 
      console.error(err)
      
      responsePackage =
        servicesInfo: servicesInfo
        serviceName: service_info.name
        queryResult: null
        servicesToSearch: servicesToSearch
        customSearchQuery: customSearchQuery
      setPreppedServiceResults__customSearch(responsePackage, servicesInfo)
      
      if kiwi_userMessages["productHuntDown__customSearch"]?
        send_kiwi_userMessage('productHuntDown__customSearch')
      
      return
    
    if content? and content.hits?
      queryResult = content.hits
    else
      queryResult = []
    
    responsePackage =
      servicesInfo: servicesInfo
      serviceName: service_info.name
      queryResult: queryResult
      servicesToSearch: servicesToSearch
      customSearchQuery: customSearchQuery
    
    setPreppedServiceResults__customSearch(responsePackage, servicesInfo)
    
  )
  
  
  
dispatchQuery__customSearch = (customSearchQuery, servicesToSearch, service_info, servicesInfo) ->
  
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
      
  browser.storage.local.get(null, (allItemsInLocalStorage) ->
    queryObj = {
      type: "GET"
      url: queryUrl
      statusCode: {
        
        0: ->
          responsePackage = {
            servicesInfo: servicesInfo
            serviceName: service_info.name
            queryResult: null
            servicesToSearch: servicesToSearch
            customSearchQuery: customSearchQuery
          };
          console.log('unavailable!1');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults__customSearch(responsePackage, servicesInfo);
        504: ->
          responsePackage = {
            servicesInfo: servicesInfo
            serviceName: service_info.name
            queryResult: null
            servicesToSearch: servicesToSearch
            customSearchQuery: customSearchQuery
          };
          console.log('unavailable!1');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults__customSearch(responsePackage, servicesInfo);
        503: ->
          responsePackage = {
            servicesInfo: servicesInfo
            serviceName: service_info.name
            queryResult: null
            servicesToSearch: servicesToSearch
            customSearchQuery: customSearchQuery
          };
          console.log('unavailable!1');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults__customSearch(responsePackage, servicesInfo);
        
        502: ->
          responsePackage = {
            servicesInfo: servicesInfo
            serviceName: service_info.name
            queryResult: null
            servicesToSearch: servicesToSearch
            customSearchQuery: customSearchQuery
          };
          console.log('Fail!1');
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
          setPreppedServiceResults__customSearch(responsePackage, servicesInfo);
        
        401: ->
          responsePackage = {
            servicesInfo: servicesInfo
            serviceName: service_info.name
            queryResult: null
            servicesToSearch: servicesToSearch
            customSearchQuery: customSearchQuery
          };
          console.log('unauthenticated1');
          setPreppedServiceResults__customSearch(responsePackage, servicesInfo);
          
          if kiwi_userMessages[service_info.name + "Down"]?
            send_kiwi_userMessage(service_info.name + "Down")
            
          if service_info.name is 'productHunt'
            tryAgainTimestamp = currentTime + (1000 * 60 * 2)
            setTimeout_forProductHuntRefresh(tryAgainTimestamp, temp__kiwi_productHunt_oauth)
          else if service_info.name is 'reddit'
            tryAgainTimestamp = currentTime + (1000 * 60 * 2)
            setTimeout_forRedditRefresh(tryAgainTimestamp, temp__kiwi_reddit_oauth)
        }
      success: (queryResult) ->
        #console.log 'response yoyoyo'
        #console.debug queryResult
        
        responsePackage =
          servicesInfo: servicesInfo
          serviceName: service_info.name
          queryResult: queryResult
          servicesToSearch: servicesToSearch
          customSearchQuery: customSearchQuery
        
        setPreppedServiceResults__customSearch(responsePackage, servicesInfo)
    }
    if service_info.name is 'reddit' and allItemsInLocalStorage.kiwi_reddit_oauth? 
      #console.log 'we are trying with oauth!'
      #console.debug allItemsInLocalStorage.kiwi_reddit_oauth
      queryObj.headers =
        'Authorization': "'bearer " + allItemsInLocalStorage.kiwi_reddit_oauth.token + "'"
    
    else if service_info.name is 'reddit' and !allItemsInLocalStorage.kiwi_reddit_oauth?
      
      responsePackage =
        servicesInfo: servicesInfo
        serviceName: service_info.name
        queryResult: null
        servicesToSearch: servicesToSearch
        customSearchQuery: customSearchQuery
      
      #console.log 'responsePackage'
      #console.debug responsePackage
      
      setPreppedServiceResults__customSearch(responsePackage, servicesInfo)
      if kiwi_userMessages[service_info.name + "Down"]?
        console.log 'setPreppedServiceResults__customSearch(responsePackage, servicesInfo)1'
        send_kiwi_userMessage(service_info.name + "Down")
      
      # console.log('unauthenticated');
      return 0
    
    
    $.ajax( queryObj )
    
  )
  
  
  # proactively set if all service_PreppedResults are ready.
    # will be set with available results if queried by popup.
  
  # the popup should always have enough to render with a properly set popupParcel.
setPreppedServiceResults__customSearch = (responsePackage, servicesInfo) ->
  
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
        # browser.storage.local.get(null, (allItemsInLocalStorage) ->
          # #console.log 'trying to save all'
          # if !allItemsInLocalStorage['kiwi_urlsResultsCache']?
          #   allItemsInLocalStorage['kiwi_urlsResultsCache'] = {}
    
    if kiwi_urlsResultsCache[tabUrl]?
      _set_popupParcel(kiwi_urlsResultsCache[tabUrl], tabUrl, true)
    else
      _set_popupParcel({}, tabUrl, true)
    
  # else
  #   #console.log 'yolo 6 not finished ' + serviceInfo.name
  #   _set_popupParcel(tempResponsesStore.services, responsePackage.forUrl, false)
    


_set_popupParcel = (setWith_urlResults = {}, forUrl, sendPopupParcel, renderView = null, oldUrl = false) ->
  
  # console.log 'trying to set popupParcel, forUrl tabUrl' + forUrl + tabUrl
  # tabUrl
  if setWith_urlResults != {}
    if forUrl != tabUrl
      # console.log "_set_popupParcel request for old url"
      return false
  
  setObj_popupParcel = {}
  
  setObj_popupParcel.forUrl = tabUrl
  
  
  browser.storage.sync.get(null, (allItemsInSyncedStorage) ->
    
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
    
    # if !allItemsInSyncedStorage['kiwi_alerts']?
    #   setObj_popupParcel.kiwi_alerts = []
    # else
    #   setObj_popupParcel.kiwi_alerts = allItemsInSyncedStorage['kiwi_alerts']
    
    setObj_popupParcel.kiwi_customSearchResults = kiwi_customSearchResults
    
    if !setWith_urlResults?
      # console.log '_set_popupParcel called with undefined responses (not supposed to happen, ever)'
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
    
    
    # kiwi_userMessages = {
    #   "redditDown":
    #     "baseValue":"reddit's API is unavailable, so results may not appear from this service for some time"
    #     "sentAndAcknowledgedInstanceObjects": []
    #       # {
    #       #   "sentTimestamp"
    #       #   "userAcknowledged": null # <timestamp>
    #       # } ...
    
    # popupParcel = {}
    # # proactively set if each services' preppedResults are ready.
    #   # will be set with available results if queried by popup.
    #   # {
    #     # forUrl:
    #     # allPreppedResults:
    #     # kiwi_servicesInfo:
    #     # kiwi_customSearchResults:
    #     # kiwi_alerts:
    #     # kiwi_userPreferences:
    #     # kiwi_unackedUserMessages:
    
    #       # unacknowledged user messages
    #   # }
    
    setObj_popupParcel.kiwi_userMessages = []
    for messageName, messageObj of kiwi_userMessages
      for sentInstance in messageObj.sentAndAcknowledgedInstanceObjects
        if sentInstance.userAcknowledged is null
          setObj_popupParcel.kiwi_userMessages.push messageObj
    
    isUrlBlocked = is_url_blocked(allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_blacklists, tabUrl)
    if isUrlBlocked == true
      setObj_popupParcel.urlBlocked = true
    
    if oldUrl is true
      setObj_popupParcel.oldUrl = true
    else
      setObj_popupParcel.oldUrl = false
    
    popupParcel = setObj_popupParcel
    
    if sendPopupParcel
      
      parcel = {}
      
      parcel.msg = 'kiwiPP_popupParcel_ready'
      parcel.forUrl = tabUrl
      
      parcel.popupParcel = setObj_popupParcel
      
      sendParcel(parcel)
    
  )
  



setPreppedServiceResults = (responsePackage, servicesInfo) ->
  #console.log 'yolo 6'
  # console.log 'query results for '
  # console.debug servicesInfo
  # console.debug responsePackage
  currentTime = Date.now()
  
  if tabUrl == responsePackage.forUrl  # if false, then do nothing (user's probably switched to new tab)
    
    for serviceObj in servicesInfo
      if serviceObj.name == responsePackage.serviceName
        serviceInfo = serviceObj
    # serviceInfo = servicesInfo[responsePackage.serviceName]
    
    
    # even if there are zero matches returned, that counts as a proper query response
    service_PreppedResults = parseResults[responsePackage.serviceName](responsePackage.queryResult, responsePackage.forUrl, serviceInfo)
    
    if !tempResponsesStore.services?
      tempResponsesStore = {}
      tempResponsesStore.services = {}
    
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
          # browser.storage.local.get(null, (allItemsInLocalStorage) ->
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
  
  
  productHunt: (resultsObj, searchQueryString, serviceInfo, customSearchBool = false) ->
    # console.log 'resultsObj'
    # console.log 'for: ' + searchQueryString
    # console.debug resultsObj
    
    # console.log 'customSearchBool ' + customSearchBool
    # ~~~~~~~ #
    
    matchedListings = []
    
    if ( resultsObj == null ) 
      return matchedListings
    
    if customSearchBool is false # so, normal URL-based queries
      
        # created_at: "2014-08-18T06:40:47.000-07:00"
        # discussion_url: "http://www.producthunt.com/tech/product-hunt-api-beta"

        # comments_count: 13
        # votes_count: 514
        # name: "Product Hunt API (beta)"

        # featured: true

        # id: 6970

        # maker_inside: true

        # tagline: "Make stuff with us. Signup for early access to the PH API :)"

        # user:
        #   headline: "Tech at Product Hunt 💃"
        #   profile_url: "http://www.producthunt.com/@andreasklinger"
        #   name: "Andreas Klinger"
        #   username: "andreasklinger"
        #   website_url: "http://klinger.io"
        
      if resultsObj.posts? and _.isArray(resultsObj.posts) is true
        
        for post in resultsObj.posts
          
          listingKeys = [
            'created_at','discussion_url','comments_count','redirect_url','votes_count','name',
            'featured','id','user','screenshot_url','tagline','maker_inside','makers'
          ]
          
          preppedResult = _.pick(post, listingKeys)
          
          preppedResult.kiwi_created_at = Date.parse(preppedResult.created_at)
          
          preppedResult.kiwi_discussion_url = preppedResult.discussion_url
          
          if preppedResult.user? and preppedResult.user.name? 
            preppedResult.kiwi_author_name = preppedResult.user.name.trim()
          else
            preppedResult.kiwi_author_name = ""
          
          if preppedResult.user? and preppedResult.user.username? 
            preppedResult.kiwi_author_username = preppedResult.user.username
          else
            preppedResult.kiwi_author_username = ""
            
          if preppedResult.user? and preppedResult.user.headline?
            preppedResult.kiwi_author_headline = preppedResult.user.headline.trim()
          else
            preppedResult.kiwi_author_headline = ""
          
          preppedResult.kiwi_makers = []
          
          for maker, index in post.makers
            makerObj = {}
            makerObj.headline = maker.headline
            makerObj.name = maker.name
            makerObj.username = maker.username
            makerObj.profile_url = maker.profile_url
            makerObj.website_url = maker.website_url
            
            preppedResult.kiwi_makers.push makerObj
          
          
          preppedResult.kiwi_exact_match = true # PH won't return fuzzy matches
          
          preppedResult.kiwi_score = preppedResult.votes_count
          preppedResult.kiwi_num_comments = preppedResult.comments_count
          preppedResult.kiwi_permaId = preppedResult.permalink
          
          matchedListings.push preppedResult
    else # custom string queries
    
      # comment_count
      # vote_count
      
      # name
      
      # url # 
      
      # tagline
        
      # category
      #   tech
      
      
      # product_makers
      #   headline
      #   name
      #   username
      #   is_maker
      
      # console.log ' else # custom string queries ' + _.isArray(resultsObj) # 
      if resultsObj? and _.isArray(resultsObj)
        # console.log ' yoyoyoy1 '
        for searchMatch in resultsObj
          
          listingKeys = [
            'author'
            'url',
            'tagline',
            'product_makers'
            'comment_count',
            'vote_count',
            'name',
            
            'id',
            'user',
            'screenshot_url',
            
          ]
          
          preppedResult = _.pick(searchMatch, listingKeys)
          
          preppedResult.kiwi_created_at = null  # algolia doesn't provide created at value :<
          
          preppedResult.kiwi_discussion_url = "http://www.producthunt.com/" + preppedResult.url
          
          if preppedResult.author? and preppedResult.author.name? 
            preppedResult.kiwi_author_name = preppedResult.author.name.trim()
          else
            preppedResult.kiwi_author_name = ""
          
          if preppedResult.author? and preppedResult.author.username? 
            preppedResult.kiwi_author_username = preppedResult.author.username
          else
            preppedResult.kiwi_author_username = ""
            
          if preppedResult.author? and preppedResult.author.headline?
            preppedResult.kiwi_author_headline = preppedResult.author.headline.trim()
          else
            preppedResult.kiwi_author_headline = ""
          
          preppedResult.kiwi_makers = []
          
          for maker, index in searchMatch.product_makers
            makerObj = {}
            makerObj.headline = maker.headline
            makerObj.name = maker.name
            makerObj.username = maker.username
            makerObj.profile_url = maker.profile_url
            makerObj.website_url = maker.website_url
            
            preppedResult.kiwi_makers.push makerObj
          
          preppedResult.kiwi_exact_match = true # PH won't return fuzzy matches
          
          preppedResult.kiwi_score = preppedResult.vote_count
          preppedResult.kiwi_num_comments = preppedResult.comment_count
          preppedResult.kiwi_permaId = preppedResult.permalink
          
          
          matchedListings.push preppedResult
      
    return matchedListings
    
    
  reddit: (resultsObj, searchQueryString, serviceInfo, customSearchBool = false) ->
    
    matchedListings = []
    if ( resultsObj == null ) 
      return matchedListings
      
    # occasionally Reddit will decide to return an array instead of an object, so...
      # in response to user's feedback, see: https://news.ycombinator.com/item?id=9994202
    forEachQueryObject = (resultsObj, _matchedListings) ->
    
      if resultsObj.kind? and resultsObj.kind == "Listing" and resultsObj.data? and 
          resultsObj.data.children? and resultsObj.data.children.length > 0
        
        for child in resultsObj.data.children
          
          if child.data? and child.kind? and child.kind == "t3"
            
            listingKeys = ["subreddit",'url',"score",'domain','gilded',"over_18","author","hidden","downs","permalink","created","title","created_utc","ups","num_comments"]
            
            preppedResult = _.pick(child.data, listingKeys)
            
            preppedResult.kiwi_created_at = preppedResult.created_utc * 1000 # to normalize to JS's Date.now() millisecond UTC timestamp
            
            if customSearchBool is false
              preppedResult.kiwi_exact_match = _exact_match_url_check(searchQueryString, preppedResult.url)
            else
              preppedResult.kiwi_exact_match = true
            
            preppedResult.kiwi_score = preppedResult.score
            preppedResult.kiwi_num_comments = preppedResult.num_comments
            preppedResult.kiwi_permaId = preppedResult.permalink
            
            _matchedListings.push preppedResult
      
      return _matchedListings
    
    if _.isArray(resultsObj)
      
      for result in resultsObj
        matchedListings = forEachQueryObject(result, matchedListings)
      
    else
      matchedListings = forEachQueryObject(resultsObj, matchedListings)
    
    return matchedListings
      
    
  hackerNews: (resultsObj, searchQueryString, serviceInfo, customSearchBool = false) ->
    
    matchedListings = []
    if ( resultsObj == null ) 
      return matchedListings
    #console.log ' hacker news #console.debug resultsObj'
    #console.debug resultsObj
    # if resultsObj.nbHits? and resultsObj.nbHits > 0 and resultsObj.hits? and resultsObj.hits.length is resultsObj.nbHits
    if resultsObj? and resultsObj.hits?
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
        
        preppedResult.kiwi_num_comments = preppedResult.num_comments
        
        preppedResult.kiwi_permaId = preppedResult.objectID
        
        matchedListings.push preppedResult
      
    return matchedListings
  
  gnews: (resultsObj, searchQueryString, serviceInfo, customSearchBool = false) ->
    
    if ( resultsObj == null ) 
      return matchedListings
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
  
    # warning:: one of the worst algo-s i've ever written... please don't use as reference
  
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
          if protocolSplitUrlArray.length > 1
            if protocolSplitUrlArray[1].indexOf('www.') != 0
              protocolSplitUrlArray[1] = 'www.' + protocolSplitUrlArray[1]
              WWWurl = protocolSplitUrlArray.join('://')
            else
              WWWurl = forUrl
            return WWWurl
            
          else
            if protocolSplitUrlArray[0].indexOf('www.') != 0
              protocolSplitUrlArray[0] = 'www.' + protocolSplitUrlArray[1]
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
            if listing.kiwi_num_comments? and listing.kiwi_num_comments >= service.notableConditions.num_comments
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
    browser.storage.sync.get(null, (allItemsInSyncedStorage) -> 
      if allItemsInSyncedStorage['kiwi_userPreferences']? and allItemsInSyncedStorage['kiwi_userPreferences'].researchModeOnOff == 'off'
        badgeText = 'off'
      else if defaultUserPreferences.researchModeOnOff == 'off'
        badgeText = 'off'
      else
        badgeText = ''
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
  
  browser.browserAction.setBadgeText({'text':text.toString()})


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
        
        # browser.storage.local.set({'kiwi_urlsResultsCache':kiwi_urlsResultsCache}, ->
            
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
  
  # console.log '#console.debug popupParcel
  #  console.debug _popupParcel'
  
  # console.debug popupParcel
  # console.debug _popupParcel
  
  if popupParcel? and popupParcel.kiwi_userPreferences? and popupParcel.kiwi_servicesInfo
    formerResearchModeValue = popupParcel.kiwi_userPreferences.researchModeOnOff
    formerKiwi_servicesInfo = popupParcel.kiwi_servicesInfo
    former_autoOffTimerType = popupParcel.kiwi_userPreferences.autoOffTimerType
    former_autoOffTimerValue = popupParcel.kiwi_userPreferences.autoOffTimerValue
  
  popupParcel = {}
  
  # console.log ' asdfasdfasd formerKiwi_autoOffTimerType'
  # console.log former_autoOffTimerType
  # console.log _popupParcel.kiwi_userPreferences.autoOffTimerType
  # console.log ' a;woeifjaw;ef formerKiwi_autoOffTimerValue'
  # console.log former_autoOffTimerValue
  # console.log _popupParcel.kiwi_userPreferences.autoOffTimerValue
  
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
  
  browser.storage.sync.set({'kiwi_userPreferences': _popupParcel.kiwi_userPreferences}, ->
      
    browser.storage.sync.set({'kiwi_servicesInfo': _popupParcel.kiwi_servicesInfo}, ->
        
      
      if updateToView?
        
        parcel = {}
        
        _popupParcel['view'] = updateToView
        
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
        
        kiwi_autoOffClearInterval = setTimeout( ->
            turnResearchModeOff()
          , new_autoOffAtUTCmilliTimestamp - currentTime )
      
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
    kiwi_autoOffClearInterval = setTimeout( ->
        turnResearchModeOff()
      , new_autoOffAtUTCmilliTimestamp - currentTime )
  
  return new_autoOffAtUTCmilliTimestamp
    
    
turnResearchModeOff = ->
  #console.log 'turning off research mode - in turnResearchModeOff'
  
  browser.storage.sync.get(null, (allItemsInSyncedStorage) -> 
    
    if kiwi_urlsResultsCache[tabUrl]?
      urlResults = kiwi_urlsResultsCache[tabUrl]
    else
      urlResults = {}
    
    if allItemsInSyncedStorage.kiwi_userPreferences?
      
      allItemsInSyncedStorage.kiwi_userPreferences.researchModeOnOff = 'off'
      browser.storage.sync.set({'kiwi_userPreferences':allItemsInSyncedStorage.kiwi_userPreferences}, ->
          _set_popupParcel(urlResults, tabUrl, true)
          if allItemsInSyncedStorage.kiwi_servicesInfo?
            refreshBadge(allItemsInSyncedStorage.kiwi_servicesInfo, urlResults)
          # else
            #console.log 'weird, allItemsInSyncedStorage.kiwi_servicesInfo not set'
        )
      
    else
      defaultUserPreferences.researchModeOnOff = 'off'
      
      browser.storage.sync.set({'kiwi_userPreferences':defaultUserPreferences}, ->
          
          _set_popupParcel(urlResults, tabUrl, true)
          
          if allItemsInSyncedStorage.kiwi_servicesInfo?
            
            refreshBadge(allItemsInSyncedStorage.kiwi_servicesInfo, urlResults)
            
        )
    
  )


autoOffTimerExpired_orOff_withoutURLoverride = (allItemsInSyncedStorage, currentTime, overrideResearchModeOff, tabUrl, kiwi_urlsResultsCache) ->
  if allItemsInSyncedStorage.kiwi_userPreferences?
    
    if allItemsInSyncedStorage.kiwi_userPreferences.autoOffAtUTCmilliTimestamp?
      if currentTime > allItemsInSyncedStorage.kiwi_userPreferences.autoOffAtUTCmilliTimestamp 
        #console.log 'timer is past due - turning off - in initifnewurl'
        allItemsInSyncedStorage.kiwi_userPreferences.researchModeOnOff = 'off'
        
    # here's the 
    
    if allItemsInSyncedStorage.kiwi_userPreferences.researchModeOnOff is 'off' and overrideResearchModeOff == false
      updateBadgeText('off')
      
      #console.log '#console.debug kiwi_urlsResultsCache'
      #console.debug kiwi_urlsResultsCache
        
      return true
      
    return false


proceedWithPreInitCheck = (allItemsInSyncedStorage, allItemsInLocalStorage, overrideSameURLCheck_popupOpen, overrideResearchModeOff,
                              sameURLCheck, tabUrl, currentTime, popupOpen) ->
  
  
  if allItemsInSyncedStorage['kiwi_userPreferences']? and overrideResearchModeOff is false
    isUrlWhitelistedBool = is_url_whitelisted(allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_whitelists, tabUrl)
    
    
      # provided that the user isn't specifically researching a URL, if it's whitelisted, then that acts as override
    overrideResearchModeOff = isUrlWhitelistedBool
    
    # console.log "if is_url_whitelisted(allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_whitelists, tabUrl)"
    # console.log is_url_whitelisted(allItemsInSyncedStorage['kiwi_userPreferences'].urlSubstring_whitelists, tabUrl)
    
    
  if autoOffTimerExpired_orOff_withoutURLoverride(allItemsInSyncedStorage, currentTime, overrideResearchModeOff, tabUrl, kiwi_urlsResultsCache) is true
    # console.log 'in if autoOffTimerExpired_orOff_withoutURLoverride'
    # showing cached responses
    # if tabUrl == tempResponsesStore.forUrl # # # # # # # # # # 
      #console.log 'if tabUrl == tempResponsesStore.forUrl'
      #console.log tabUrl
      #console.log tempResponsesStore.forUrl
    if kiwi_urlsResultsCache[tabUrl]?
      _set_popupParcel(kiwi_urlsResultsCache[tabUrl],tabUrl,false);
      if allItemsInSyncedStorage['kiwi_servicesInfo']?
        refreshBadge(allItemsInSyncedStorage['kiwi_servicesInfo'], kiwi_urlsResultsCache[tabUrl])
    else
      #console.log '_set_popupParcel({},tabUrl,false);  '
      _set_popupParcel({},tabUrl,true);
    
  else
    periodicCleanup(tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage, (tabUrl, allItemsInLocalStorage, allItemsInSyncedStorage) ->
      
      
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
        browser.storage.sync.set(setObj, ->
          
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

checkForNewDefaultUserPreferenceAttributes_thenProceedWithInitCheck = (allItemsInSyncedStorage, allItemsInLocalStorage, 
                    overrideSameURLCheck_popupOpen, overrideResearchModeOff, sameURLCheck, tabUrl, currentTime, popupOpen) ->
    # ^^ checks if newly added default user preference attributes exist (so new features don't break current installs)
    
  setObj = {}
  newUserPrefsAttribute = false
  newServicesInfoAttribute = false
  newServicesInfo = []
  newUserPreferences = {}
  
  if allItemsInSyncedStorage['kiwi_userPreferences']?
    
    newUserPreferences = _.extend {}, allItemsInSyncedStorage['kiwi_userPreferences']
    for keyName, value of defaultUserPreferences
      
      if typeof allItemsInSyncedStorage['kiwi_userPreferences'][keyName] is 'undefined'
        # console.log 'the following is a new keyName '
        # console.log keyName
        newUserPrefsAttribute = true
        newUserPreferences[keyName] = value
  
  
  if allItemsInSyncedStorage['kiwi_servicesInfo']?
    
    # needs to handle entirely new services as well as simplly new attributes
    newServicesInfo = _.extend [], allItemsInSyncedStorage['kiwi_servicesInfo']
    
    for service_default, index in defaultServicesInfo
      
      matchingService = _.find(allItemsInSyncedStorage['kiwi_servicesInfo'], (service_info) -> 
        if service_info.name is service_default.name
          return true
        else
          return false
      )
      
      if matchingService?
        
        newServiceObj = _.extend {}, matchingService 
        for keyName, value of service_default
          # console.log keyName
          if typeof matchingService[keyName] is 'undefined'
            
            newServicesInfoAttribute = true
            newServiceObj[keyName] = value
        
        indexOfServiceToReplace = _.indexOf(newServicesInfo, matchingService)
        
        newServicesInfo[indexOfServiceToReplace] = newServiceObj
      else
          # supports adding an entirely new service
        newServicesInfoAttribute = true
          # users that don't download with a specific service will need to opt-in to the new one
        if service_default.active? 
          service_default.active = 'off'
        newServicesInfo.push service_default
  
  if newUserPrefsAttribute or newServicesInfoAttribute
    if newUserPrefsAttribute
      setObj['kiwi_userPreferences'] = newUserPreferences
      
    if newServicesInfoAttribute
      setObj['kiwi_servicesInfo'] = newServicesInfo
    
    browser.storage.sync.set(setObj, ->
        
        # this reminds me of the frog DNA injection from jurassic park
      if newUserPrefsAttribute
        allItemsInSyncedStorage['kiwi_userPreferences'] = newUserPreferences
      
      if newServicesInfoAttribute
        allItemsInSyncedStorage['kiwi_servicesInfo'] = newServicesInfo
      
      proceedWithPreInitCheck(allItemsInSyncedStorage, allItemsInLocalStorage, overrideSameURLCheck_popupOpen, overrideResearchModeOff,
          sameURLCheck, tabUrl, currentTime, popupOpen)
    )
  else
    proceedWithPreInitCheck(allItemsInSyncedStorage, allItemsInLocalStorage, overrideSameURLCheck_popupOpen, overrideResearchModeOff,
        sameURLCheck, tabUrl, currentTime, popupOpen)

  # a wise coder once told me "try to keep functions to 10 lines or less." yea, welcome to initIfNewURL! let me find my cowboy hat :D
initIfNewURL = (overrideSameURLCheck_popupOpen = false, overrideResearchModeOff = false) ->
  
  if typeof overrideSameURLCheck_popupOpen != 'boolean'
    # ^^ because the Chrome api tab listening functions were exec-ing callback with an integer argument
      # that has since been negated by nesting the callback, but why not leave the check here?
    overrideSameURLCheck_popupOpen = false
  
  # #console.log 'wtf 1 kiwi_urlsResultsCache ' + o2verrideSameURLCheck_popupOpen
  if overrideSameURLCheck_popupOpen # for when a user turns researchModeOnOff "on" or refreshes results from popup
    popupOpen = true
  else
    popupOpen = false
  
  currentTime = Date.now()
  
  # browser.tabs.getSelected(null,(tab) ->
  browser.tabs.query({ currentWindow: true, active: true }, (tabs) ->
    
    if tabs.length > 0 and tabs[0].url?
        
      if tabs[0].url.indexOf('chrome-devtools://') != 0
        
        tabUrl = tabs[0].url
        
        # we care about the title, because it's the best way to search google news
        if tabs[0].status == 'complete'
          title = tabs[0].title
          
            # a little custom title formatting for sites that begin their tab titles with "(<number>)" like twitter.com
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
      
      browser.storage.local.get(null, (allItemsInLocalStorage) ->
        
        # #console.log 'browser.storage.local.get(null, (allItemsInLocalStorage) ->  '
        
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
        browser.storage.local.set({'persistentUrlHash': tabUrl_hash}, ->)
        
        if sameURLCheck == false          
          updateBadgeText('')
        
          browser.storage.sync.get(null, (allItemsInSyncedStorage) ->
            
            checkForNewDefaultUserPreferenceAttributes_thenProceedWithInitCheck(allItemsInSyncedStorage, allItemsInLocalStorage, 
                overrideSameURLCheck_popupOpen, overrideResearchModeOff, sameURLCheck, tabUrl, currentTime, popupOpen)
            
          )
        
    )
  )

browser.tabs.onActivated.addListener( -> 
    # nesting function because the Chrome api tab listening functions were exec-ing callback with an integer argument
    initIfNewURL()
  )

browser.tabs.onUpdated.addListener((tabId , info) ->
    # updateBadgeText('')
    if tabTitleObject? and tabTitleObject.forUrl == tabUrl and !tabTitleObject.tabTitle?
      if (info.status == "complete") 
        initIfNewURL(true)
        return 0
    else
      initIfNewURL()
  )

browser.windows.onFocusChanged.addListener( -> 
    # nesting function because the Chrome api tab listening functions were exec-ing callback with an integer argument
    initIfNewURL()
  )

# intial startup
if tabTitleObject == null
  initIfNewURL(true)




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
  
