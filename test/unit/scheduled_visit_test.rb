require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ScheduledVisitTest < ActiveSupport::TestCase
  context '.before' do
    should 'return all scheduled visits before a given date inclusive, ordered by date' do
      expected = [
        ScheduledVisit.make(:scheduled_for => 2.days.from_now),
        ScheduledVisit.make(:scheduled_for => 2.days.ago)
      ].reverse
      chaff = ScheduledVisit.make(:scheduled_for => 3.days.from_now)

      ScheduledVisit.before(2.days.from_now).should == expected
    end
  end

  context 'a scheduled visit today' do
    setup do
      @visit = ScheduledVisit.make(:scheduled_for => Date.today)
      @child = @visit.child
    end

    context '#complete!' do
      setup do
        @visit.complete!
      end

      should_change('the child home_visits count', :by => 1) do
        @child.home_visits.count
      end

      should 'set the date of the newly-created home visit' do
        @child.home_visits.last.happened_on.should == @visit.scheduled_for
      end

      should 'destroy the scheduled visit' do
        lambda {
          @visit.reload
        }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context '#completable?' do
      should 'be true' do
        @visit.completable?.should == true
      end
    end
  end

  context 'a scheduled visit in the future' do
    setup do
      @visit = ScheduledVisit.make(:scheduled_for => 1.day.from_now)
      @child = @visit.child
    end

    context '#complete!' do
      setup do
        @visit.complete!
      end

      should_not_change('the child home_visits count') do
        @child.home_visits.count
      end

      should 'not destroy the visit' do
        lambda {
          @visit.reload
        }.should_not raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context '#completable?' do
      should 'be false' do
        @visit.completable?.should == false
      end
    end
  end
end
