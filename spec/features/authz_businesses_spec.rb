require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'

RSpec.feature "AuthzBusinesses", type: :feature, js:true do
  include_context "db_cleanup_each"
  include SubjectsUiHelper

  let(:admin)         { apply_admin(create_user) }
  let(:originator)    { apply_originator(create_user, Business) }
  let(:organizer)     { originator }
  let(:member)        { create_user }
  let(:authenticated) { create_user }
  let(:business_props)   { FactoryBot.attributes_for(:business) }
  let(:businesses)       { FactoryBot.create_list(:business, 3,
                                                  :with_roles,
                                                  :originator_id=>originator[:id],
                                                  :member_id=>member[:id]) }
  let(:business)         { businesses[0] }

  shared_examples "cannot list businesses" do
    it "does not list businesses" do
      visit_businesses businesses
      expect(page).to have_css(".business-list",:visible=>false)
    end
  end
  shared_examples "can list businesses" do
    it "lists businesses" do
      visit_businesses businesses
      within("sd-business-selector .business-list") do
        businesses.each do |t|
          expect(page).to have_css("li a",:text=>t.offer)
          expect(page).to have_css(".business_id",:text=>t.id,:visible=>false)
          expect(page).to have_no_css(".business_id") #should be hidden
        end
      end
    end
  end

  shared_examples "displays correct buttons for role" do |displayed,not_displayed|
    it "displays correct buttons" do
      within("sd-business-editor .business-form") do
        displayed.each do |button|
          #create is present and disabled until name filled in
          disabled_value = ["Create Business","Update Business"].include? button
          expect(page).to have_button(button, disabled:disabled_value,:wait=>5)
        end
        not_displayed.each do |button|
          expect(page).to_not have_button(button)
        end
      end
    end
  end

  shared_examples "organizer has invalid business" do
    it "cannot edit description for invalid business" do
      within("sd-business-editor .business-form") do
        expect(page).to have_field("business-offer", :visible=>true)
        expect(page).to have_no_field("business-description")
      end
    end
    it "cannot create invalid business" do
      within("sd-business-editor .business-form") do
        expect(page).to have_field("business-offer", :with=>"")
        expect(page).to have_button("Create Business", :disabled=>true)
      end
    end
  end

  shared_examples "can create valid business" do
    it "creates business" do
      within ("sd-business-editor .business-form") do
        fill_in("business-offer", :with=>business_props[:offer])
        fill_in("business-description", :with=>business_props[:description])
        click_button("Create Business")
        expect(page).to have_no_button("Create Business")
      end

      #new business shows up in list
      visit_businesses businesses
      expect(page).to have_css(".business-list ul li a",:text=>business_props[:offer])
    end
  end

  shared_examples "displays business" do
    it "can display specific business" do
      visit_business business
      within("sd-business-editor .business-form") do
        expect(page).to have_css(".business_id", :text=>business.id, :visible=>false)
        expect(page).to have_field("business-offer", :with=>business.offer)
        expect(page).to have_no_css(".business_id") #should be hidden
      end
    end
  end

  shared_examples "can clear business" do
    it "clears business" do
      within("sd-business-editor .business-form") do
        expect(page).to have_css(".business_id", :text=>business.id, :visible=>false)
        expect(page).to have_field("business-offer", :with=>business.offer)
        click_button("Clear Business")
        expect(page).to have_no_css(".business_id", :text=>business.id, :visible=>false)
        expect(page).to have_field("business-offer", :with=>"")
        expect(page).to have_field("business-description", :visible=>false, :with=>"")
      end
    end
  end

  shared_examples "cannot see details" do
    it "hides details" do
      within("sd-business-editor .business-form") do
        expect(page).to have_field("business-offer", :with=>business.offer)
        expect(page).to have_field("business-description", :with=>business.description)
      end
    end
  end
  shared_examples "can see details" do |readonly|
    it "shows details" do
      within("sd-business-editor .business-form") do
        expect(page).to have_field("business-offer", :with=>business.offer)
        expect(page).to have_field("business-description", :with=>business.description)
      end
    end
  end

  shared_examples "cannot update business" do
    it "fields read-only" do
      within("sd-business-editor .business-form") do
        expect(page).to have_field("business-offer", :with=>business.offer, :readonly=>true)
        expect(page).to have_field("business-description", :with=>business.description, :readonly=>true)
      end
    end
  end

  shared_examples "can update business" do
    it "updates business" do
      within("sd-business-editor .business-form") do
        fill_in("business-offer", :with=>business_props[:offer])
        fill_in("business-description", :with=>business_props[:description])
        click_button("Update Business")
        expect(page).to have_no_button("Update Business")
        click_button("Clear Business")
        expect(page).to have_no_button("Clear Business")
      end

      #updated business shows up in list
      within("sd-business-selector .business-list") do
        expect(page).to have_css("li a",:text=>business_props[:offer],:wait=>5)
      end
    end
  end

  def update_text_field field_name
    within("sd-business-editor .business-form") do
      expect(page).to have_no_button("Update Business")
      new_text=Faker::Lorem.characters(5000)
      fill_in(field_name, :with=>new_text)
      text_field=find("textarea[offer='#{field_name}']")
      expect(text_field.value.size).to eq(4000)  #stops as maxlength
      expect(text_field.value).to eq(new_text.slice(0,4000))
    end
  end

  shared_examples "cannot update to invalid business" do
    it "cannot update with invalid name" do
      within("sd-business-editor .business-form") do
          #initialize disabled becuase not $dirty
        expect(page).to have_no_button("Update Business")
        fill_in("business-offer", :with=>"abc")
        expect(page).to have_button("Update Business", :disabled=>false)
        fill_in("business-offer", :with=>"")
        expect(page).to have_button("Update Business", :disabled=>true)
      end
    end
    it "cannot update with invalid description" do
      update_text_field "business-description"
    end
  end

  shared_examples "can delete business" do
    it "deletes business" do
      visit_businesses businesses
      within("sd-business-selector .business-list") do
        expect(page).to have_css(".business_id", :text=>business.id, :visible=>false)
        expect(page).to have_css("li a",:text=>business.offer)
      end

      visit_business business
      within("sd-business-editor .business-form") do
        click_button("Delete Business")
        expect(page).to have_no_button("Delete Business",:wait=>5)
      end

      within("sd-business-selector .business-list") do
        expect(page).to have_no_css(".business_id", :text=>business.id, :visible=>false)
        expect(page).to have_no_css("li a",:text=>business.offer)
      end
    end
  end

  context "no business selected" do
    after(:each) { logout }

    context "unauthenticated user" do
      before(:each) { visit_businesses businesses }
      it_behaves_like "cannot list businesses"
      it_behaves_like "displays correct buttons for role",
          [],
          ["Create Business", "Clear Business", "Update Business", "Delete Business"]
    end
    context "authenticated user" do
      before(:each) { login authenticated; visit_businesses businesses}
      it_behaves_like "cannot list businesses"
      it_behaves_like "displays correct buttons for role",
          [],
          ["Create Business"], ["Clear Business", "Update Business", "Delete Business"]
    end
    context "originator user" do
      before(:each) { login originator; visit_businesses businesses }
      it_behaves_like "displays correct buttons for role",
          ["Create Business"],
          ["Clear Business", "Update Business", "Delete Business"]
      it_behaves_like "can list businesses"
      it_behaves_like "organizer has invalid business"
      it_behaves_like "can create valid business"
    end
    context "admin user" do
      before(:each) { login admin; visit_businesses businesses }
      it_behaves_like "displays correct buttons for role",
          [],
          ["Create Business", "Clear Business", "Update Business", "Delete Business"]
      it_behaves_like "can list businesses"
    end
  end

  context "businesses posted" do
    before(:each) do
      businesses #touch businesses to have them created before visiting page
      visit "#{ui_path}/#/businesses/"
      logout
      expect(page).to have_css("sd-business-selector")
    end
    after(:each) { logout }

    def select_business
      within("sd-business-selector .business-list") do
        find("span.business_id",:text=>business.id, :visible=>false).find(:xpath,"..").click
      end
      within("sd-business-editor .business-form") do
        expect(page).to have_css("span.business_id",:text=>business.id, :visible=>false)
      end
    end

    context "user selects business" do
      it_behaves_like "displays business"

      context "anonymous user" do
        before(:each) { visit "#{ui_path}/#/businesses/#{business.id}" }
        it_behaves_like "displays correct buttons for role",
            [],
            ["Clear Business"], ["Create Business", "Update Business", "Delete Business"]
        it_behaves_like "cannot see details"
      end

      context "authenticated user" do
        before(:each) { visit "#{ui_path}/#/businesses/#{business.id}" }
        it_behaves_like "displays correct buttons for role",
            [],
            ["Clear Business", "Create Business", "Update Business", "Delete Business"]
        it_behaves_like "cannot see details"
      end

      context "member user" do
        before(:each) { login member; select_business }
        it_behaves_like "displays correct buttons for role",
            ["Clear Business"],
            ["Create Business", "Update Business", "Delete Business"]
        it_behaves_like "displays business"
        it_behaves_like "can see details", true
        it_behaves_like "can clear business"
        it_behaves_like "cannot update business"
      end

      context "organizer user" do
        before(:each) { login organizer; select_business }
        it_behaves_like "displays correct buttons for role",
            ["Clear Business", "Update Business", "Delete Business"],
            ["Create Business"]
        it_behaves_like "displays business"
        it_behaves_like "can see details", false
        it_behaves_like "can clear business"
        it_behaves_like "can update business"
        it_behaves_like "cannot update to invalid business"
        it_behaves_like "can delete business"
      end

      context "admin user" do
        before(:each) { login admin; select_business }
        it_behaves_like "displays correct buttons for role",
            ["Clear Business", "Delete Business"],
            ["Create Business", "Update Business"]
        it_behaves_like "displays business"
        it_behaves_like "can see details", true
        it_behaves_like "can clear business"
        it_behaves_like "cannot update business"
        it_behaves_like "can delete business"
      end
    end

    context "user logs out" do
      it "displays last selected business as non-member" do
        login organizer
        select_business
        within("sd-business-editor .business-form") do
          expect(page).to have_field("business-offer", :with=>business.offer)
          expect(page).to have_field("business-description", :visible=>true,
                                                   :readonly=>false)
          expect(page).to have_css("button");
        end

        logout
        within("sd-business-editor .business-form") do
          expect(page).to have_field("business-offer", :with=>business.offer,
                                                   :readonly=>true)
          expect(page).to have_field("business-description", :with=>business.description,
                                                   :readonly=>true)
          expect(page).to have_no_css("button");
        end
      end
    end

  end
end
