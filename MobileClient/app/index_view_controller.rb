class IndexViewController < UIViewController
  attr_accessor :web_view

  def loadView
    super

    $index = self
    initialize_reverse_proxy
    add_webview
    goto_url "http://localhost:3000"
  end

  def add_webview
    @web_view = WKWebView.new
    @web_view.UIDelegate = self
    @web_view.navigationDelegate = self
    @web_view.frame = CGRectMake(0, 0, device_screen_width, device_screen_height)
    view.addSubview(@web_view)
  end

  def initialize_reverse_proxy
    ReverseProxy.debug = 2
    ReverseProxy.delegate = self
    NSURLProtocol.registerClass(ReverseProxy)
  end

  def startedLoading url
    puts "started loading #{url}"
  end

  def startedLoading url
    puts "completed loading #{url}"
  end

  def device_screen_height
    UIScreen.mainScreen.bounds.size.height
  end

  def device_screen_width
    UIScreen.mainScreen.bounds.size.width
  end

  def webView(webView, shouldStartLoadWithRequest: request, navigationType: navigation_type)
    true
  end

  def remove_element_at_point(x, y)
    script = <<-SCRIPT
      var x = document.elementFromPoint(#{x}, #{y});
      var results = [];
      if(x) {
        var attributes = {};
        for (var attributeIndex = 0; attributeIndex < x.attributes.length; attributeIndex++) {
          var attribute = x.attributes[attributeIndex];
          attributes[attribute.nodeName] = attribute.nodeValue;
        }
        results.push(attributes);
      }
      if(x) { x.remove(); }
      JSON.stringify(results);
    SCRIPT

    evaluate_js(script) { |r, e| puts(parse(r), e && e.localizedDescription) }
  end

  def remove_popup
    evaluate_js(<<-SCRIPT) { |r, e| puts e }
      var x = document.querySelectorAll('.DualPartInterstitial');
      var results = [ ];
      var index = 0;
      for(index = 0; index < x.length; index++) {
        x[index].remove();
      }
    SCRIPT
  end

  def poll_for_loading_complete
    evaluate_js('document.readyState') do |result, error|
      if result != "complete" || @web_view.isLoading
        NSTimer.scheduledTimerWithTimeInterval(0.25,
                                               target: self,
                                               selector: 'poll_for_loading_complete',
                                               userInfo: nil,
                                               repeats: false)
      else
        remove_popup
      end
    end
  end

  def query_select_all css
    value = <<-SCRIPT
      var x = document.querySelectorAll('#{css}');
      var results = [ ];
      var index = 0;
      for(index = 0; index < x.length; index++) {
        console.log(x);
        var attributes = {};
        for (var attributeIndex = 0; attributeIndex < x[index].attributes.length; attributeIndex++) {
          var attribute = x[index].attributes[attributeIndex];
          attributes[attribute.nodeName] = attribute.nodeValue;
        }
        results.push(attributes);
      }
      JSON.stringify(results);
    SCRIPT

    evaluate_js(value) do |result, error|
      puts parse(result)
    end
  end

  def parse(str_data)
    return nil unless str_data
    data = str_data.respond_to?('dataUsingEncoding:') ? str_data.dataUsingEncoding(NSUTF8StringEncoding) : str_data
    opts = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
    error = Pointer.new(:id)
    obj = NSJSONSerialization.JSONObjectWithData(data, options: opts, error: error)
    raise ParserError, error[0].description if error[0]
    if block_given?
      yield obj
    else
      obj
    end
  end


  def evaluate_js script, &block
    @web_view.evaluateJavaScript(
      script, completionHandler: proc do |result, error|
        block.call result, error if block
      end)
  end

  def goto_url(address)
    url = NSURL.URLWithString(address)
    requestObj = NSURLRequest.requestWithURL(url)
    @web_view.loadRequest(requestObj)
    poll_for_loading_complete
  end
end
