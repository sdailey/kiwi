# console.log 'opened'
viewElementId = ''

renderedBool = false

preferencesOnlyPage = false

initialize = (popupParcel) ->
  console.log 'in init with popupParcel'
  console.debug popupParcel
  
  if getURLParam(window.location, 'optionsOnly') != ''
    preferencesOnlyPage = true
    switchViews.userPreferences.render(popupParcel)
    return 0
    
  for viewName, view of fixedViews
    view.init(popupParcel)
    
  # views.userPreferences.render(popupParcel)
  if popupParcel.view? and switchViews[popupParcel.view]?
    switchViews[popupParcel.view].render(popupParcel)
    
  else
    switchViews.conversations.render(popupParcel)


class Widget # basic building block
  constructor: (@name, @parentView, @__renderStates__) ->
    @elsToUnbind = []
    @totalRenders = 0
    @DOMselector = @parentView.DOMselector + " #" + @name + "_Widget"
    
    @Widgets = {}
    
    @bindAllGoToViewButtons = (viewData) =>
      # console.log '@bindAllGoToViewButtons = (viewData) =>'
      # console.log @DOMname
      
      for _viewName, viewValue of switchViews
        # console.log _viewName
        # bind to goToView buttons
        els_goTo_view = $(@DOMselector + ' .goTo_' + _viewName + 'View')
        # console.debug els_goTo_view
        @elsToUnbind.push els_goTo_view
        bindGoToViewButtons(els_goTo_view, _viewName, viewData)
  
    @unbindWidget = =>
      for el in @elsToUnbind
        el.unbind()
      @elsToUnbind = []
      
      for widget in @Widgets
        widget.unbindWidget()
      
    @render = (renderState, popupParcel) =>
      @totalRenders++
      @unbindWidget(@name)
      
      @renderStates[renderState].paint(popupParcel)
      
      @bindAllGoToViewButtons(popupParcel)
      
      @renderStates[renderState].bind(popupParcel)
    
    @renderStates = @__renderStates__()
    return @



class MessageCenter extends Widget
  constructor: (@name, @parentView, @widgetOpenBool) ->
    # console.debug @__renderStates__
    # console.log ' trying '
    
    super @name, @parentView, @__renderStates__
    
  init: (popupParcel) ->
    @unbindWidget()
    
    @render('showMessages',popupParcel)
    
  __renderStates__: =>
    showMessages: 
      paint: (popupParcel) =>
        # console.log 'messagesHTML = ""
          # console.debug popupParcel'
        messagesHTML = ""
        # console.debug popupParcel
        
        if popupParcel.kiwi_userMessages.length > 0
          
          messagesHTML += '<div style="padding-top:4px; padding-bottom:10px;">' 
          for messageObj in popupParcel.kiwi_userMessages
            messagesHTML += '<div class="bg-warning" style="margin:6px; padding:8px; text-align:justify;"> 
              <button style="float:right; margin:8px; padding:4px; padding-right:6px; padding-left:6px;" class="btn btn-xs btn-default acknowledgeMessage" data-messageToAcknowledge="' + messageObj.name + '" > 
                <span title="remove" data-messageToAcknowledge="' + messageObj.name + '"
                    class="glyphicon glyphicon-remove" aria-hidden="true"
                    style="color:#E65F5F;"
                  ></span>
              </button>
              ' + messageObj.baseValue + ' &nbsp;
              
              </div>'
          messagesHTML += '<div style="width:100%; text-align:center;"> <b>message priority</b>: urgent. &nbsp;&nbsp; 
              please acknowledge the message(s) by clicking the "x" button(s). Thanks! :)
            </div></div>'
          
        $(@DOMselector).html(messagesHTML)
        
        # $(@DOMselector + " .notFixed").css({'height':fixedHeight + "px"})
        
      bind: (popupParcel) =>
        
        if popupParcel.kiwi_userMessages.length > 0
          
          
          # console.log 'bind: (popupParcel) =>'
          ackMessageButtons = $(@DOMselector + ' .acknowledgeMessage')
          
          @elsToUnbind = @elsToUnbind.concat ackMessageButtons
          
          ackMessageButtons.bind 'click', (ev) =>
            # console.log "trying for ackMessageButtons.bind 'click', (ev) =>"
            messageToAcknowledge = $(ev.target).attr('data-messageToAcknowledge')
            # console.log 'messageToAcknowledge ' + messageToAcknowledge
            # console.debug popupParcel.kiwi_userPreferences.urlSubstring_whitelists.anyMatch
            # console.debug whitelistSubString
            
            
            parcel =
              messageToAcknowledge: messageToAcknowledge
              msg: 'kiwiPP_acknowledgeMessage'
            
            sendParcel(parcel)
        
        
