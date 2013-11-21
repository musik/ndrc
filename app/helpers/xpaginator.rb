class Xpaginator < Kaminari::Helpers::Paginator
  def relevant_pages(options)
    left_window_plus_one = []
    _start = (options[:current_page].to_i / options[:window]) * options[:window] + 1
    inside_window_plus_each_sides = _start.upto(_start + options[:window] - 1).to_a
    _all = options[:total_pages] / options[:window]  + 1
    right_window_plus_one = _all > 1  ? Array.new(_all){|i| i*options[:window] + 1} : []
    #@window_options[:window] = options[:total_pages]

    (inside_window_plus_each_sides + right_window_plus_one).reject {|x| (x < 1) || (x > options[:total_pages])}
  end
end
