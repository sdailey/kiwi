
viewElementId = ''

renderedBool = false

preferencesOnlyPage = false



# `
# var head = document.getElementsByTagName('head')[0];
#  var script = document.createElement('script');
#  script.type = 'text/javascript';
#  script.src = "https://www.google.com/uds/?file=search&v=1";
#  head.appendChild(script);
# `


  


initialize = (popupParcel) ->
  console.log 'in init'
  
  if getURLParam(window.location, 'optionsOnly') != ''
    preferencesOnlyPage = true
    views.userPreferences.render(popupParcel)
    return 0

  # views.userPreferences.render(popupParcel)
  if popupParcel.view? and views[popupParcel.view]?
    views[popupParcel.view].render(popupParcel)
  else
    views.conversations.render(popupParcel)
    

class Widget # basic building block
  constructor: (@name) ->
    @elsToUnbind = []
    @DOMselector = "#" + @name + "_Widget"
    
    @bindAllGoToViewButtons = (viewData) =>
      console.log '@bindAllGoToViewButtons = (viewData) =>'
      console.log @DOMname
      
      for _viewName, viewValue of views
        console.log _viewName
        # bind to goToView buttons
        els_goTo_view = $(@DOMselector + ' .goTo_' + _viewName + 'View')
        console.debug els_goTo_view
        @elsToUnbind.push els_goTo_view
        bindGoToViewButtons(els_goTo_view, _viewName, viewData)
  
    @unbindWidget = =>
      for el in @elsToUnbind
        el.unbind()
      @elsToUnbind = []
      
    @render = (renderState, popupParcel) =>
      @unbindWidget(@name)
      
      @renderStates[renderState].paint(popupParcel)
      
      @bindAllGoToViewButtons(popupParcel)
      
      @renderStates[renderState].bind(popupParcel)
    return @
    
class CustomSearch extends Widget
  constructor: (@name, @widgetOpenBool) ->
    super @name
    @renderStates = @__renderStates__()
    
  init: (popupParcel) ->
    @unbindWidget()
    if @widgetOpenBool == false
      @render('collapsed',popupParcel)
    else
      @render('opened',popupParcel)
  
  
  __renderStates__: =>
      collapsed: 
        paint: (popupParcel) =>
          openedCustomSearchHTML = '<div>
              <input style="width:275px; margin-right:10px;" id="customSearchQuery" type="text" placeholder=" search" />
              <button class="goTo_userPreferencesView">User Options 
              <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span></button> 
            </div><br>'
              
          $(@DOMselector).html(openedCustomSearchHTML)  
          
          
        bind: (popupParcel) =>
          inputSearchQuery = $("#customSearchQuery")
          @elsToUnbind.push inputSearchQuery
          inputSearchQuery.bind 'click', =>
            @widgetOpenBool = true
            @render('opened',popupParcel)
            
      opened: 
        paint: (popupParcel) =>
          cellWidth = (popupParcel.kiwi_servicesInfo.length + 1)/100 
          openedCustomSearchHTML = '<div>
              
              <input id="customSearchQuery" type="text" placeholder=" search" style="width:234px; margin-right: 10px;" />
              <button style="margin-right: 10px;">Submit</button>
              <button style="" class="goTo_userPreferencesView"> Options 
              <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span></button>  
              <br><br>
          <table style="width:100%;"><tbody><tr>'
          for serviceInfoObject in popupParcel.kiwi_servicesInfo
            
            serviceInfoObject.name
            serviceDisabledAttr = if serviceInfoObject.active is 'off' then ' disabled ' else ' checked '
            openedCustomSearchHTML += '<td style="width:' + cellWidth + '%;">
              &nbsp;&nbsp;' + serviceInfoObject.name + '&nbsp; <input type="checkbox" ' + serviceDisabledAttr + ' /></td>'
          
          openedCustomSearchHTML += '<td style="width:' + cellWidth + '%;" id="close__' + @name + '"> &nbsp; close <span class="glyphicon glyphicon-remove" aria-hidden="true"></span> </td>
          </tr></tbody></table></div><br>'
          
          $(@DOMselector).html(openedCustomSearchHTML)
          
        
        bind: (popupParcel) =>
          inputSearchQuery = $("#customSearchQuery")
          closeWidget = $('#close__' + @name)
          inputSearchQuery.focus()
          @elsToUnbind.concat [inputSearchQuery, closeWidget]
          
          closeWidget.bind 'click', =>
            @widgetOpenBool = false
            @render('collapsed',popupParcel)    
    
    
    renderStates: {}

