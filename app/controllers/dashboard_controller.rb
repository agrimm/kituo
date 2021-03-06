class DashboardController < ApplicationController
  before_filter :require_sign_in

  def show
    case current_user.role
    when 'social_worker'
      @scheduled_visits   = current_user.scheduled_visits.before(2.weeks.from_now).sort_by {|x| x.child.name }
      @recommended_visits = current_user.recommended_visits(:limit => 4).sort_by {|x| x.child.name }
      @search_results     = current_user.children.search(params[:search]).map { |child| RecommendedVisit.new(child) }
      @new_children       = Child.recent.all(:limit => 5)
    when 'social_work_coordinator'
      @children_requiring_social_workers = Child.by_name.find_all_by_social_worker_id(nil)
      @statistics = Statistics.new
    when 'development_officer'
      @children_requiring_headshots = Child.by_name.find_all_by_headshot_file_name(nil)
      @statistics = Statistics.new
    when 'database_administrator'
      @new_children   = Child.recent.all(:limit => 5)
      @search_results = Child.search(params[:search])
    else
      raise "Unknown caregiver role: #{current_user.inspect}"
    end

    render current_user.role
  end
end