class CustomSearch extends Widget
  constructor: (@name, @parentView, @widgetOpenBool) ->
    # console.debug @__renderStates__
    
    super @name, @parentView, @__renderStates__
    
  init: (popupParcel) ->
    @Widgets = {messageCenter: new MessageCenter 'messageCenter', @, false}
    @unbindWidget()
    if @widgetOpenBool == false
      @render('collapsed',popupParcel)
    else
      @render('opened',popupParcel)
  
  __renderStates__: =>
    collapsed: 
      paint: (popupParcel) =>
        
        openedCustomSearchHTML = '
          <div class="topSearchBar" style="padding-bottom: 14px;">
            <div class="evenlySpacedContainer">
              <input class="queryInputOpen" id="customSearchQueryInput" type="text" placeholder=" combined search" />
              <button class="btn btn-mini btn-default goTo_userPreferencesView">User Options 
              <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span></button> 
            </div>
          '
          
        if popupParcel.kiwi_customSearchResults.queryString? and popupParcel.kiwi_customSearchResults.queryString != ''
          openedCustomSearchHTML += "<div style='padding-top: 12px;'><a id='openPreviousSearch'>see custom results for '" + popupParcel.kiwi_customSearchResults.queryString + "'
            </a> &nbsp;&nbsp;&nbsp;&nbsp; <a id='clearPreviousSearch'>clear</a></div>"
        openedCustomSearchHTML += "
          <div id='messageCenter_Widget'></div>
        </div>
          <div class='notFixed'></div>"
        $(@DOMselector).html(openedCustomSearchHTML)
        
        # console?.log 'console.log @DOMselector + " .topSearchBar"' + @DOMselector + " .topSearchBar"
        
        duplicateFixedHeight = =>
          fixedElHeight = $(@DOMselector + " .topSearchBar").outerHeight()
          # console.log 'console.log fixedElHeight closed'
          # console.log fixedElHeight
          
          if popupParcel.kiwi_userMessages? and popupParcel.kiwi_userMessages.length > 0
            fixedElHeight += 70 + popupParcel.kiwi_userMessages.length * 60
            
          
          if fixedElHeight == 0
            setTimeout -> # defer to next browser event tick
                duplicateFixedHeight()
              , 0
          else
            $(@DOMselector + " .notFixed").css({'height':fixedElHeight + "px"})
        
        duplicateFixedHeight()
        @Widgets.messageCenter.render('showMessages', popupParcel)
        # $(@DOMselector + " .notFixed").css({'height':fixedHeight + "px"})
        
      bind: (popupParcel) =>
        # console.log 'bind: (popupParcel) =>'
        inputSearchQueryInput = $("#customSearchQueryInput")
        previousSearchLink = $("#openPreviousSearch")
        clearPreviousSearch = $("#clearPreviousSearch")
        
        @elsToUnbind = @elsToUnbind.concat inputSearchQueryInput, previousSearchLink, clearPreviousSearch
        
        previousSearchLink.bind 'click', ->
          $("#customSearchQueryInput").click()
        
        clearPreviousSearch.bind 'click', ->
          parcel =
            msg: 'kiwiPP_refreshSearchQuery'
          sendParcel(parcel)
            
        inputSearchQueryInput.bind 'click', =>
          # console.log '@widgetOpenBool = true'
          @widgetOpenBool = true
          @render('opened',popupParcel)
          
          
    opened: 
      
      paint: (popupParcel) =>
        # console.log 'popupParcel.kiwi_servicesInfo.length'
        # console.log popupParcel.kiwi_servicesInfo.length
        
        
        
        queryString = if popupParcel.kiwi_customSearchResults.queryString? then popupParcel.kiwi_customSearchResults.queryString else ''
        
        openedCustomSearchHTML = '<div class="topSearchBar">
          <div class="evenlySpacedContainer">
            <input id="customSearchQueryInput" value="' + queryString + '" type="text" placeholder=" combined search" style="width:234px; margin-right: 10px;" />
            <button  class="btn btn-mini btn-default" id="customSearchQuerySubmit" style="margin-right: 10px;">Submit</button>
            <button style="" class="goTo_userPreferencesView btn btn-mini btn-default"> Options 
            <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span></button> 
          </div> 
            <br>
          <div class="evenlySpacedContainer" style="position: relative; top: -8px; margin-bottom: 3px;">'
        
        for serviceInfoObject in popupParcel.kiwi_servicesInfo
          
          openedCustomSearchHTML += '<div>'
          
          # console.log 'asdfasdf ' + serviceInfoObject.name
          # console.debug serviceInfoObject
          
          if serviceInfoObject.active == 'off' 
            serviceDisabledAttr = ' disabled title="Service must be active, can be changed in options." '
          else 
            serviceDisabledAttr = ' '
            
            
          if popupParcel.kiwi_customSearchResults.servicesSearchesRequested? and popupParcel.kiwi_customSearchResults.servicesSearchesRequested[serviceInfoObject.name]?
            activeClass = ' active '
            ariaPressedState = 'true'
          else if !popupParcel.kiwi_customSearchResults.servicesSearchesRequested?
            activeClass = if serviceInfoObject.active is 'off' then ' ' else ' active '
            ariaPressedState = if serviceInfoObject.active is 'off' then 'false' else 'true'
          else
            activeClass = ' '
            ariaPressedState = 'false'
          
          if serviceInfoObject.customSearchTags? and Object.keys(serviceInfoObject.customSearchTags).length > 0
            openedCustomSearchHTML += '<div class="btn-group">
              <button data-toggle="button" aria-pressed="' + ariaPressedState + '" autocomplete="off" ' + serviceDisabledAttr + ' 
                class="servicesToSearch btn btn-default btn-mini dropdownLabel ' + activeClass + '" data-serviceName="' + serviceInfoObject.name + '">
                  ' + serviceInfoObject.title + '
              </button>
              <button ' + serviceDisabledAttr + ' data-toggle="dropdown" class="btn btn-default dropdown-toggle ' + activeClass + ' 
                 dropDownPrefs_' + serviceInfoObject.name + '" data-placeholder="false"><span class="caret"></span></button>
              <ul class="dropdown-menu">'
            
            for tagName, tagObject of serviceInfoObject.customSearchTags
              
              if popupParcel.kiwi_customSearchResults.servicesSearchesRequested? and popupParcel.kiwi_customSearchResults.servicesSearchesRequested[serviceInfoObject.name]?
                if popupParcel.kiwi_customSearchResults.servicesSearchesRequested[serviceInfoObject.name].customSearchTags[tagName]?
                  tagActiveChecked = ' checked '
                else
                  tagActiveChecked = ''
              else
                tagActiveChecked = if tagObject.include is true then ' checked ' else ''
              
              tagDisabledAttr = if serviceInfoObject.active is 'off' then ' disabled title="Service must be active, can be changed in options." ' else ''
              
              openedCustomSearchHTML += '<li><input ' + tagActiveChecked + tagDisabledAttr + ' type="checkbox" value="' + tagName + '" class="tagPref tagPref_' + serviceInfoObject.name + '" id="' + serviceInfoObject.name + tagName + '">
                  <label for="' + serviceInfoObject.name + tagName + '">
                     ' + tagObject.title + '
                  </label></li>'
                    
            openedCustomSearchHTML += '</ul></div>'
            
          else
            
            openedCustomSearchHTML += '<button data-toggle="button" aria-pressed="' + ariaPressedState + '" autocomplete="off" 
                type="button" class="servicesToSearch btn btn-mini btn-default  ' + activeClass + '" data-serviceName="' + serviceInfoObject.name + '">
                  ' + serviceInfoObject.title + '
              </button>'
            
          openedCustomSearchHTML += '</div>'
        
        openedCustomSearchHTML += '<div> 
            <button aria-pressed="false" autocomplete="off" type="button" class="btn btn-mini btn-default" 
                id="close__' + @name + '"
              >
              close <span class="glyphicon glyphicon-remove" aria-hidden="true"></span> 
            </button>
          </div>  
        </div>'
        openedCustomSearchHTML += '
          <div id="messageCenter_Widget">asdfasd</div>
        </div>
          <div class="notFixed"></div>
          <div id="customSearchResults"></div>
        '
        
        
        resultsSummaryArray = []
        customSearchResultsHTML = ""
        if popupParcel.kiwi_customSearchResults? and popupParcel.kiwi_customSearchResults.queryString? and 
            popupParcel.kiwi_customSearchResults.queryString != ''
            
          for serviceInfoObject, index in popupParcel.kiwi_servicesInfo
            
            if popupParcel.kiwi_customSearchResults.servicesSearched[serviceInfoObject.name]?
              
              service_PreppedResults = popupParcel.kiwi_customSearchResults.servicesSearched[serviceInfoObject.name].results
              
              resultsSummaryArray.push("<a class='jumpTo' data-serviceindex='" + index + "'>" + serviceInfoObject.title + " (" + service_PreppedResults.length + ")</a>")
              
              customSearchResultsHTML += tailorResults[serviceInfoObject.name](serviceInfoObject, service_PreppedResults, popupParcel.kiwi_userPreferences)
              
              if service_PreppedResults.length > 14
                customSearchResultsHTML += '<div class="listing showHidden" data-servicename="' + serviceInfoObject.name + '"> show remaining ' + (service_PreppedResults.length - 11) + ' results</div>'
            else
              customSearchResultsHTML += '<br>No results for ' + serviceInfoObject.title + '<br>'
            
          # customSearchResultsHTML += '</div>'
          
        else
          customSearchResultsHTML += '<div id="customSearchResultsDrop"><br>No results to show... make a search! :) </div><br>'
        
        customSearchResultsHTML = "<div style='width: 100%; text-align: center;font-size:.9em;'>" + resultsSummaryArray.join(" - ") + "</div>" + customSearchResultsHTML
        
        
        customSearchResultsHTML += "<br>"
        
        $(@DOMselector).html(openedCustomSearchHTML)
        
        $(@DOMselector + " #customSearchResults").html(customSearchResultsHTML)
        
        $(@DOMselector + " .hidden_listing").hide()
        
        duplicateFixedHeight = =>
          fixedElHeight = $(@DOMselector + " .topSearchBar").outerHeight()
          # console.log 'console.log fixedElHeight opened'
          # console.log fixedElHeight
          
          if popupParcel.kiwi_userMessages? and popupParcel.kiwi_userMessages.length > 0
            fixedElHeight += 70 + popupParcel.kiwi_userMessages.length * 60
          
          if fixedElHeight == 0
            setTimeout -> # defer to next browser event tick
                duplicateFixedHeight()
              , 0
          else
            $(@DOMselector + " .notFixed").css({'height':fixedElHeight + "px"})
        
        duplicateFixedHeight()
        @Widgets.messageCenter.render('showMessages', popupParcel)
       
      bind: (popupParcel) =>
        
        
        customSearchQueryInput = $(@DOMselector + " #customSearchQueryInput")
        customSearchQuerySubmit = $(@DOMselector + " #customSearchQuerySubmit")
        closeWidget = $(@DOMselector + ' #close__' + @name)
        customSearch_sortByPref = $(@DOMselector + " .conversations_sortByPref")
        
        modifySearch = $(@DOMselector + " .customSearchOpen")
        
        elsServicesButtons = $(@DOMselector + " button.servicesToSearch ")
        
        elsServicesActivePrefs = $(@DOMselector + " .customSearchServicePref input")
        
        showHidden = $(@DOMselector + " .showHidden")
        
        jumpToServiceCustomResults = $(@DOMselector + " #customSearchResults .jumpTo")
        
        @elsToUnbind = @elsToUnbind.concat(customSearchQueryInput, closeWidget, customSearchQuerySubmit, elsServicesButtons, 
          customSearch_sortByPref, showHidden, jumpToServiceCustomResults, modifySearch)
        
        
        modifySearch.bind 'click', ->
          $(@DOMselector + " #customSearchQueryInput").focus()
        
        jumpToServiceCustomResults.bind 'click', (ev) =>
          serviceIndex = parseInt($(ev.target).data('serviceindex'))
          
          pxFromTop = $($(@DOMselector + " #customSearchResults .serviceResultJumpTo")[serviceIndex]).offset().top
          
          # offsetBy = $($(@DOMselector + " #customSearchResults .serviceResultJumpTo")[serviceIndex]).outerHeight() + 40
          
          $('body').scrollTop(pxFromTop - 100)
        
        showHidden.bind 'click', (ev) =>
          # console.log "showHidden.bind 'click', (ev) ->"
          # console.debug ev
          serviceName = $(ev.target).data('servicename')
          # resultsBox__" + serviceInfoObject.name + 
          # console.log @DOMselector + " .resultsBox__" + serviceName + " .hidden_listing"
          $(@DOMselector + " .resultsBox__" + serviceName + " .hidden_listing").show(1200)
          $(ev.target).remove()
          
        elsServicesButtons.bind('click', (ev) =>
            
            if $(ev.target).hasClass("dropdownLabel")
              serviceName = $(ev.target).attr('data-serviceName')
              # console.log serviceName
              # console.debug $(ev.target).attr('aria-pressed')
              ariaPressed = $(ev.target).attr('aria-pressed')
              
              if ariaPressed == 'true'
                $('button.dropDownPrefs_' + serviceName).removeClass('active')
                # console.log 'if ev.target.checked == "false" ' + serviceName
                $(@DOMselector + " input.tagPref_" + serviceName ).attr('disabled','disabled')
              else
                $('button.dropDownPrefs_' + serviceName).addClass('active')
                # console.log $(ev.target).attr('aria-pressed') + "asdfasdf"
                $(@DOMselector + " input.tagPref_" + serviceName ).removeAttr('disabled')
                
            $(ev.target).blur()
          )
        
        customSearch_sortByPref.bind 'change', (ev) ->
          
          # console.log ' customSearch_sortByPref.val()'
          # console.log 
          
          popupParcel.kiwi_userPreferences.sortByPref = $(ev.target).val()
          
          parcel =
            refreshView: 'conversations'
            keyName: 'kiwi_userPreferences'
            newValue: popupParcel.kiwi_userPreferences
            localOrSync: 'sync'
            
            msg: 'kiwiPP_post_save_a_la_carte'
          
          sendParcel(parcel)
      
        sendSearch = =>
          
          queryString = customSearchQueryInput.val()
          
          elsServicesToSearch = $(@DOMselector + ' button.servicesToSearch[aria-pressed="true"]')
          
          # ariaPressed = $(ev.target).attr('aria-pressed')
          # if ariaPressed == 'true'
          
          servicesToSearch = {}
          
          for el in elsServicesToSearch
            serviceName = $(el).attr('data-serviceName')
            
            servicesToSearch[serviceName] = {}
            servicesToSearch[serviceName].customSearchTags = {}
            
            elTagPrefs = $(@DOMselector + " input.tagPref_" + serviceName + ":checked")
            
            for elTagPref in elTagPrefs 
              tagName = $(elTagPref).val()
              servicesToSearch[serviceName].customSearchTags[tagName] = {}
          
          # console.log 'asfdasdfasdf ' + serviceName
          # console.debug servicesToSearch
          
          if queryString != ''
            parcel =
              msg: 'kiwiPP_post_customSearch'
              customSearchRequest:
                queryString: queryString
                servicesToSearch: servicesToSearch
            sendParcel(parcel)
        
        customSearchQueryInput.keypress (event) ->
          charCode = if event.keyCode then event.keyCode else event.which
          if charCode == 13
            sendSearch()
        
        customSearchQuerySubmit.bind 'click', =>
          sendSearch()
          
          
        closeWidget.bind 'click', =>
          @widgetOpenBool = false
          @render('collapsed',popupParcel)
        
        customSearchQueryInput.focus()
    
    