widgets = 
  customSearch: new CustomSearch 'customSearch', false
  
      
vFs = 
  unbindView: (viewName) ->
    for el in views[viewName].elsToUnbind
      el.unbind()
    views[viewName].elsToUnbind = []
  
  showViewAndBindGoToViewButtons: (viewName, viewData) ->
    for _viewName, viewValue of views
      if _viewName == viewName
        # show
        console.log 'showing ' + viewName
        
        $('#' + viewName + 'View').css({'display':'block'})
      else
        # hide
        console.log 'hiding ' + _viewName
        
        $('#' + _viewName + 'View').css({'display':'none'})
        
        # bind to goToView buttons
        els_goTo_view = $('#' + viewName + 'View .goTo_' + _viewName + 'View')
        views[viewName].elsToUnbind.push els_goTo_view
        bindGoToViewButtons(els_goTo_view, _viewName, viewData)

views =
  
  conversations:
    elsToUnbind: []
    
    render: (popupParcel) ->
      viewName = 'conversations'
      
      console.log ' in conversations view'
      
      console.debug popupParcel
      
      vFs.unbindView(viewName) # prevents redundant bindings
      
      
      widgets['customSearch'].init(popupParcel)
      
      
      researchModeDisabledButtonsHTML = ''
      
      if popupParcel.urlBlocked == true or popupParcel.kiwi_userPreferences.researchModeOnOff == 'off'
        
        researchModeDisabledButtonsHTML += "<br><button id='researchUrlOverride'>Research this Url</button><br>"
        
      if popupParcel.kiwi_userPreferences.researchModeOnOff == 'off'
        
        researchModeDisabledButtonsHTML +=  "<br>Research Mode is off <button class='goTo_userPreferencesView'> change settings </button><br>"
        
      $("#researchModeDisabledButtons").html(researchModeDisabledButtonsHTML)
      
      
      preppedHTMLstring = ''
      
      for serviceInfoObject in popupParcel.kiwi_servicesInfo
        
        if popupParcel.allPreppedResults[serviceInfoObject.name]? and popupParcel.allPreppedResults[serviceInfoObject.name].service_PreppedResults.length > 0
          
          serviceResults = popupParcel.allPreppedResults[serviceInfoObject.name]
          
          preppedHTMLstring += tailorResults[serviceInfoObject.name](serviceInfoObject,serviceResults)
          
        else
          if serviceInfoObject.submitTitle?
            submitUrl = serviceInfoObject.submitUrl
            submitTitle = serviceInfoObject.submitTitle
            preppedHTMLstring += '<div><a target="_blank" href="' + submitUrl + '">' + submitTitle + '</a></div>'
            
          else
            
            preppedHTMLstring += '<div>No results for ' + serviceInfoObject.title + '</div>'
          
          
      $("#resultsByService").html(preppedHTMLstring)
      
      vFs.showViewAndBindGoToViewButtons(viewName, popupParcel)
      
      setTimeout( -> # to reign in a chrome rendering issue
          renderExtensionHeight(viewName+'View', 1)
          $($('input')[0]).blur()
          $($('a')[0]).blur()
          $($('button')[0]).blur()
        , 300
      )
      renderExtensionHeight(viewName+'View', 1)
      $($('input')[0]).blur()
      $($('a')[0]).blur()
      $($('button')[0]).blur()
      
      views[viewName].bind(popupParcel)
      
    bind: (popupParcel) ->
      viewName = 'conversations'
      
      researchUrlOverrideButton = $("#researchUrlOverride")
      
      clearKiwiURLCacheButton = $("#clearKiwiURLCache")
      
      refreshURLresultsButton = $("#refreshURLresults")
      
      views[viewName].elsToUnbind.concat [refreshURLresultsButton, researchUrlOverrideButton, clearKiwiURLCacheButton]
      
      if refreshURLresultsButton?
        refreshURLresultsButton.bind 'click', ->
          parcel =
            msg: 'kiwiPP_refreshURLresults'
          sendParcel(parcel)
      
      if clearKiwiURLCacheButton?
        clearKiwiURLCacheButton.bind 'click', ->
          parcel =
            msg: 'kiwiPP_clearAllURLresults'
          sendParcel(parcel)
      
      if researchUrlOverrideButton?
        researchUrlOverrideButton.bind 'click', ->
          parcel =
            msg: 'kiwiPP_researchUrlOverrideButton'
          sendParcel(parcel)
      
      
  userPreferences:
    elsToUnbind: []
    render: (popupParcel) ->
      viewName = 'userPreferences'
      
      vFs.unbindView(viewName) # prevents redundant bindings
      vFs.showViewAndBindGoToViewButtons(viewName, popupParcel)
      
      
      if preferencesOnlyPage is true
        $("#menuBar_preferences").hide()
      
      
      currentTime = Date.now()
      if popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp? and popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp > currentTime
        $("#autoOffTimer").html("Auto-Off timer expires at: " + formatTime(popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp) + "<br>")
      else if popupParcel.kiwi_userPreferences.researchModeOnOff == 'off' and popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp?
        $("#autoOffTimer").html("Auto-off timer last expired at: " + formatTime(popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp) + "<br>")
      else
        $("#autoOffTimer").html("Auto-off timer is not set")
        
      researchModeHtml = ''
      
      if popupParcel.kiwi_userPreferences.researchModeOnOff == "on"
        researchOnString = " checked='checked' "
        researchOffString = ""
      else
        researchOnString = ""
        researchOffString = " checked='checked' "
      
      if autoOffAtUTCmilliTimestamp?
        researchModeExpirationString = '<br>Research Mode will turn off (expire) at: ' + formatTime(autoOffAtUTCmilliTimestamp)
        researchModeExpirationString += '<br><button id="resetAutoOffTimer">Reset auto-off timer</button>'
      else  
        researchModeExpirationString = ''
      autoOffTimerType = popupParcel.kiwi_userPreferences.autoOffTimerType
      autoOffTimerValue = popupParcel.kiwi_userPreferences.autoOffTimerValue
      
      `var auto20, auto60, autoAlways, autoCustom, autoCustomValue = '';
      if(autoOffTimerType != null){
        if(autoOffTimerType == "20"){ auto20 = " checked='checked' " }
        else if(autoOffTimerType == "60"){ auto60 = " checked='checked' " }
        else if(autoOffTimerType == "always"){ autoAlways = " checked='checked' " }
        else if(autoOffTimerType == "custom"){ autoCustom = " checked='checked' "; autoCustomValue = autoOffTimerValue;}
      }`
      
      researchModeHtml += 'Research Mode: 
          on <input type="radio" name="research" value="on" ' + researchOnString + '> - 
          off <input type="radio" name="research" value="off" ' + researchOffString + '>
        ' + researchModeExpirationString + '<br>  
      <br>Auto-Off in:
       <br>&nbsp; &nbsp;<input type="radio" name="researchAutoOffType" ' + auto20 + ' value="20"> 20 min
       <br>&nbsp; &nbsp;<input type="radio" name="researchAutoOffType" ' + auto60 + ' value="60"> 1 hr
       <br>&nbsp; &nbsp;<input type="radio" name="researchAutoOffType" ' + autoAlways + ' value="always"> Always On
       <br>&nbsp; &nbsp;<input type="radio" name="researchAutoOffType" ' + autoCustom + ' value="custom"> Custom
          &nbsp; &nbsp; <input id="autoCustomValue" type="text" value="' + autoCustomValue + '" size="4" disabled /> minutes'
      
      $("#researchModeDrop").html(researchModeHtml)
      
      servicesHtml = ''
      
      for service, index in popupParcel.kiwi_servicesInfo
        
        console.debug service
        console.debug service
        if service.active == "on"
          activeCheck = " checked='checked' "
          notActiveCheck = ""
        else
          activeCheck = ""
          notActiveCheck = " checked='checked' "
        
        servicesHtml += '<br>
          <div class="serviceListing">
          <table><tbody><tr>
          <td class="upDownButtons">'
        if index != 0
          servicesHtml += '<span class="glyphicon glyphicon-chevron-up" id="' + service.name + '_moveServiceUp" aria-hidden="true"></span>'
        if index != 0 and index != popupParcel.kiwi_servicesInfo.length - 1
          servicesHtml += '<br><br>'
        if index != popupParcel.kiwi_servicesInfo.length - 1 
          servicesHtml += '<span class="glyphicon glyphicon-chevron-down" id="' + service.name + '_moveServiceDown" aria-hidden="true"></span>'
        
        servicesHtml += '</td>
          <td class="serviceInfo">' + service.title + ' - using: <a href="' + service.broughtToYouByURL + '">' + service.broughtToYouByTitle + '</a><br>
            <div style="padding-left:15px;">
              status:
              on <input type="radio" name="' + service.name + '_serviceStatus" value="on" ' + activeCheck + '> - 
              off <input type="radio" name="' + service.name + '_serviceStatus" value="off" ' + notActiveCheck + '>
              <br>Results are deemed notable (capitilizes badge letter, optionally plays sound) if:'
        
        if service.name == 'gnews'      
          console.log " if service.name == 'gnews'  servicesHtml "
          console.debug service
          servicesHtml += '<br> it has <input id="' + service.name + '_numberOfStoriesFoundWithinTheHoursSincePostedLimit" type="text" size="4" value="' + service.notableConditions.numberOfStoriesFoundWithinTheHoursSincePostedLimit + '"/> or related stories
            <br> posted within  <input id="' + service.name + '_numberOfRelatedItemsWithClusterURL" type="text" size="4" value="' + service.notableConditions.numberOfRelatedItemsWithClusterURL + '"/> hours
            </div>
            </td>
          </tr></tbody></table>
          </div>'
          console.log 'trying to set with ' + service.notableConditions.hoursSincePosted + '"/> or fewer hours since posting - or'
        
          
        
        else
        
          servicesHtml +=  '<br> URL is an exact match, and:
          <br> it has been <input id="' + service.name + '_hoursNotable" type="text" size="4" value="' + service.notableConditions.hoursSincePosted + '"/> or fewer hours since posting <br> - or - 
          <br> it has <input id="' + service.name + '_commentsNotable" type="text" size="4" value="' + service.notableConditions.num_comments + '"/> or more comments
            </div>
            </td>
          </tr></tbody></table>
          </div>'
          console.log 'trying to set with ' + service.notableConditions.hoursSincePosted + '"/> or fewer hours since posting - or'
        
        
      servicesHtml += '<div class="serviceListing">
        
        add service! (tweet)
        
        </div>'
      
      $("#servicesInfoDrop").html(servicesHtml)
      
      views[viewName].bind(popupParcel)
      
    bind: (popupParcel) ->
      viewName = 'userPreferences'
      
      saveButtons = $(".userPreferencesSave")
      
      saveButtons.attr('disabled','disabled')
      
      
      
      views[viewName].elsToUnbind.push saveButtons
      
      autoTimerRadios = $("input:radio[name='researchAutoOffType']")
      
      allInputs = $('#userPreferencesSave input')
      
      views[viewName].elsToUnbind.push allInputs
      
      allInputs.bind 'change', ->
        $(".userPreferencesSave").removeAttr('disabled')
      
      $("#userPreferencesView input").bind 'focus', ->
        $(".userPreferencesSave").removeAttr('disabled')
      
      if $("input:radio[name='researchAutoOffType']:checked").val() is 'custom'
        $("#autoCustomValue").removeAttr('disabled')
        
      autoTimerRadios.bind 'change', ->
        if $("input:radio[name='researchAutoOffType']:checked").val() is 'custom'
          $("#autoCustomValue").removeAttr('disabled')
        else
          $("#autoCustomValue").attr('disabled','disabled')
      
      
      bindDown = (downButton, index) ->
        downButton.bind 'click', ->    
          popupParcel.kiwi_servicesInfo = moveArrayElement(popupParcel.kiwi_servicesInfo, index, index + 1)
          
          parcel =
            refreshView: 'userPreferences'
            keyName: 'kiwi_servicesInfo'
            newValue: popupParcel.kiwi_servicesInfo
            localOrSync: 'sync'
            
            msg: 'kiwiPP_post_save_a_la_carte'
          
          sendParcel(parcel)
      
      bindUp = (upButton, index) ->
        upButton.bind 'click', ->
          
          popupParcel.kiwi_servicesInfo = moveArrayElement(popupParcel.kiwi_servicesInfo, index, index - 1 )
          
          parcel =
            refreshView: 'userPreferences'
            keyName: 'kiwi_servicesInfo'
            newValue: popupParcel.kiwi_servicesInfo
            localOrSync: 'sync'
            msg: 'kiwiPP_post_save_a_la_carte'
          
          sendParcel(parcel)
      
      for service,index in popupParcel.kiwi_servicesInfo
        downButton = $("#" + service.name + '_moveServiceDown')
        if downButton.length > 0
          views[viewName].elsToUnbind.push downButton
          bindDown(downButton, index)
            
        upButton = $("#" + service.name + '_moveServiceUp')
        if upButton.length > 0
          views[viewName].elsToUnbind.push upButton
          bindUp(upButton, index)
        
      postError = (userErrMsg) ->
        
        $("#" + viewName + "View .userErrMsg").html(userErrMsg)
        
      saveButtons.bind 'click', ->
        
        researchModeHTMLval = $("input:radio[name='research']:checked").val()
        console.log 'researchModeHTMLval is ' + researchModeHTMLval
        if researchModeHTMLval != 'on' and researchModeHTMLval != 'off'
          postError('research mode must be "on" or "off"'); return 0;
        
        allowedAutoOffTypes = ["20","60","always","custom"]
        
        autoOffTimerType = $("input:radio[name='researchAutoOffType']:checked").val()
        
        autoOffTimerValue = $("#autoCustomValue").val()
        
        if autoOffTimerType in allowedAutoOffTypes
          if autoOffTimerType == 'custom' and (autoOffTimerValue == '' or isNaN(autoOffTimerValue))
            postError('Must specify a number of minutes for auto-off timer.'); return 0;
        else
          postError('not acceptable autoOffTimerType'); return 0;
        
        # autoOffAtUTCmilliTimestamp
        
        
        for service, index in popupParcel.kiwi_servicesInfo
          
          if service.name == 'gnews'
            
            active = $("input:radio[name='" + service.name + "_serviceStatus']:checked").val()
            if active != 'on' and active != 'off'
              postError('active must be "on" or "off"'); return 0;
              
            numberOfStoriesFoundWithinTheHoursSincePostedLimit = $('#' + service.name + '_numberOfStoriesFoundWithinTheHoursSincePostedLimit').val()
            if numberOfStoriesFoundWithinTheHoursSincePostedLimit == '' or isNaN(numberOfStoriesFoundWithinTheHoursSincePostedLimit)
              postError('number Of Stories Found Within The Hours Since Posted Limit must be an integer'); return 0;
            
            numberOfRelatedItemsWithClusterURL = $('#' + service.name + '_numberOfRelatedItemsWithClusterURL').val()
            if numberOfRelatedItemsWithClusterURL == '' or isNaN(numberOfRelatedItemsWithClusterURL)
              postError('number Of Related Items With Cluster URL of comments must be an integer'); return 0;
          
          else
            active = $("input:radio[name='" + service.name + "_serviceStatus']:checked").val()
            if active != 'on' and active != 'off'
              postError('active must be "on" or "off"'); return 0;
              
            hoursSincePosted = $('#' + service.name + '_hoursNotable').val()
            if hoursSincePosted == '' or isNaN(hoursSincePosted)
              postError('Hours must be an number'); return 0;
            
            num_comments = $('#' + service.name + '_commentsNotable').val()
            if num_comments == '' or isNaN(num_comments)
              postError('Number of comments must be an integer'); return 0;

          
        popupParcel.kiwi_userPreferences.researchModeOnOff = researchModeHTMLval
        
        if (autoOffTimerType != 'custom')
          popupParcel.kiwi_userPreferences.autoOffTimerType = autoOffTimerType
        else  
          popupParcel.kiwi_userPreferences.autoOffTimerType = autoOffTimerType
          popupParcel.kiwi_userPreferences.autoOffTimerValue = parseFloat(autoOffTimerValue)
        
        for service, index in popupParcel.kiwi_servicesInfo
          
          active = $("input:radio[name='" + service.name + "_serviceStatus']:checked").val()
          popupParcel.kiwi_servicesInfo[index].active = active
          
          hoursSincePosted = $('#' + service.name + '_hoursNotable').val()
          popupParcel.kiwi_servicesInfo[index].notableConditions.hoursSincePosted = parseFloat(hoursSincePosted)
          
          num_comments = $('#' + service.name + '_commentsNotable').val()
          popupParcel.kiwi_servicesInfo[index].notableConditions.num_comments = parseInt(num_comments)
          
        popupParcel.view = 'userPreferences'
        
        parcel =
          refreshView: popupParcel.view
          newPopupParcel: popupParcel
          msg: 'kiwiPP_post_savePopupParcel'
        
        sendParcel(parcel)
        
  credits:
    elsToUnbind: []
    
    render: (popupParcel) ->
      'http://glyphicons.com/'
      viewName = 'credits'
      vFs.unbindView(viewName) # prevents redundant bindings
      vFs.showViewAndBindGoToViewButtons(viewName, popupParcel)



