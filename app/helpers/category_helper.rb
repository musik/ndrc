module CategoryHelper
  def sort_by_name arr 
    arr.sort{|a,b| a.name.length <=> b.name.length}
  end
end