# showViewAndBindGoToViewButtons

class View # basic building block
  constructor: (@name, @__renderStates__) ->
    @elsToUnbind = []
    @totalRenders = 0
    @DOMselector = "#" + @name + "_View"
    
    @Widgets = {}
    
    @bindAllGoToViewButtons = (viewData) =>
      
      for _viewName, viewValue of switchViews
        
        els_goTo_view = $(@DOMselector + ' .goTo_' + _viewName + 'View')
        
        @elsToUnbind.push els_goTo_view
        bindGoToViewButtons(els_goTo_view, _viewName, viewData)
  
      
      
      
    @renderStates = @__renderStates__()
    
    return @
    
  unbindView: =>
    # console.log 'unbinding view'
    # console.debug @elsToUnbind
    # $(".userPreferencesSave").unbind()
    for el in @elsToUnbind
      el.unbind()
    @elsToUnbind = []
    for widget in @Widgets
      widget.unbindWidget()
    
  render: (popupParcel, renderState = "__normal__") =>
    @totalRenders++
    @unbindView(@name)
    if !renderState? and !@renderStates.__normal__?
      console?.log 'ERROR: must declare renderState for view ' + @name + ' since __normal__ undefined'
      
    # console.log 'console.debug renderState ' + @name + renderState
    # console.log @totalRenders
    # console.debug @renderStates
    @renderStates[renderState].paint(popupParcel)
    
    @bindAllGoToViewButtons(popupParcel)
    
    @renderStates[renderState].bind(popupParcel)

class FixedView extends View
  constructor: (@name, @__renderStates__, uniqueSelectorPostfix) ->
    super @name, @__renderStates__
    @DOMselector += uniqueSelectorPostfix
    # console.log @DOMselector

class SwitchView extends View
  constructor: (@name, @__renderStates__) ->
    super @name, @__renderStates__
  
  showView: =>
    for _viewName, viewValue of switchViews
      if _viewName == @name
        # show
        # console.log 'showing ' + _viewName
        $('#' + _viewName + '_View').css({'display':'block'})
      else
        # hide
        # console.log 'hiding ' + _viewName
        $('#' + _viewName + '_View').css({'display':'none'})
  
  render: (popupParcel, renderState = "__normal__") =>
    super popupParcel, renderState
    @showView()
    
class Conversations extends SwitchView
  constructor: (@name) ->
    super @name, @__renderStates__
    
    @Widgets =
      customSearch: new CustomSearch 'customSearch', @, false
    
  init: (popupParcel) ->
    @unbindWidget()
    @render(popupParcel)
  
  __renderStates__: =>
    __normal__: 
      paint: (popupParcel) =>
        
        # console.log ' in conversations view'
        
        # console.debug popupParcel
        
        @Widgets['customSearch'].init(popupParcel)
          
        researchModeDisabledButtonsHTML = ''
        
        if popupParcel.urlBlocked == true or popupParcel.kiwi_userPreferences.researchModeOnOff == 'off' or (popupParcel.oldUrl? and popupParcel.oldUrl == true)
          
          researchModeDisabledButtonsHTML += "<br>
            <div style='width:100%;text-align: center;'><button class='btn btn-success' style='font-size: 1.1em;display: inline-block;' id='researchUrlOverride'>Research this Url</button></div>
          <br>"
          
        if popupParcel.kiwi_userPreferences.researchModeOnOff == 'off'
          
          researchModeDisabledButtonsHTML +=  "<br>
          <div style='width:100%; text-align:center;'>
            Research Mode is off: &nbsp; 
              <button class='goTo_userPreferencesView btn btn-xs btn-default' style='position:relative; bottom:2px;'>
                change settings 
              </button>
          </div>"
          
        $("#researchModeDisabledButtons").html(researchModeDisabledButtonsHTML)
        
        
        resultsSummaryArray = []
        
        resultsHTML = ""
        totalResults = 0
        
        for serviceInfoObject, index in popupParcel.kiwi_servicesInfo
          
          if popupParcel.allPreppedResults[serviceInfoObject.name]? and popupParcel.allPreppedResults[serviceInfoObject.name].service_PreppedResults.length > 0
            
            service_PreppedResults = popupParcel.allPreppedResults[serviceInfoObject.name].service_PreppedResults
            
            totalResults += service_PreppedResults.length
            brandedTitle = if (serviceInfoObject.name is 'reddit') then "for " + serviceInfoObject.title else serviceInfoObject.title
            resultsSummaryArray.push("<a class='jumpTo' data-serviceindex='" + index + "'>" + brandedTitle + " (" + service_PreppedResults.length + ")</a>")
            
            resultsHTML += tailorResults[serviceInfoObject.name](serviceInfoObject, service_PreppedResults, popupParcel.kiwi_userPreferences)
            
            if service_PreppedResults.length > 14
              resultsHTML += '<div class="listing showHidden" data-servicename="' + serviceInfoObject.name + '"> show remaining ' + (service_PreppedResults.length - 11) + ' results</div>'
          else
          
            if serviceInfoObject.active is 'on'
              if serviceInfoObject.submitTitle?
                
                submitUrl = serviceInfoObject.submitUrl
                submitTitle = serviceInfoObject.submitTitle
                resultsHTML += '<div class="serviceResultJumpTo">No conversation matches for ' + serviceInfoObject.title + '... <br> 
                  &nbsp;&nbsp;&nbsp;<a target="_blank" href="' + submitUrl + '">' + submitTitle + '</a></div><br>'
                
              else
                
                resultsHTML += '<div>No results for ' + serviceInfoObject.title + '</div>'
            else  
              
              resultsHTML += '<div>' + serviceInfoObject.title + ' has been toggled "off" in settings. <br>
                &nbsp;&nbsp;&nbsp;<button class="goTo_userPreferencesView btn btn-xs btn-default" style="position:relative; bottom:2px;">
                  go to settings 
                </button> to toggle back on.
              </div>'
              
        preppedHTMLstring = ''
        
        if (popupParcel.urlBlocked == true and Object.keys(popupParcel.allPreppedResults).length < 2)  
          # do nothing
          preppedHTMLstring += "<div style='width: 100%; text-align: justify; padding:20px; font-size:.9em; opacity:.9;'>
              <em>
                Certain super-high traffic URLs 
                (or weird urls (like 'about:config' and chrome new tab pages)) have been
                excluded from auto-search out of respect for the APIs of the conversation sites. you can still manually
                search them by hitting the green button
              </em>
            </div><br>"
        else if ((totalResults > 0 and popupParcel.kiwi_userPreferences.researchModeOnOff == 'off') or 
            popupParcel.kiwi_userPreferences.researchModeOnOff == 'on' or
            Object.keys(popupParcel.allPreppedResults).length > 1)
          preppedHTMLstring = '<br><h3 style="position:relative; top:-10px;">Results for this URL:</h3>'
          preppedHTMLstring += "<div style='width: 100%; text-align: center;font-size:.9em;'>" + resultsSummaryArray.join(" - ") + "</div><br>"
          preppedHTMLstring += resultsHTML
          
        $("#resultsByService").html(preppedHTMLstring)
        $(@DOMselector + " .hidden_listing").hide()
        # console.log 'console.log $("#resultsByService").outerHeight()'
        # console.log $("#resultsByService").outerHeight()
        
        if totalResults < 4 and @totalRenders < 4
          fixedViews.kiwiSlice.render(popupParcel, "open")
          
        setTimeout( -> # to reign in a chrome rendering issue
            # renderExtensionHeight(@DOMselector, 1)
            $($('input')[0]).blur()
            $($('a')[0]).blur()
            $($('button')[0]).blur()
          , 300
        )
        # renderExtensionHeight(@DOMselector, 1)
        $($('input')[0]).blur()
        $($('a')[0]).blur()
        $($('button')[0]).blur()
        
        
      bind: (popupParcel) =>
        
        
        
        showHidden = $(@DOMselector + " .showHidden")
        
        researchUrlOverrideButton = $(@DOMselector + " #researchUrlOverride")
        
        conversations_sortByPref = $(@DOMselector + " .conversations_sortByPref")
        
        customSearchOpen = $(@DOMselector + " .customSearchOpen")
        
        jumpToService = $(@DOMselector + " #resultsByService .jumpTo")
        
        @elsToUnbind = @elsToUnbind.concat(conversations_sortByPref, showHidden, researchUrlOverrideButton, customSearchOpen, jumpToService)
          
        jumpToService.bind 'click', (ev) =>
          serviceIndex = parseInt($(ev.target).data('serviceindex'))
          
          # console.log serviceIndex
          pxFromTop = $($(@DOMselector + " #resultsByService .serviceResultJumpTo")[serviceIndex]).offset().top
          # console.log 'pxFromTop = $($(@DOMselector + " #resultsByService .serviceResultJumpTo")[serviceIndex]).offset().top'
          # console.log $($(@DOMselector + " #resultsByService .serviceResultJumpTo")[serviceIndex]).offset().top
          # offsetBy = $($(@DOMselector + " #resultsByService .serviceResultJumpTo")[serviceIndex]).outerHeight() + 40
          # console.log $($(@DOMselector + " #resultsByService .serviceResultJumpTo")[serviceIndex]).outerHeight() + 40
          $('body').scrollTop(pxFromTop - 100)
          
        
        customSearchOpen.bind 'click', ->
          $("#customSearchQueryInput").click()
        
        researchUrlOverrideButton.bind 'click', ->
          parcel =
            msg: 'kiwiPP_researchUrlOverrideButton'
          sendParcel(parcel)
        
        showHidden.bind 'click', (ev) =>
          # console.log "showHidden.bind 'click', (ev) -> "
          # console.debug ev
          serviceName = $(ev.target).data('servicename')
          $(@DOMselector + " .resultsBox__" + serviceName + " .hidden_listing").show(1200)
          $(ev.target).remove()
          
        conversations_sortByPref.bind 'change', (ev) ->
          
          # console.log "'conversations_sortByPref.bind 'change', (ev) ->"
          # console.log $(ev.target).val()
          popupParcel.kiwi_userPreferences.sortByPref = $(ev.target).val()
          
          parcel =
            refreshView: 'conversations'
            keyName: 'kiwi_userPreferences'
            newValue: popupParcel.kiwi_userPreferences
            localOrSync: 'sync'
            
            msg: 'kiwiPP_post_save_a_la_carte'
          
          sendParcel(parcel)
        
    
