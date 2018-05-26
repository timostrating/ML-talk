$(document).ready ->
  _writing_rate = 0.1
  _throttle = {
    start: 4821
    stop: 5344
  }
  _colors = {
    background: "#333"
    text: "#ccc"  
    offblack: "#111111"
    dark: "#8d8b80"
    selector: "#a6da27"
    key: "#64d9ef"
    value: "#fefefe"
    hex: "#f92772"
    text: "#fefefe"
    string: "#d2cc70"  
    var: "#66d9e0"  
    operator: "#f92772"  
    method: "#f9245c"
    integer: "#fd971c"
    run: "#ae81ff"
  }
  _body_selection = "document.body"
  _current_code = 0
  _codes = ["""
  /******************************
   *                            *
   * __1.4_Data_visualisatie__  *
   *                            *
   ******************************/!

  selector  { property: value; }    
  .comment  { color: #{_colors.dark}; }

  #my-code {
    overflow: auto;
    position: fixed; width: 50%;
    margin: 0;
    top: 0px; bottom: 0px; right: 0px;
  }
  
  body {
    background-color: #{_colors.background}; color: #{_colors.text};
    overflow: hidden;
    font-size: 13px; line-height: 1.4;
    margin: 0;
    width: 48%;
  }

  #my-code {
    transition: all 1s, width 1s, opacity 1s;
    background-color: #{_colors.offblack}; color: #{_colors.text};
    border: 1px solid rgba(0,0,0,0.2);
    padding: 24px 12px;
    box-sizing: border-box;
    border-radius: 2px;
  }

  pre em:not(.comment) { font-style: normal; }
  .comment       { color: #{_colors.dark}; }
  .selector      { color: #{_colors.selector}; }
  .selector .key { color: #{_colors.selector}; }
  .selector .int { color: #{_colors.selector}; }
  .key           { color: #{_colors.key}; }
  .int           { color: #{_colors.integer}; }
  .hex           { color: #{_colors.hex}; }
  .hex .int      { color: #{_colors.hex}; }
  .value         { color: #{_colors.value}; }
  .var           { color: #{_colors.var}; }
  .operator      { color: #{_colors.operator}; }
  .string        { color: #{_colors.string}; }

  center { margin: 50px; }

  ~\`

  /* 
   * Als je dit zo snel kan lezen dat je het ook begrijpt, Respect.
   */
  var site = document.createElement("center");
  #{_body_selection}.appendChild(site); ~  
  
  var title = document.createElement("h1");
  title.innerHTML = "Timo Strating - 1E";
  site.appendChild(title); ~  

  var text = document.createElement("h3");
  text.innerHTML = 'TL <span style="margin:0 20px">➡️</span> MBO <span style="margin:0 20px">➡️</span> HBO';
  site.appendChild(text); ~ 
 
  var text = document.createElement("p");
  text.innerHTML = '<a href="gewoon.de" style="color:  wheat;">gewoon.de</a>';
  site.appendChild(text); ~ 
  
  var text = document.createElement("p");
  text.innerHTML = '<a href="#" style="color:  wheat;">zernimap</a>';
  site.appendChild(text); ~ 

  \`

  #my-code {
    top: 50%;
    right: 0%;
    width: 100%;
  }

  .projects {
    position: absolute;
    top: 0;
    width:  100%;
    height: 100%;
  }

  .project {
    background-color: rgb(255, 158, 37);
    width: 50%;
    height: 50%;
    position: absolute;
    text-align: center;
    margin: -5px;
  }


  #my-code {
    width: 50%;
  }

  """
  ]