tailorResults = 
  gnews: (serviceInfoObject, serviceResults) ->
    # preppedHTMLstring = ''
    # for listing, index in serviceResults.service_PreppedResults
    preppedHTMLstring = ""
    preppedHTMLstring += "<br>" + serviceInfoObject.title + "<br>"
    if serviceResults.service_PreppedResults? and serviceResults.service_PreppedResults.length > 0
      preppedHTMLstring += "
        Searched for: " + serviceResults.service_PreppedResults[0].kiwi_searchedFor + "<br>
        
        results are good" + serviceResults.service_PreppedResults[0].kiwi_exact_match + "<br>"
    
    serviceResults.service_PreppedResults = _.sortBy(serviceResults.service_PreppedResults, 'clusterUrl')
    serviceResults.service_PreppedResults.reverse()
    
    
    # clusterUrl
    # publisher
    # content
    # publishedDate
    # unescapedUrl
    # titleNoFormatting
    console.log 'console.debug serviceResults.service_PreppedResults'
    console.debug serviceResults.service_PreppedResults
    
    for listing, index in serviceResults.service_PreppedResults
      
      preppedHTMLstring += '<div class="listing" style="position:relative;">
        <a class="listingTitle" target="_blank" href="' + listing.unescapedUrl + '">
          ' + listing.titleNoFormatting + '<br>'
      
      _time = formatTime(listing.kiwi_created_at)
      
      preppedHTMLstring += listing.publisher + ' -- ' + _time + '</a>
      <br>' + listing.content + '<br>'
      if listing.clusterUrl != ''
        preppedHTMLstring += '<a target="_blank" href="' + listing.clusterUrl + '"> Google News cluster </a>'
      preppedHTMLstring += '</a>
        </div><br>'
        
    
    return preppedHTMLstring
    
  hackerNews: (serviceInfoObject, serviceResults) ->
    return tailorRedditAndHNresults_returnHtml(serviceInfoObject, serviceResults)
    
  reddit: (serviceInfoObject, serviceResults) ->
    return tailorRedditAndHNresults_returnHtml(serviceInfoObject, serviceResults)
    
    
