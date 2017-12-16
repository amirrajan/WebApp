class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @index_view_controller = IndexViewController.new

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @index_view_controller
    @window.makeKeyAndVisible

    true
  end

end