class UserPreferences extends SwitchView
  constructor: (@name) ->
    super @name, @__renderStates__
    
  init: (popupParcel) ->
    @unbindWidget()
    @render(popupParcel)
  
  __renderStates__: =>
    __normal__: 
      paint: (popupParcel) =>
        
        $(@DOMselector + " .userErrMsg").html('')
        
        # console.log 'paint: adsfaeaewfawefawefawef(popupParcel) =># viewName = '
        
        if preferencesOnlyPage is true
          $("#menuBar_preferences").hide()
        
        currentTime = Date.now()
        if popupParcel.kiwi_userPreferences.researchModeOnOff == "off"
          $("#autoOffTimer").html("Research mode is off, so auto-off timer is not set")
        else if popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp? and popupParcel.kiwi_userPreferences.autoOffAtUTCmilliTimestamp > currentTime
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
            <a class="tooltipCustom" style="position: relative;">
              <div style="display:inline; font-size:.9em;"><sup><em> ?</em></sup></div>
              <span style="bottom:34px; left:-114px;">
                When the Research mode is "Off", Kiwi won\'t automatically search URLs as you surf;
                 instead, you can check URLs on a case-by-case basis (and still be able to do custom searches)
              </span>
            </a> 
            
            <label style="font-weight: normal;" for="researchmodeON"> on </label> <input id="researchmodeON" type="radio" name="research" value="on" ' + researchOnString + '> - 
            <label style="font-weight: normal;" for="researchmodeOFF"> off </label> <input id="researchmodeOFF" type="radio" name="research" value="off" ' + researchOffString + '> 
            &nbsp;&nbsp;<button class="btn btn-mini btn-default userPreferencesSave"> save preferences </button><br>'
        
        if popupParcel.kiwi_userPreferences.researchModeOnOff is 'off'
          researchModeHtml += ''
          timerDisabled = ' disabled '
          timerOnlyUsefulWhenMessage = '<br>
            <span style="font-size:.8em;"><i>
              &nbsp;&nbsp;Note: the auto-off-timer only matters when Research Mode is "on".
            </i></span>
          <br>'
              
        else
          timerDisabled = ' '
          researchModeHtml += '<br>
            <span style="font-size:.8em;"><i>
              Note: The Whitelist only makes a difference when Research mode is turned "off", which it currently isn\'t.
            </i></span>
          <br>'
          timerOnlyUsefulWhenMessage = ''
          
        researchModeHtml += ' 
          <br>
          <table class="table table-bordered table-striped whitelistTable">
            <thead>
              <tr>
                <th colspan="3">  
                    <div class="input-group" id="addWhiteListString">
                      <label class="input-group-addon">
                        <a class="tooltipCustom" style="position: relative;">
                          <div style="display:inline; font-size:.9em;">whitelist strings <sup><em> ?</em></sup></div>
                          <span style="bottom:84px;left:-12px;">
                            
                            <b>Whitelist strings:</b> <br>
                            Kiwi will automatically research any URL (upon visiting) that contains a user-provided Whitelist string --
                            even when Research Mode is "off". 
                            Try it with "github.com" or "bitbucket.org", and then visit the respective site with research mode "off".
                            
                          </span>
                        </a>
                      </label>
                      
                      <input type="text" class="form-control ignoreSaveButtonListen">
                        
                      <label class="input-group-addon btn btn-default">
                        add
                      </label>
                      
                    </div>
                  
                </th>
              </tr>
            </thead>
            <tbody>
          '
            
        for whitelistSubString, index in popupParcel.kiwi_userPreferences.urlSubstring_whitelists.anyMatch
          researchModeHtml += '
            <tr>
              <th scope="row" style="width:35px;"> ' + (index + 1) + ' </th>
              <td> ' + whitelistSubString + ' </td>
              <td style="width:35px;"> 
                <button class="btn btn-xs btn-default removeWhitelistString" data-whitelistStringToRemove="' + whitelistSubString + '" > 
                  <span title="remove" data-whitelistStringToRemove="' + whitelistSubString + '"
                      class="glyphicon glyphicon-remove" aria-hidden="true"
                      style="color:#E65F5F;"
                    ></span>
                </button>
              </td>
            </tr>'
        
        

        researchModeHtml += '
            </tbody>
          </table>
          
        <br>Auto-Off Timer set for: ' + timerOnlyUsefulWhenMessage + '
            
         <br>&nbsp; &nbsp;<label><input ' + timerDisabled + ' type="radio" name="researchAutoOffType" ' + auto20 + ' value="20"> 20 min</label>
         <br>&nbsp; &nbsp;<label><input ' + timerDisabled + ' type="radio" name="researchAutoOffType" ' + auto60 + ' value="60"> 1 hr</label>
         <br>&nbsp; &nbsp;<label><input ' + timerDisabled + ' type="radio" name="researchAutoOffType" ' + autoAlways + ' value="always"> Always On</label>
         <br>&nbsp; &nbsp;<label><input ' + timerDisabled + ' type="radio" name="researchAutoOffType" ' + autoCustom + ' value="custom"> Custom</label>
            &nbsp; &nbsp; <input ' + timerDisabled + ' id="autoCustomValue" type="text" value="' + autoCustomValue + '" size="4" disabled /> minutes'
        
        $("#researchModeDrop").html(researchModeHtml)
        
        servicesHtml = ''
        
        for service, index in popupParcel.kiwi_servicesInfo
          
          if service.active == "on"
            activeCheck = " checked='checked' "
            notActiveCheck = ""
          else
            activeCheck = ""
            notActiveCheck = " checked='checked' "
          
          servicesHtml += '<br>
            <div class="serviceListing listing">
            <table><tbody><tr>
            <td class="upDownButtons">'
          if index != 0
            servicesHtml += '<span title="Move ' + service.title + ' results above ' + popupParcel.kiwi_servicesInfo[index - 1].title + '" class="glyphicon glyphicon-chevron-up" id="' + service.name + '_moveServiceUp" aria-hidden="true"></span>'
          if index != 0 and index != popupParcel.kiwi_servicesInfo.length - 1
            servicesHtml += '<br><br>'
          if index != popupParcel.kiwi_servicesInfo.length - 1 
            servicesHtml += '<span title="Move ' + service.title + ' results below ' + popupParcel.kiwi_servicesInfo[index + 1].title + '"  class="glyphicon glyphicon-chevron-down" id="' + service.name + '_moveServiceDown" aria-hidden="true"></span>'
          
          brandedTitle = if (service.name is 'reddit') then "for " + service.title else service.title
          brandingImage = ''
          if service.brandingImage?
            brandingImage = "&nbsp;<a target='_blank' href='" + service.broughtToYouByURL + "' style='text-decoration:none;'>
              <img height='28' src='" + service.brandingImage + "'/></a>&nbsp;"
          
          servicesHtml += '</td>
            <td class="serviceInfo">'  + brandedTitle + ' - using: ' + brandingImage + ' <a target="_blank" href="' + service.broughtToYouByURL + '">' + service.broughtToYouByTitle + '</a><br>'
          
          if service.name == "productHunt"
            
            specificAPIlink = ", <a target='_blank' href='https://github.com/producthunt/producthunt-api/wiki/Product-Hunt-APIs#algolia-search-api'>for PH</a>"
          
          if service.customSearchBroughtToYouByTitle?
            customSearchApiBrandingHTML = "<div class='bg-warning' style='margin:4px; margin-top:10px;padding:6px;'>
                <em><div style='padding-bottom:2px;'>&nbsp;&nbsp;&nbsp;&nbsp;custom searches are using: </div>" + '
                <div style="padding-bottom:4px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <a target="_blank" href="' + service.customSearchBroughtToYouByURL + '">' + service.customSearchBroughtToYouByTitle + '</a> 
                  ' + specificAPIlink + '
                  </em>
                </div>
                </em>
                
              </div>'
          else
            customSearchApiBrandingHTML = "" 
          
          
          servicesHtml += '<div style="padding-left:15px;">
                status:
                  <label style="font-weight: normal;" for="' + service.name + '_serviceStatusON"> on </label> <input id="' + service.name + '_serviceStatusON" type="radio" name="' + service.name + '_serviceStatus" value="on" ' + activeCheck + ' /> - 
                  <label style="font-weight: normal;" for="' + service.name + '_serviceStatusOFF"> off </label> <input id="' + service.name + '_serviceStatusOFF" type="radio" name="' + service.name + '_serviceStatus" value="off" ' + notActiveCheck + ' />
                <br><br>Results are deemed notable (capitilizes badge letter) if:'
          
          
            
          if service.name == 'gnews'
            servicesHtml += '<br><br> the topic has had <input id="' + service.name + '_numberOfStoriesFoundWithinTheHoursSincePostedLimit" type="text" size="4" value="' + service.notableConditions.numberOfStoriesFoundWithinTheHoursSincePostedLimit + '"/> or more related stories published within the last <input id="' + service.name + '_hoursNotable" type="text" size="4" value="' + service.notableConditions.hoursSincePosted + '"/> hours <br> 
              <div style="width:100%; text-align:center;"><span style="padding:7px; margin-right: 280px; display: inline-block;"> - or - </span></div>
              
              number of News Clusters  <input id="' + service.name + '_numberOfRelatedItemsWithClusterURL" type="text" size="4" value="' + service.notableConditions.numberOfRelatedItemsWithClusterURL + '"/>
              </div>
              ' + customSearchApiBrandingHTML + '
              </td>
            </tr></tbody></table>
            </div>'
            
          
          else
          
            servicesHtml +=  '<br> URL is an exact match, and:
            <br> it has been <input id="' + service.name + '_hoursNotable" type="text" size="4" value="' + service.notableConditions.hoursSincePosted + '"/> or fewer hours since posting <br>
            <div style="width:100%; text-align:center;"><span style="padding:7px; margin-right: 280px; display: inline-block;"> - or - </span></div>
            a post has <input id="' + service.name + '_commentsNotable" type="text" size="4" value="' + service.notableConditions.num_comments + '"/> or more comments
              </div>
              ' + customSearchApiBrandingHTML + '
              </td>
            </tr></tbody></table>
            </div>'
          
          
        servicesHtml += "<div class='serviceListing listing' style='padding:15px; margin-top: 30px;'>
            
            Wouldn't it be awesome if we could add some more services to opt-in to?&nbsp;&nbsp; All that's needed are friendly APIs!&nbsp; <a href='https://twitter.com/spencenow' target='_blank'>Tweet me</a> if you're interested in adding one!
            
          </div>
          <br>"
        
        $("#servicesInfoDrop").html(servicesHtml)
        
      bind: (popupParcel) =>
        
        saveButtons = $(@DOMselector + " .userPreferencesSave")
        
        removeWhitelistStringButtons = $(@DOMselector + " .removeWhitelistString")
        
        autoTimerRadios = $(@DOMselector + " input:radio[name='researchAutoOffType']")
        
        allInputs = $(@DOMselector + ' input:not(.ignoreSaveButtonListen)')
        
        
        addWhitelistString_button = $(@DOMselector + " #addWhiteListString label")
        
        
        
        @elsToUnbind = @elsToUnbind.concat allInputs, saveButtons, autoTimerRadios, removeWhitelistStringButtons, addWhitelistString_button
        
        
        
        saveButtons.attr('disabled','disabled')
        
        allInputs.bind 'change', ->
          $(".userPreferencesSave").removeAttr('disabled')
        
        allInputs.bind 'focus', ->
          $(".userPreferencesSave").removeAttr('disabled')
        
        if $("input:radio[name='researchAutoOffType']:checked").val() is 'custom'
          $("#autoCustomValue").removeAttr('disabled')
          
        autoTimerRadios.bind 'change', ->
          if $("input:radio[name='researchAutoOffType']:checked").val() is 'custom'
            $("#autoCustomValue").removeAttr('disabled')
          else
            $("#autoCustomValue").attr('disabled','disabled')
        
        
        
        _bindDown = (downButton, index) =>
          downButton.bind 'click', ->    
            popupParcel.kiwi_servicesInfo = moveArrayElement(popupParcel.kiwi_servicesInfo, index, index + 1)
            
            parcel =
              refreshView: 'userPreferences'
              keyName: 'kiwi_servicesInfo'
              newValue: popupParcel.kiwi_servicesInfo
              localOrSync: 'sync'
              
              msg: 'kiwiPP_post_save_a_la_carte'
            
            sendParcel(parcel)
        
        _bindUp = (upButton, index) =>
          
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
            @elsToUnbind.push downButton
            _bindDown(downButton, index)
              
          upButton = $("#" + service.name + '_moveServiceUp')
          if upButton.length > 0
            @elsToUnbind.push upButton
            _bindUp(upButton, index)
          
        postError = (userErrMsg) =>
          # console.log 'trying to post error ' + userErrMsg
          $(@DOMselector + " .userErrMsg").html("<br>" + userErrMsg)
        
        
        removeWhitelistStringButtons.bind 'click', (ev) =>
          
          whitelistSubString = $(ev.target).attr('data-whitelistStringToRemove')
          
          # console.debug popupParcel.kiwi_userPreferences.urlSubstring_whitelists.anyMatch
          # console.debug whitelistSubString
          
          newWhitelistAnyMatchArray = _.without(popupParcel.kiwi_userPreferences.urlSubstring_whitelists.anyMatch, whitelistSubString);
          
          popupParcel.kiwi_userPreferences.urlSubstring_whitelists.anyMatch = newWhitelistAnyMatchArray
          
          
          parcel =
            refreshView: 'userPreferences'
            keyName: 'kiwi_userPreferences'
            newValue: popupParcel.kiwi_userPreferences
            localOrSync: 'sync'
            msg: 'kiwiPP_post_save_a_la_carte'
          
          sendParcel(parcel)
        
        
        addWhitelistString_button.bind 'click', (ev) =>
          
          # whitelistSubString = $(ev.target).attr('data-whitelistStringToRemove')
          
          whitelistSubString_toAdd = $(@DOMselector + " #addWhiteListString input").val()
          
          popupParcel.kiwi_userPreferences.urlSubstring_whitelists.anyMatch.push whitelistSubString_toAdd
          
          parcel =
            refreshView: 'userPreferences'
            keyName: 'kiwi_userPreferences'
            newValue: popupParcel.kiwi_userPreferences
            localOrSync: 'sync'
            msg: 'kiwiPP_post_save_a_la_carte'
          
          sendParcel(parcel)
        
        
        
        saveButtons.bind 'click', ->
          
          researchModeHTMLval = $("input:radio[name='research']:checked").val()
          
          # console.log 'researchModeHTMLval is ' + researchModeHTMLval
          
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

          # console.log '1234' 
          popupParcel.kiwi_userPreferences.researchModeOnOff = researchModeHTMLval
          
          if (autoOffTimerType != 'custom')
            popupParcel.kiwi_userPreferences.autoOffTimerType = autoOffTimerType
          else  
            popupParcel.kiwi_userPreferences.autoOffTimerType = autoOffTimerType
            popupParcel.kiwi_userPreferences.autoOffTimerValue = parseFloat(autoOffTimerValue)
          
          for service, index in popupParcel.kiwi_servicesInfo
            
            active = $("input:radio[name='" + service.name + "_serviceStatus']:checked").val()
            popupParcel.kiwi_servicesInfo[index].active = active
            
            # notableSound = $("input:radio[name='" + service.name + "_soundStatus']:checked").val()
            # popupParcel.kiwi_servicesInfo[index].notableSound = notableSound
            
            hoursSincePosted = $('#' + service.name + '_hoursNotable').val()
            # console.log popupParcel.kiwi_servicesInfo[index].name
            # console.log "hoursSincePosted = $('#' + service.name + '_hoursNotable').val() " + hoursSincePosted
            popupParcel.kiwi_servicesInfo[index].notableConditions.hoursSincePosted = parseFloat(hoursSincePosted)
            
            
            if service.name == 'gnews'
              
              numberOfRelatedItemsWithClusterURL = $('#' + service.name + '_numberOfRelatedItemsWithClusterURL').val()
              popupParcel.kiwi_servicesInfo[index].notableConditions.numberOfRelatedItemsWithClusterURL = parseInt(numberOfRelatedItemsWithClusterURL)
              
              numberOfStoriesFoundWithinTheHoursSincePostedLimit = $('#' + service.name + '_numberOfStoriesFoundWithinTheHoursSincePostedLimit').val()
              popupParcel.kiwi_servicesInfo[index].notableConditions.numberOfStoriesFoundWithinTheHoursSincePostedLimit = parseInt(numberOfStoriesFoundWithinTheHoursSincePostedLimit)
            else
            
              num_comments = $('#' + service.name + '_commentsNotable').val()
              popupParcel.kiwi_servicesInfo[index].notableConditions.num_comments = parseInt(num_comments)
            
          popupParcel.view = 'userPreferences'
          
          # console.log '4567'
          # console.debug popupParcel
          
          parcel = 
            refreshView: popupParcel.view
            newPopupParcel: popupParcel
            msg: 'kiwiPP_post_savePopupParcel'
          
          sendParcel(parcel)