tailorRedditAndHNresults_returnHtml = (serviceInfoObject, serviceResults) ->
  # reddit:
    preppedHTMLstring = ''
    
    # kiwi_exact_match
    
      # fuzzy matches
    
    # linkify stuff
    
    fuzzyMatchBool = false
    
    preppedHTMLstring += "<br>" + serviceInfoObject.title + "<br>"
    
    serviceResults.service_PreppedResults = _.sortBy(serviceResults.service_PreppedResults, 'num_comments')
    serviceResults.service_PreppedResults.reverse()
    
    for listing, index in serviceResults.service_PreppedResults
      
      if listing.kiwi_exact_match
        preppedHTMLstring += '<div class="listing" style="position:relative;">'
        preppedHTMLstring += '<a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.kiwi_permaId + '">'
        
        if listing.over_18? and listing.over_18 is true
          preppedHTMLstring += '<span class="nsfw">NSFW</span>' + listing.title + '<br>'
        else
          preppedHTMLstring += listing.title + '<br>'
        
        _time = formatTime(listing.kiwi_created_at)
        
        preppedHTMLstring += listing.num_comments + ' comments, ' + listing.kiwi_score + ' upvotes -- ' + _time + '</a>'
        
        if listing.subreddit?
          preppedHTMLstring +=  '<br><span>'
          preppedHTMLstring += '<a target="_blank" href="' + serviceInfoObject.permalinkBase + '/r/' + listing.subreddit + '">'
          preppedHTMLstring += 'subreddit: ' + listing.subreddit + '</a></span>'
        
        preppedHTMLstring += '<div style="float:right;">'
        preppedHTMLstring +=    '<a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '</a>'
        preppedHTMLstring += '</div></div><br>'
        
      else
        fuzzyMatchBool = true
    
    if fuzzyMatchBool
      preppedHTMLstring += '<br><div class="showFuzzyMatches" style="position:relative;"> Show fuzzy matches </div><br><span class="fuzzyMatches">'
      
      for listing, index in serviceResults.service_PreppedResults
        
        if !listing.kiwi_exact_match
          preppedHTMLstring += '<div class="listing">'
          preppedHTMLstring += '<a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.kiwi_permaId + '">'
          
          preppedHTMLstring += 'for Url: <span class="altURL">' + listing.url + '<br>'
          
          if listing.over_18? and listing.over_18 is true
            preppedHTMLstring += '<span class="nsfw">NSFW</span>' + listing.title + '<br>'
          else
            preppedHTMLstring += listing.title + '<br>'
          
          preppedHTMLstring += listing.num_comments + ' comments, ' + listing.kiwi_score + ' upvotes ' + formatTime(listing.kiwi_created_at) + '</a>'
          
          if listing.subreddit?
            preppedHTMLstring +=  '<br><span>'
            preppedHTMLstring += '<a target="_blank" href="' + serviceInfoObject.permalinkBase + '/r/' + listing.subreddit + '">'
            preppedHTMLstring += 'subreddit: ' + listing.subreddit + '</a></span>'
          
          preppedHTMLstring +=  '<div style="float:right;">'
          preppedHTMLstring += '<a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '</a></div>'
          preppedHTMLstring += '</div><br>'
          
      
      preppedHTMLstring += "</span>" 
    
    return preppedHTMLstring
    




