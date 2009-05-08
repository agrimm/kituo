ActionController::Routing::Routes.draw do |map|
  map.resources :children, :collection => { :onsite => :get, :boarding_offsite => :get, :dropped_out => :get, :reunified => :get, :terminated => :get } do |child|
    child.resource :headshot
    child.resources :arrivals, :offsite_boardings, :reunifications, :dropouts, :terminations
  end

  map.root :controller => 'children'
end