class Credits extends SwitchView
  constructor: (@name) ->
    super @name, @__renderStates__
    
  init: (popupParcel) ->
    @unbindWidget()
    @render(popupParcel)
  
  __renderStates__: =>
    __normal__: 
      paint: (popupParcel) =>
        console?.log 'painting ' + @name
      bind: (popupParcel) =>
        console?.log 'binding ' + @name

class Loading extends SwitchView
  constructor: (@name) ->
    super @name, @__renderStates__
    
  init: (popupParcel) ->
    @unbindWidget()
    @render(popupParcel)
  
  __renderStates__: =>
    __normal__: 
      paint: (popupParcel) =>
        console?.log 'painting ' + @name
      bind: (popupParcel) =>
        console?.log 'binding ' + @name

class KiwiSlice extends FixedView
  constructor: (@name, uniqueSelectorPostfix) ->
    super @name, @__renderStates__, uniqueSelectorPostfix
    
  init: (popupParcel, renderState = null) =>
    @renderStateTransitions = @__renderStateTransitions__()
    
    # console.log 'hehehehee init: (popupParcel, renderState = null) =>'
    @unbindView()
    
    renderState = if renderState? then renderstate else "collapsed"
    # console.log ' renderState = if renderState? then renderstate else "collapsed" ' + renderState
    @render(popupParcel, 'collapsed')
  
  render: (popupParcel, renderState, fromState = null) =>
    # console.log 'in render for kiwi'
    __renderStates__callback = (popupParcel, renderState) =>
      super popupParcel, renderState
    
    if fromState? and @renderStateTransitions[fromState + "__to__" + renderState]?
      # console.log 'yep, has renderstate'
      @renderStateTransitions[fromState + "__to__" + renderState](popupParcel, renderState, __renderStates__callback)
    else
      super popupParcel, renderState
    
  __renderStates__: =>
    collapsed: 
      paint: (popupParcel) =>
        kiwiSliceHTML = '<div id="sliceActivateTransition" style="position:fixed; bottom: -33px; right: -33px; ">
            <img style="width: 66px; height: 66px;" src="symmetricKiwi.png" /> 
          </div>'
        
        $(@DOMselector).html(kiwiSliceHTML)
        
      bind: (popupParcel) =>
        
        elActivateTransition = $(@DOMselector + " #sliceActivateTransition")
        
        @elsToUnbind = @elsToUnbind.concat elActivateTransition
        
        elActivateTransition.bind 'mouseover', (ev) =>
          elActivateTransition.addClass('rotateClockwiseFull')
        
        elActivateTransition.bind 'mouseout', (ev) =>
          elActivateTransition.removeClass('rotateClockwiseFull')
          
        elActivateTransition.bind 'click', (ev) =>
          elActivateTransition.removeClass('rotateClockwiseFull')
          @render(popupParcel,'open', 'collapsed')
        
    open:
      
      paint: (popupParcel) =>
        # console.log 'painting ' + @name
        kiwiSliceHTML = '<div id="transition_open_showMe" class="evenlySpacedContainer kiwiSliceOpenPlatter">
            <button type="button" class=" goTo_creditsView btn btn-mini btn-default">credits</button> 
            <a class="btn btn-mini btn-default" style="font-size:.8em;" target="_blank" href="http://www.metafruit.com/kiwi/">MetaFruit <span class="glyphicon glyphicon-apple"></span></a>
            <button class=" btn btn-mini btn-default" id="clearKiwiURLCache">clear cache</button>
            <button class=" btn btn-mini btn-default" id="refreshURLresults">refresh</button>
          </div>
          <div id="sliceActivateTransition" style="position:fixed; bottom: 15px; right: 15px; ">
            <img style="width: 66px; height: 66px;" src="symmetricKiwi.png" /> 
          </div>'
        
        $(@DOMselector).html(kiwiSliceHTML)
        # console.log kiwiSliceHTML
        
          
        
      bind: (popupParcel) =>
        # console.log 'binding ' + @name
        elActivateTransition = $(@DOMselector + " #sliceActivateTransition")
          
        clearKiwiURLCacheButton = $(@DOMselector + " #clearKiwiURLCache")
        
        refreshURLresultsButton = $(@DOMselector + " #refreshURLresults")
        
        @elsToUnbind = @elsToUnbind.concat elActivateTransition, refreshURLresultsButton, clearKiwiURLCacheButton
        
        refreshURLresultsButton.bind 'click', ->
          parcel =
            msg: 'kiwiPP_refreshURLresults'
          sendParcel(parcel)
        
        $('body').mouseup((e) => 
          # console.log 'test test test'
          container = $(@DOMselector)
          if (!container.is(e.target) && container.has(e.target).length == 0)
            $('body').unbind 'mouseup'
            @render(popupParcel,'collapsed', 'open')   
        )
          
        
        elActivateTransition.bind 'click', (ev) =>
          @render(popupParcel,'collapsed', 'open')
        
        clearKiwiURLCacheButton.bind 'click', ->
          parcel =
            msg: 'kiwiPP_clearAllURLresults'
          sendParcel(parcel)
  
  # \/ \/ \/ THIS IS A WORK IN PROGRESS \/ \/ \/
  __renderStateTransitions__: =>
    
    'open__to__collapsed': (popupParcel, renderState, __renderStates__callback) =>
      
      $(@DOMselector + " #transition_open_showMe").animate({'opacity':0}, 300)
      
      $(@DOMselector + " #sliceActivateTransition").addClass('rotateClockwise')
      $(@DOMselector + " #sliceActivateTransition").animate({"bottom": '-33px', "right": "-33px"}, {
        duration: 500,
        complete: ->
          __renderStates__callback(popupParcel, renderState)
      })
      
      
      # return transitionObj
    
    'collapsed__to__open': (popupParcel, renderState, __renderStates__callback) =>
      # console.log "'collapsed__to__open': (popupParcel, renderState, __renderStates__callback) =>"
      $(@DOMselector + " #sliceActivateTransition").addClass('rotateCounterClockwise')
      $(@DOMselector + " #sliceActivateTransition").animate({"bottom": '15px', "right": "15px"}, {
        duration: 500,
        complete: ->
          # console.log 'we are done with animation'
          __renderStates__callback(popupParcel, renderState)
      })
      $(@DOMselector).prepend('<div id="transition_open_showMe" class="evenlySpacedContainer kiwiSliceOpenPlatter" style="opacity: 0;">
            <button type="button" class="goTo_creditsView btn btn-mini btn-default ">credits</button> 
            <a class=" btn btn-mini btn-default" style="font-size:.8em;" target="_blank" href="http://www.metafruit.com/kiwi/">MetaFruit <span class="glyphicon glyphicon-apple"></span></a> 
            <button class="btn btn-mini btn-default " id="clearKiwiURLCache">clear cache</button>
            <button class="btn btn-mini btn-default " id="refreshURLresults">refresh</button>
          
          </div>')
      # setTimeout =>
      $(@DOMselector + " #transition_open_showMe").animate({'opacity':1}, 499)
        # , 200
  
fixedViews = 
  kiwiSlice: new KiwiSlice 'kiwiSlice', 'FixedBottom'

switchViews =
  conversations: new Conversations 'conversations'
  userPreferences: new UserPreferences 'userPreferences'
  credits: new Credits 'credits'
  loading: new Loading 'loading'

  
tailorResults = 
  gnews: (serviceInfoObject, service_PreppedResults, kiwi_userPreferences) ->
    
    currentTime = Date.now()
    
    
    preppedHTMLstring = "<div class='serviceResultsBox serviceResultJumpTo resultsBox__" + serviceInfoObject.name + "'>
      <div class='serviceResultsHeaderBar'>
        <span class='serviceResultsTitles'>" + serviceInfoObject.title + '</span> &nbsp;&nbsp;<a class="customSearchOpen"> modify search</a>
          <p>&nbsp&nbsp' + serviceInfoObject.brandingSlogan + '</p>'
      
    if kiwi_userPreferences.sortByPref == 'attention'
      selectedString_attention = 'selected'
      selectedString_recency = ''
    else
      selectedString_attention = ''
      selectedString_recency = 'selected'
      
    preppedHTMLstring += '<div style="position: absolute;padding-top: 20px;top: 0px;right: 0px;">&nbsp;&nbsp; sorted by: 
        <select class="conversations_sortByPref">
          <option ' + selectedString_attention + ' id="_attention" value="attention">attention</option>
          <option ' + selectedString_recency + ' id="_recency" value="recency">recency</option>
        </select> </div>
    
      </div>'
      
    if service_PreppedResults? and service_PreppedResults.length > 0
      preppedHTMLstring += '<div style="padding:7px;">
        &nbsp;&nbsp; Searched for: "<strong>' + service_PreppedResults[0].kiwi_searchedFor + '</strong>"
       </div>'
    
    if kiwi_userPreferences.sortByPref is 'attention'
      service_PreppedResults = _.sortBy(service_PreppedResults, 'clusterUrl')
      service_PreppedResults.reverse()
    else if kiwi_userPreferences.sortByPref is 'recency'
      service_PreppedResults = _.sortBy(service_PreppedResults, 'kiwi_created_at')
      service_PreppedResults.reverse()
    
    # console.log 'if kiwi_userPreferences.sortByPref is '
    # console.log kiwi_userPreferences.sortByPref
    
    # console.log 'console.debug serviceResults.service_PreppedResults'
    # console.debug service_PreppedResults
      
    for listing, index in service_PreppedResults
      
      listingClass = if (index > 10 and service_PreppedResults.length > 14) then ' hidden_listing' else ''
      
      recentTag = if (currentTime - listing.kiwi_created_at < 1000 * 60 * 60 * 4) then "<span class='recentListingTag'>Recent: </span>" else ""
      
      preppedHTMLstring += '<div class="listing ' + listingClass + '" style="position:relative;">' + recentTag + '
        <a class="listingTitle" target="_blank" href="' + listing.unescapedUrl + '">
          <b>' + listing.titleNoFormatting + '</b><br>'
      
      _time = formatTime(listing.kiwi_created_at)
      
      preppedHTMLstring += listing.publisher + ' -- ' + _time + '</a>
      <br>' + listing.content + '<br>'
      if listing.clusterUrl != ''
        preppedHTMLstring += '<a target="_blank" href="' + listing.clusterUrl + '"> Google News cluster </a>'
      preppedHTMLstring += '</a>
        </div>'
        
    preppedHTMLstring += "</div>"
    return preppedHTMLstring
    
  hackerNews: (serviceInfoObject, service_PreppedResults, kiwi_userPreferences) ->
    return tailorRedditAndHNresults_returnHtml(serviceInfoObject, service_PreppedResults, kiwi_userPreferences)
    
  reddit: (serviceInfoObject, service_PreppedResults, kiwi_userPreferences) ->
    return tailorRedditAndHNresults_returnHtml(serviceInfoObject, service_PreppedResults, kiwi_userPreferences)
  
  
  productHunt:  (serviceInfoObject, service_PreppedResults, kiwi_userPreferences) ->
    
    preppedHTMLstring = ''
    
    currentTime = Date.now()
    
    # comments_count: 30
    # created_at: "2015-08-13T06:03:40.625-07:00"
    # discussion_url: "http://www.producthunt.com/tech/buffer-for-video"
    # id: 30839
    
    
    
    
    fuzzyMatchBool = false
    
    brandingDisplay = ''
    if serviceInfoObject.brandingImage?
      brandingDisplay = '<img style="margin-left:7px;" title="' + serviceInfoObject.title + '" height="28" src="' + serviceInfoObject.brandingImage + '"/> 
      &nbsp;&nbsp; <span class="serviceResultsTitles" style="color:black; position: relative;top: 6px;">' + serviceInfoObject.title + '</span>'
    else
      brandingDisplay = "<span class='serviceResultsTitles'>" + serviceInfoObject.title + '</span>'
    
    preppedHTMLstring += "<div class='serviceResultsBox serviceResultJumpTo resultsBox__" + serviceInfoObject.name + "'>
      <div class='serviceResultsHeaderBar'>" + brandingDisplay + "</div>"
    
      # recency doesn't make sense for PH
    # if kiwi_userPreferences.sortByPref == 'attention'
    #   selectedString_attention = 'selected'
    #   selectedString_recency = ''
    # else
    #   selectedString_attention = ''
    #   selectedString_recency = 'selected'
      
        
    
    if service_PreppedResults.length < 1
      preppedHTMLstring += ' no results <br>'
      return preppedHTMLstring
    else
      service_PreppedResults = _.sortBy(service_PreppedResults, 'kiwi_num_comments')
      service_PreppedResults.reverse()
    
    
    for listing, index in service_PreppedResults
      listingClass = if (index > 10 and service_PreppedResults.length > 14) then ' hidden_listing ' else ''
      if listing.comment_text?
        
        preppedHTMLstring += _tailorHNcomment(listing, serviceInfoObject, listingClass)
        
      else
        if (listing.kiwi_created_at? and currentTime - listing.kiwi_created_at < 1000 * 60 * 60 * 4)
          recentTag = "<span class='recentListingTag'>Recent: </span>"
        else
          recentTag = ""
        
        # preppedHTMLstring += '<div class="listing ' + listingClass + '" style="position:relative;">' + recentTag + '
        #   <div style="float:right;">
        #     <a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '</a>
        #   </div>
        #   <a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.kiwi_permaId + '">'
        
        if listing.kiwi_makers.length > 3
          gridLayoutBool = false
        else  
          gridLayoutBool = true
        
        preppedHTMLstring += '<div class="listing ' + listingClass + '">'
        
          # kiwi_created_at: 1439471020625
          
          # kiwi_author_headline: "Community @ProductHunt. "
          # kiwi_author_name: "Ben Tossell"
          # kiwi_author_username: "bentossell"
          # kiwi_discussion_url: "http://www.producthunt.com/tech/buffer-for-video"
          # kiwi_makers: Array[9]
            
          #   headline: "Co-founder/CEO, Buffer"
          #   name: "Joel Gascoigne"
          #   profile_url: "http://www.producthunt.com/@joelgascoigne"
          #   username: "joelgascoigne"
          #   website_url: "http://joel.is"
            
          # kiwi_num_comments: 30
          # kiwi_score: 244
          
          # name: "Buffer for Video"
          # tagline: "All-in-one video scheduling & management for social media"
          
          # redirect_url: "http://www.producthunt.com/r/4918f991fdd705/30839?app_id=1674"
          # screenshot_url: Object
        
        if gridLayoutBool
          preppedHTMLstring +=  '<div style="display:inline-table; width: 60%; padding-right:8px;">'
        else
          preppedHTMLstring +=  '<div>'
          
        preppedHTMLstring += '
          <a class="listingTitle" target="_blank" href="' + listing.kiwi_discussion_url + '">
            <div style="color:black; padding:4px; padding-bottom: 8px; font-size: 1.1em;">' + recentTag + '
              <b>' + listing.name + '</b>
            </div>
            <div style="color:#4D586F; padding-left:18px;">
              <div style="padding-bottom:4px;">"' + listing.tagline + '"</div>'
          
        preppedHTMLstring += '<div style="padding-bottom:4px;">
            ' + listing.kiwi_num_comments + ' comments, ' + listing.kiwi_score + ' upvotes
          </div>'
        
        if listing.kiwi_created_at?
          _time = formatTime(listing.kiwi_created_at)
          preppedHTMLstring += '' + _time
        
        preppedHTMLstring += '</div></a></div>'
        
        if gridLayoutBool
          preppedHTMLstring +=  '<div style="display:inline-table; width: 39%;">'
        else
          preppedHTMLstring +=  '<div style="padding: 8px;">'
        
        makerUsernames = []
        
        if listing.kiwi_makers? and listing.kiwi_makers.length > 0
          
          preppedHTMLstring += '<div><div style="padding-bottom:2px;"><b>made by</b>: </div>'
             
          for maker in listing.kiwi_makers
            
            if gridLayoutBool
              preppedHTMLstring += '<div style="padding-bottom: 4px;">'
            else
              preppedHTMLstring += '<div style="padding-bottom: 4px; padding-left: 10px;">'
            
            preppedHTMLstring += '<a target="_blank" href="' + serviceInfoObject.userPageBaselink + maker.username + '" style="color:#727E98;">' + maker.name 
            if maker.headline? and maker.headline != ""
              preppedHTMLstring += ', "' + maker.headline + '"'
            preppedHTMLstring += '</a>'
              
            if maker.website_url?
              preppedHTMLstring += ' <a href="' + maker.website_url + '" target="_blank"><span class="glyphicon glyphicon-log-in" style="color:blue;"></span> </a>'
            
            if listing.kiwi_author_username == maker.username
              preppedHTMLstring += " (also submitted post)"
            preppedHTMLstring += '</div>'
            
          preppedHTMLstring += '</div>'
          
          makerUsernames.push maker.username
          
        if listing.kiwi_author_username not in makerUsernames
          if gridLayoutBool
              gridLayoutAuthorDiv = '<div style="padding-bottom: 2px;">'
            else
              gridLayoutAuthorDiv = '<div style="padding-bottom: 2px; margin-left: 10px;">'
          preppedHTMLstring +=  '<div style="">
            <div style="padding-bottom:2px;"><b>submitted by:</b></div>
              ' + gridLayoutAuthorDiv + '<a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.kiwi_author_username + '"
               style="color:#727E98;">' + listing.kiwi_author_name + '
              ' 
              
          if listing.kiwi_author_headline? and listing.kiwi_author_headline != ""
            preppedHTMLstring += ', "' + listing.kiwi_author_headline + '"'
            
          preppedHTMLstring += '</a></div></div>'
        
        
        preppedHTMLstring += '</div></div>'
    
    preppedHTMLstring += "</div>"
    return preppedHTMLstring
    
    
    
    # return '{{ do not have layout yet, ' + service_PreppedResults.length + ' results }}'

_tailorHNcomment = (listing, serviceInfoObject, listingClass) ->
  currentTime = Date.now()
  commentHtml = ""
  
  # story_text
  # comment_text
  # story_id
  # story_title
  # story_url
  
  recentTag = if (currentTime - listing.kiwi_created_at < 1000 * 60 * 60 * 4) then "<span class='recentListingTag'>Recent: </span>" else ""
  
  commentHtml += '<div class="listing ' + listingClass + ' " style="position:relative;">' + recentTag
  
  if listing.over_18? and listing.over_18 is true
    commentHtml += '<span class="nsfw">NSFW</span> For story: ' + listing.story_title + '<br>'
  else
    commentHtml += "For story: <a target='_blank' href='" + serviceInfoObject.permalinkBase + listing.story_id + "'>" + listing.story_title + '</a><br>'
  
  _time = formatTime(listing.kiwi_created_at)
  
  commentHtml += 'at ' + _time + ',
    <a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '">' + listing.author + '</a> recieved ' + listing.kiwi_score + ' upvotes, by saying: 
    
    ( <a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.kiwi_permaId + '">
      comment permalink 
    </a> , <a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.story_id + '"> story permalink </a>
     )<br><div class="commentBox">
    ' + listing.comment_text + '
    </div></div>'

  return commentHtml
  
tailorRedditAndHNresults_returnHtml = (serviceInfoObject, service_PreppedResults, kiwi_userPreferences) ->
  preppedHTMLstring = ''
  
  currentTime = Date.now()
  # kiwi_exact_match
    # fuzzy matches
  
  # linkify stuff
  
  fuzzyMatchBool = false
  
  preppedHTMLstring += "<div class='serviceResultsBox serviceResultJumpTo resultsBox__" + serviceInfoObject.name + "'>
    <div class='serviceResultsHeaderBar'>"
  
  if serviceInfoObject.name == 'reddit'
    preppedHTMLstring += "<span class='serviceResultsTitles'>for " + serviceInfoObject.title + ':</span>'
  else
    preppedHTMLstring += "<span class='serviceResultsTitles'>" + serviceInfoObject.title + '</span>'
  
  if kiwi_userPreferences.sortByPref == 'attention'
    selectedString_attention = 'selected'
    selectedString_recency = ''
  else
    selectedString_attention = ''
    selectedString_recency = 'selected'
    
  preppedHTMLstring += '<div style="float:right; padding-top: 9px;"> &nbsp;&nbsp sorted by: <select class="conversations_sortByPref">
        <option ' + selectedString_attention + ' id="_attention" value="attention">attention</option>
        <option ' + selectedString_recency + ' id="_recency" value="recency">recency</option>
      </select></div>
      
    </div>'
  
  if service_PreppedResults.length < 1
    preppedHTMLstring += ' no results <br>'
    return preppedHTMLstring
  
  else if !service_PreppedResults[0].comment_text? and kiwi_userPreferences.sortByPref is 'attention'
    
    service_PreppedResults = _.sortBy(service_PreppedResults, 'kiwi_num_comments')
    service_PreppedResults.reverse()
  else if kiwi_userPreferences.sortByPref is 'attention'
    service_PreppedResults = _.sortBy(service_PreppedResults, 'kiwi_score')
    service_PreppedResults.reverse()
  else if kiwi_userPreferences.sortByPref is 'recency'
    service_PreppedResults = _.sortBy(service_PreppedResults, 'kiwi_created_at')
    service_PreppedResults.reverse()
  
  
  for listing, index in service_PreppedResults
    listingClass = if (index > 10 and service_PreppedResults.length > 14) then ' hidden_listing ' else ''
    if listing.comment_text?
      
      preppedHTMLstring += _tailorHNcomment(listing, serviceInfoObject, listingClass)
      
    else
      recentTag = if (currentTime - listing.kiwi_created_at < 1000 * 60 * 60 * 4) then "<span class='recentListingTag'>Recent: </span>" else ""
      
      if listing.kiwi_exact_match
        # preppedHTMLstring += '<div class="listing ' + listingClass + '" style="position:relative;">' + recentTag + '
        #   <div style="float:right;">
        #     <a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '</a>
        #   </div>
        #   <a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.kiwi_permaId + '">'
        
        preppedHTMLstring += '<div class="listing ' + listingClass + '">'
        if serviceInfoObject.name != 'reddit'
          preppedHTMLstring +=  '<div style="float:right;">
              <a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '</a>
            </div>'
        preppedHTMLstring +=  '<a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.kiwi_permaId + '"><span style="color:black;">' + recentTag
        
        
        if listing.over_18? and listing.over_18 is true
          preppedHTMLstring += '<span class="nsfw">NSFW</span> <b>' + listing.title + '</b><br>'
        else
          preppedHTMLstring += '<b>' + listing.title + '</b><br>'
        
        _time = formatTime(listing.kiwi_created_at)
        
        preppedHTMLstring += listing.kiwi_num_comments + ' comments, ' + listing.kiwi_score + ' upvotes -- ' + _time + '</span></a>'
        
        if listing.subreddit?
          preppedHTMLstring +=  '<br><span> 
            <a target="_blank" href="' + serviceInfoObject.permalinkBase + '/r/' + listing.subreddit + '">
            subreddit: ' + listing.subreddit + '</a></span>
            <div style="float:right;">
                <a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '
                </a>
            </div>'
        
        preppedHTMLstring += '<br></div>'
        
      else
        fuzzyMatchBool = true
  
  if fuzzyMatchBool
    
    numberOfExactMatches = _.reduce(service_PreppedResults, (memo, obj) -> 
        if obj.kiwi_exact_match
          memo++
          return memo
        else
          memo
    )
    if (service_PreppedResults.length - numberOfExactMatches) > 10 and service_PreppedResults.length > 14
      listingClass = ' hidden_listing ' 
    else
      listingClass = ''
      
    # listingClass = if nonFuzzyItemCounter > 10 then ' hidden_listing ' else ''
    preppedHTMLstring += '<div class="showFuzzyMatches ' + listingClass + '" style="position:relative;"> fuzzy matches: <br></div>
      <span class="fuzzyMatches">'
    # console.log 'fuzzy matches 12312312 ' + serviceInfoObject.name
    
    for listing, index in service_PreppedResults
      listingClass = if (index > 10 and service_PreppedResults.length > 14) then ' hidden_listing ' else ''
      if !listing.kiwi_exact_match
        
        recentTag = if (currentTime - listing.kiwi_created_at < 1000 * 60 * 60 * 4) then "<span class='recentListingTag'>Recent: </span>" else ""
          
        preppedHTMLstring += '<div class="listing ' + listingClass + '">'
        if serviceInfoObject.name != 'reddit'
          preppedHTMLstring +=  '<div style="float:right;">
              <a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '</a>
            </div>'
        preppedHTMLstring +=  '<a class="listingTitle" target="_blank" href="' + serviceInfoObject.permalinkBase + listing.kiwi_permaId + '"><span style="color:black;">' + recentTag
        
        if listing.over_18? and listing.over_18 is true
          preppedHTMLstring += '<span class="nsfw">NSFW</span> <b>' + listing.title + '</b><br>'
        else
          preppedHTMLstring += '<b>' + listing.title + '</b><br>'
        
        preppedHTMLstring += listing.kiwi_num_comments + ' comments, ' + listing.kiwi_score + ' upvotes ' + formatTime(listing.kiwi_created_at) + '</span>
        <br>
        for Url: <span class="altURL">' + listing.url + '</span>
        </a>'
        
        if listing.subreddit?
          preppedHTMLstring +=  '<br><span>
            <a target="_blank" href="' + serviceInfoObject.permalinkBase + '/r/' + listing.subreddit + '">
            subreddit: ' + listing.subreddit + '</a></span>
            <div style="float:right;">
              <a target="_blank" href="' + serviceInfoObject.userPageBaselink + listing.author + '"> by ' + listing.author  + '
              </a></div>'
        preppedHTMLstring += '<br></div>'
        
    
    preppedHTMLstring += "</span>" 
  preppedHTMLstring += "</div>"
  return preppedHTMLstring

bindGoToViewButtons = (buttonEls, viewName, viewData) ->
  for el in buttonEls
    $(el).bind('click', (ev) ->
      # console.log 'clicked ' + viewName
      switchViews[viewName].render(viewData)
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
  
  amOrPm = if hour > 11 then 'pm' else 'am'
   
  if hour > 12 
    hour = hour - 12 
  else if parseInt(hour) == 0
    hour = 12
  
  if min < 10
    min = '0' + min
  
  time = month + ' ' + date + ', ' + year + ' - ' + hour + ':' + min + amOrPm
  return time
  
renderExtensionHeight = (elementSelector, extraPx) ->
  if viewElementId is elementSelector
    extraPx = 2
    extHeight_ = $(elementSelector).outerHeight() + extraPx
    
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


# console.log 'trying to send123'



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
            
              # console.log "when 'popupParcel_ready' parcel"
              # console.debug parcel
              
              initialize(parcel.popupParcel)
              
          else 
            # console.log 'chrome-devtools:// '
            return 0  
          
          # # $("#landingStatusBox").html('Summaries available! :)')
      )


 
sendParcel = (parcel) ->
  # console.log 'wtf sent'
  port = chrome.extension.connect({name: "kiwi_fromBackgroundToPopup"})
  
  # chrome.tabs.getSelected(null,(tab) ->
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) ->
    # console.log 'wtf sent2'
    # console.debug tabs
    if tabs.length > 0 and tabs[0].status is "complete"
      if tabs[0].url.indexOf('chrome-devtools://') != 0
        parcel.forUrl = tabs[0].url
      
        if !parcel.msg?
          return false
        
        switch parcel.msg
          when 'kiwiPP_refreshSearchQuery'
            port.postMessage(parcel)  
            
          when 'kiwiPP_acknowledgeMessage'
            port.postMessage(parcel)
          when 'kiwiPP_post_customSearch'
            # console.log 'trying to post custom search'
            # console.debug parcel
            port.postMessage(parcel)  
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
        # console.log 'chrome-devtools:// '
        return 0     
  )
  
  # listen for other messages
chrome.extension.onConnect.addListener((port) ->  
  if port.name is 'kiwi_fromBackgroundToPopup'
    
    port.onMessage.addListener((pkg) ->
      receiveParcel(pkg)
    )
)

sendParcel({'msg':'kiwiPP_request_popupParcel'})