bindGoToViewButtons = (buttonEls, viewName, viewData) ->
  for el in buttonEls
    $(el).bind('click', (ev) ->
      console.log 'clicked ' + viewName
      views[viewName].render(viewData)
    )





receiveParcel  = (parcel) ->
  
  if !parcel.msg?
    
    return false
    
  
  switch parcel.msg
    
    when 'kiwiPP_popupParcel_ready' 
    
      chrome.tabs.query({ currentWindow: true, active: true }, (tabs) ->
      # chrome.tabs.getSelected(null,(tab) ->
        if tabs.length > 0 and tabs[0].status is "complete"
          if tabs[0].url.indexOf('chrome-devtools://') != 0
          
            tabUrl = tabs[0].url
            if tabs[0].url is parcel.forUrl
            
              console.log "when 'popupParcel_ready' parcel"
              console.debug parcel
              
              initialize(parcel.popupParcel)
              
          else 
            console.log 'chrome-devtools:// '
            return 0  
          
          # # $("#landingStatusBox").html('Summaries available! :)')
      )



sendParcel = (parcel) ->
  console.log 'wtf sent'
  port = chrome.extension.connect({name: "kiwi_fromBackgroundToPopup"})
  
  # chrome.tabs.getSelected(null,(tab) ->
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) ->
    if tabs.length > 0 and tabs[0].status is "complete"
      if tabs[0].url.indexOf('chrome-devtools://') != 0
        
        parcel.forUrl = tabs[0].url
      
        if !parcel.msg?
          return false
        
        switch parcel.msg
          when 'kiwiPP_request_popupParcel'
            port.postMessage(parcel)
          when 'kiwiPP_post_savePopupParcel'
            port.postMessage(parcel)
          when 'kiwiPP_post_save_a_la_carte'
            port.postMessage(parcel)
          when 'kiwiPP_clearAllURLresults'
            port.postMessage(parcel)
          when 'kiwiPP_refreshURLresults'
            port.postMessage(parcel)
          when 'kiwiPP_researchUrlOverrideButton'
            port.postMessage(parcel)
      else 
        console.log 'chrome-devtools:// '
        return 0     
  )
  
  # listen for other messages
