class StateMigrator
  def migrate!
    Child.find_each do |child|
      last_event = child.events.find(:first,
        :conditions => ['type != ?', 'HomeVisit'],
        :order      => 'happened_on DESC, created_at DESC')

      child.state = last_event.try(:to_state) || 'unknown'
      child.save!
    end
  end
end
