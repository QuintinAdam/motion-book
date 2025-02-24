class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # white background
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.backgroundColor = UIColor.whiteColor
    @window.makeKeyAndVisible # This is a special method for UIWindow that tells the system it will be the window receiving touch events and should be drawn to the screen.

    #set box color
    @box_color = UIColor.blueColor

    #blue box
    @blue_view = UIView.alloc.initWithFrame(CGRect.new([10, 40], [100, 100]))

    #old
    # @blue_view.backgroundColor = UIColor.blueColor
    #use box color
    @blue_view.backgroundColor = @box_color

    @window.addSubview(@blue_view)

    # add labels to boxes for testing the index
    add_labels_to_boxes

    #add button
    @add_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @add_button.setTitle("Add", forState:UIControlStateNormal)
    @add_button.sizeToFit
    @add_button.frame = CGRect.new([10, @window.frame.size.height - 10 - @add_button.frame.size.height], @add_button.frame.size)
    @window.addSubview(@add_button)

    #tapped button event add box
    @add_button.addTarget(self, action: "add_tapped", forControlEvents:UIControlEventTouchUpInside)

    #remove button
    @remove_button = UIButton.buttonWithType(UIButtonTypeSystem)
    @remove_button.setTitle("Remove", forState:UIControlStateNormal)
    @remove_button.sizeToFit
    @remove_button.frame = CGRect.new([@add_button.frame.origin.x + @add_button.frame.size.width + 10, @add_button.frame.origin.y], @remove_button.frame.size)
    @window.addSubview(@remove_button)

    # tapped button event remove box
    @remove_button.addTarget(self, action:"remove_tapped", forControlEvents:UIControlEventTouchUpInside)

    @color_field = UITextField.alloc.initWithFrame(CGRectZero)
    @color_field.borderStyle = UITextBorderStyleRoundedRect
    @color_field.text = "Blue"
    @color_field.enablesReturnKeyAutomatically = true
    @color_field.returnKeyType = UIReturnKeyDone
    @color_field.autocapitalizationType = UITextAutocapitalizationTypeNone
    @color_field.sizeToFit
    @color_field.frame = CGRect.new( [@blue_view.frame.origin.x + @blue_view.frame.size.width + 10, @blue_view.frame.origin.y + @color_field.frame.size.height], @color_field.frame.size)
    @window.addSubview(@color_field)

    @color_field.delegate = self

    true
  end

  def add_tapped
    new_view = UIView.alloc.initWithFrame(CGRect.new([0, 0], [100, 100]))
    #old
    # new_view.backgroundColor = UIColor.blueColor
    #use box color
    new_view.backgroundColor = @box_color
    last_view = @window.subviews[0]
    new_view.frame = CGRect.new([last_view.frame.origin.x, last_view.frame.origin.y + last_view.frame.size.height + 10], last_view.frame.size)
    @window.insertSubview(new_view, atIndex:0)

    # recall index in boxes
    add_labels_to_boxes
  end

  def remove_tapped
    # make sure we only deal with boxes
    # old way because we added labels we need to change the code
    # other_views = @window.subviews.reject do |view|
    #   view.is_a?(UIButton)
    # end

    # new
    other_views = self.boxes

    # the last box created
    last_view = other_views.last
    # if there are no more boxes?
    return unless last_view && other_views.count > 1
    # Animations revolve around the UIView.animateWithDuration:animations: group of methods (you can also use animateWithDuration:delay:options:animations:completions: if you need to fine-tune things)
    # animations_block = lambda do
    #   last_view.alpha = 0
    #   last_view.backgroundColor = UIColor.redColor
    #   other_views.reject do |view|
    #     view == last_view
    #   end.each do |view|
    #     new_origin = [view.frame.origin.x, view.frame.origin.y - (last_view.frame.size.height + 10)]
    #     view.frame = CGRect.new(new_origin, view.frame.size)
    #   end
    # end

    # clean up view This will remove the view from its parent's subviews and be erased from the screen.
    # completion_block = lambda do |finished|
    #   last_view.removeFromSuperview
    #   # update the labels after removed from views
    #   add_labels_to_boxes
    # end

    # UIView.animateWithDuration(0.5,
    #   animations: animations_block,
    #   completion: completion_block
    # )

    # sugar cube replacement of the animation
    last_view.fade_out do |view|
      last_view.removeFromSuperview
      add_labels_to_boxes
    end

    other_views.each do |view|
      new_origin = [
        view.frame.origin.x,
        view.frame.origin.y - (last_view.frame.size.height)
      ]
      view.move_to new_origin
    end
  end

  def add_label_to_box(box)
    box.subviews.each do |subview|
      # remove all subviews from box, which handles the case where we call this method multiple times on the same view
      subview.removeFromSuperview
    end
    index_of_box = @window.subviews.index(box)
    # CGRectZero shorthand for a rectangle at the origin and no size
    label = UILabel.alloc.initWithFrame(CGRectZero)
    label.text = "#{index_of_box}"
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    # sizeToFit() will precisely fill the frame to fit the text, leaving no padding
    label.sizeToFit
    # use the center property of UIView, which is shorthand for putting the center of a view at a point
    label.center = [box.frame.size.width / 2, box.frame.size.height / 2]
    box.addSubview(label)
  end

  def boxes
    # grab only boxes
    @window.subviews.reject do |view|
      # ignore the new text field
      # view.is_a?(UIButton) or view.is_a?(UILabel)
      view.is_a?(UIButton) or view.is_a?(UILabel) or view.is_a?(UITextField)
    end
  end

  def add_labels_to_boxes
    # helper method to call both of the new methods.
    # grab all the boxes go through each ad add the label
    self.boxes.each do |box|
      add_label_to_box(box)
    end
  end

  def textFieldShouldReturn(textField)
    color_tapped
    textField.resignFirstResponder
    false
  end

  def color_tapped
    color_prefix = @color_field.text
    color_method = "#{color_prefix.downcase}Color"
    if UIColor.respond_to?(color_method)
      @box_color = UIColor.send(color_method)
      self.boxes.each do |box|
        box.backgroundColor = @box_color
      end
    else
      UIAlertView.alloc.initWithTitle("Invalid Color",
        message: "#{color_prefix} is not a valid color",
        delegate: nil,
        cancelButtonTitle: "OK",
        otherButtonTitles: nil
      ).show
    end
  end
end