chrome.extension.onConnect.addListener((port) ->  
  if port.name is 'kiwi_fromBackgroundToPopup'
    
    port.onMessage.addListener((pkg) ->
      receiveParcel(pkg)
    )
)
  
moveArrayElement = (array, from, to) ->
  array.splice(to, 0, array.splice(from, 1)[0]);
  return array

getRandom = (min, max) ->
  return min + Math.floor(Math.random() * (max - min + 1))


formatTime = (utcMillisecondTimestamp) ->
  a = new Date(utcMillisecondTimestamp)
  months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  year = a.getFullYear()
  month = months[a.getMonth()]
  date = a.getDate()
  hour = a.getHours()
  min = a.getMinutes()
  sec = a.getSeconds()
  time = month + ' ' + date + ', ' + year + ' ' + hour + ':' + min + ':' + sec 
  return time
  
renderExtensionHeight = (elementId, extraPx) ->
  if viewElementId is elementId
    extraPx = 2
    extHeight_ = $('#' + elementId).outerHeight() + extraPx
    
    if extHeight_ > 590
      extHeight_ = 590
      
    # $('html').css('height',extHeight+'px')
    $('body').css('height', extHeight_ + 'px')
    `heightString = extHeight_.toString() +'px'`
    $('html').css('min-height', heightString)
    extHeight_--
    $('body').css('min-height', heightString)
    
capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

# // http://css-tricks.com/snippets/javascript/htmlentities-for-javascript/
htmlEntities = (str) ->
  return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

getURLParam = (oTarget, sVar) ->
  return decodeURI(oTarget.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURI(sVar).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));


console.log 'trying to send123'

$().ready(
  sendParcel({'msg':'kiwiPP_request_popupParcel'})
)

