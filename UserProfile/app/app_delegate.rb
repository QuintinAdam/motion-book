class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    # setup user
    # @user = User.new
    # @user.id = "123"
    # @user.name = "Clay"
    # @user.email = "clay@mail.com"
    # lOAD user
    @user = User.load
    # or make new one
    @user ||= User.new(id: "123", name: "Clay",email: "clay@mail.com", phone: "555-555-5555")
    @user_controller = UserController.alloc.initWithUser(@user)
    @nav_controller = UINavigationController.alloc.initWithRootViewController(@user_controller)
    @window.rootViewController = @nav_controller
    @window.makeKeyAndVisible

    puts 'user = App.delegate.instance_variable_get("@user")'
    puts 'user.email = "my_new_email@host.com"'
    puts 'user.name = "Quintin"'
    true
  end

  # Apple recommends we save user data after the application has entered the background (as not to accidentally freeze the interface),
  def applicationDidEnterBackground(application)
    @user.save
  end
end
