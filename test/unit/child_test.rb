require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ChildTest < ActiveSupport::TestCase
  should_have_many :events, :dependent => :destroy

  should_have_many :arrivals
  should_have_many :home_visits
  should_have_many :offsite_boardings
  should_have_many :reunifications
  should_have_many :dropouts
  should_have_many :terminations

  should_belong_to :social_worker

  should_have_attached_file :headshot

  should_validate_presence_of :name

  context '.search' do
    should 'return an empty list when given nil' do
      Child.search(nil).should == []
    end
  end

  should 'normalize name' do
    assert_equal "Emmanuel Lang'eda", Child.make(:name => "EMMANUEL lang'eda").name
  end

  context 'given an existing Child' do
    setup do
      @existing_child = Child.make
    end

    context 'a second child with the same name' do
      setup do
        @child = Child.make_unsaved(
          :ignore_potential_duplicates => false,
          :name => @existing_child.name)
      end

      should 'not be valid' do
        assert !@child.valid?
      end

      should 'have potential duplicate children' do
        assert_equal [@existing_child], @child.potential_duplicates
      end

      should 'have :potential_duplicates_found error on base' do
        @child.valid?
        assert @child.errors.on(:base).include?('Potential duplicates found')
      end

      context 'overriding duplicate check' do
        setup do
          @child.ignore_potential_duplicates = 'Some string from the button name'
        end

        should 'be valid' do
          assert @child.valid?
        end
      end
    end
  end

  context 'length of stay' do
    setup { @child = Child.make }

    should 'be nil for a child with no Arrivals' do
      assert_nil @child.length_of_stay
    end

    context 'for a child who arrived 3 weeks ago' do
      setup do
        @child.arrivals.make(:happened_on => 3.weeks.ago)
      end

      should 'be number of days since Arrival' do
        assert_equal 21, @child.length_of_stay
      end

      context 'measuring from a different day' do
        should 'adjust the result' do
          assert_equal 14, @child.length_of_stay(1.week.ago)
        end

        should 'exclude newer events' do
          assert_nil @child.length_of_stay(4.weeks.ago)
        end
      end

      context 'and dropped out 2 weeks ago' do
        setup do
          @child.dropouts.make(:happened_on => 2.weeks.ago)
        end

        should 'be number of days from Arrival to Dropout' do
          assert_equal 7, @child.length_of_stay
        end
      end

      context 'and who, oops, also arrived 5 weeks ago (so that we make sure we honor ordering)' do
        setup do
          @child.arrivals.make(:happened_on => 5.weeks.ago)
        end

        should 'be number of days since Arrival' do
          assert_equal 35, @child.length_of_stay
        end
      end
    end
  end
end