# https://www.desmos.com/calculator/gfpglu3o5o


  # body selector
  $body = document.getElementsByTagName("body")[0]
  _PAUSED = false

  # easily create element with id
  createElement = (tag, id) ->
    el = document.createElement tag
    el.id = id if id
    return el
      
  # create our primary elements
  _style_elem   = createElement "style", "style-elem"
  _code_pre     = createElement "pre",   "my-code"
  _script_area  = createElement "div",   "script-area"

  # append our primary elements to the body
  $body.appendChild _style_elem
  $body.appendChild _code_pre
  $body.appendChild _script_area

  # select our primary elements
  $style_elem   = document.getElementById "style-elem"
  $code_pre     = document.getElementById "my-code"
  $script_area  = document.getElementById "script-area"

  # tracking states
  openComment = false
  openInteger = false
  openString = false
  prevAsterisk = false
  prevSlash = false


  # script syntax highlighting logic
  scriptSyntax = (string, which) ->
    
    # if end of integer (%, ., or px too)
    if openInteger && !which.match(/[0-9\.]/) && !openString && !openComment
      s = string.replace(/([0-9\.]*)$/, "<em class=\"int\">$1</em>" + which)
    
    # open comment detection
    else if which == '*' && !openComment && prevSlash
      openComment = true
      s = string + which
    
    # closed comment detection    
    else if which == '/' && openComment && prevAsterisk
      openComment = false
      s = string.replace(/(\/[^(\/)]*\*)$/, "<em class=\"comment\">$1/</em>") 
    
    # var detection
    else if which == 'r' && !openComment && string.match(/[\n ]va$/)
      s = string.replace(/va$/, "<em class=\"var\">var</em>")  
    
    # operator detection
    else if which.match(/[\!\=\-\?]$/) && !openString && !openComment
      s = string + "<em class=\"operator\">" + which + "</em>"

    # pre paren detection
    else if which == "(" && !openString && !openComment
      s = string.replace(/(\.)?(?:([^\.\n]*))$/, "$1<em class=\"method\">$2</em>(")      
      
    # detecting quotes    
    else if which == '"' && !openComment
      s = if openString then string.replace(/(\"[^"\\]*(?:\\.[^"\\]*)*)$/, "<em class=\"string\">$1\"</em>") else string + which
        
    # detecting run script command ~
    else if which == "~" && !openComment
      s = string + "<em class=\"run-command\">" + which + "</em>"

    # ignore syntax temporarily or permanently
    else
      s = string + which
      
    # return script formatted string    
    return s


  # style syntax highlighting logic
  styleSyntax = (string, which) ->
   
    # if end of integer (%, ., or px too), close it and continue
    if openInteger && !which.match(/[0-9\.\%pxems]/) && !openString && !openComment
      preformatted_string = string.replace(/([0-9\.\%pxems]*)$/, "<em class=\"int\">$1</em>")
    else
      preformatted_string = string
    
    # open comment detection
    if which == '*' && !openComment && prevSlash
      openComment = true
      s = preformatted_string + which
      
    # closed comment detection    
    else if which == '/' && openComment && prevAsterisk
      openComment = false
      s = preformatted_string.replace(/(\/[^(\/)]*\*)$/, "<em class=\"comment\">$1/</em>") 
      
    # wrap style declaration
    else if which == ':'
      s = preformatted_string.replace(/([a-zA-Z- ^\n]*)$/, '<em class="key">$1</em>:')
      
    # wrap style value 
    else if which == ';'
      # detect hex code
      crazy_reghex = /((#[0-9a-zA-Z]{6})|#(([0-9a-zA-Z]|\<em class\=\"int\"\>|\<\/em\>){12,14}|([0-9a-zA-Z]|\<em class\=\"int\"\>|\<\/em\>){8,10}))$/
      
      # is hex    
      if preformatted_string.match(crazy_reghex)
        s = preformatted_string.replace(crazy_reghex, '<em class="hex">$1</em>;')
      # is standard value      
      else
        s = preformatted_string.replace(/([^:]*)$/, '<em class="value">$1</em>;')

    # wrap selector
    else if which == '{'
      s = preformatted_string.replace(/(.*)$/, '<em class="selector">$1</em>{')
    
    # ignore syntax temporarily or permanently
    else
      s = preformatted_string + which

    # return style formatted string    
    return s


  __js = false
  _code_block = ""

  # write a single character
  writeChar = (which) ->
    if which == "!"
      _PAUSED = true
    
    # toggle CSS/JS on `
    if which == "`"
      # reset it to empty string so as not to show in DOM    
      which = ""
      __js = !__js
      
    # Using JS  
    if __js
      # running a command block. initiated with "~"
      if which == "~" && !openComment
        script_tag = createElement "script"
        # two matches based on prior scenario
        prior_comment_match = /(?:\*\/([^\~]*))$/
        prior_block_match = /([^~]*)$/
        
        if _code_block.match(prior_comment_match)      
          script_tag.innerHTML = _code_block.match(prior_comment_match)[0].replace("*/", "") + "\n\n"
        else
          script_tag.innerHTML = _code_block.match(prior_block_match)[0] + "\n\n"

        $script_area.innerHTML = "" 
        $script_area.appendChild script_tag    
      char = which 
      code_html = scriptSyntax($code_pre.innerHTML, char)
    
    # Using CSS
    else
      char = if which == "~" then "" else which      
      $style_elem.innerHTML += char
      code_html = styleSyntax($code_pre.innerHTML, char)        

    # set states    
    prevAsterisk = (which == "*")
    prevSlash = (which == "/") && !openComment
    openInteger = if which.match(/[0-9]/) || (openInteger && which.match(/[\.\%pxems]/)) then true else false
    if which == '"' then openString = !openString

    # you should not see these charecters
    # if which == "!" || which == "~" 
    #   which = ""
      # code_html = $code_pre.innerHTML

    # add text to code block variable for regex matching.
    _code_block += which
      
    # add character to pre
    $code_pre.innerHTML = code_html

  # write all the chars
  writeChars = (message, index, interval) ->
    if index < message.length
      if index >= _throttle.start && index < _throttle.stop
        interval = 2
      else
        interval = _writing_rate
      $code_pre.scrollTop = $code_pre.scrollHeight 

      if _PAUSED == false
        writeChar message[index++]


      setTimeout (->
        writeChars message, index, interval
      ), interval

  # detect url parameters
  getURLParam = (key, url) ->
    if typeof url == 'undefined'
      url = window.location.href
    match = url.match('[?&]' + key + '=([^&]+)')
    if match then match[1] else 0

  # has version parameter?
  _version = getURLParam "billy"

  # initiate the script
  writeChars(_codes[_version], 0, _writing_rate)




  jQuery ->
    $(document).mouseup ->
      _PAUSED = false