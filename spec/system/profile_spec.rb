require 'rails_helper'

RSpec.describe "Profile", type: :system do
  before do
    driven_by :rack_test
  end

  before do
    @user = create(:user,
                  complete_name: "Tester McTest",
                  citation_name: "McTest, T.",
                  email: "test@testers.test",
                  affiliation: "Research test center",
                  github: "tester-user-33",
                  domains: "big trees"
                  )

    create(:language, name: "Ruby")
    create(:language, name: "Julia")
    @user.languages << create(:language, name: "Python")
    create(:area, name: "Astronomy")
    create(:area, name: "Biomedicine")
    @user.areas << create(:area, name: "Plant Science")
  end

  scenario "Is not public" do
    visit root_path
    expect(page).to_not have_link("Profile")

    visit profile_path
    expect(page).to have_content("Please login first")
    expect(page).to_not have_content("Profile")
    expect(page).to have_current_path(root_path)
  end

  scenario "Show all user data" do
    login_as @user

    visit profile_path

    expect(page).to have_content("GitHub: tester-user-33")
    expect(find_field("user_complete_name").value).to eq("Tester McTest")
    expect(find_field("user_citation_name").value).to eq("McTest, T.")
    expect(find_field("user_email").value).to eq("test@testers.test")
    expect(find_field("user_affiliation").value).to eq("Research test center")
    expect(find_field("user_domains").value).to eq("big trees")
    expect(find_field("user_twitter").value.to_s).to eq("")
    expect(find_field("user_reviewer")).to_not be_checked
    expect(page).to have_content("Plant Science")
    expect(page).to_not have_content("Astronomy")
    expect(find_field("Python")).to be_checked
    expect(find_field("Julia")).to_not be_checked
  end

  scenario "Users can update their data" do
    login_as @user

    visit profile_path

    fill_in "user_citation_name", with: "McT, T."
    fill_in "user_affiliation", with: "Testing University"
    fill_in "user_domains", with: "Rainforest, Forests"
    fill_in "user_twitter", with: "@tester33-twitter"
    check("user_reviewer")
    check('Julia')
    check('Ruby')
    uncheck('Python')

    click_button "Save profile"

    expect(page).to have_content("Your profile was successfully updated.")
    expect(find_field("user_complete_name").value).to eq("Tester McTest")
    expect(find_field("user_citation_name").value).to eq("McT, T.")
    expect(find_field("user_email").value).to eq("test@testers.test")
    expect(find_field("user_affiliation").value).to eq("Testing University")
    expect(find_field("user_domains").value).to eq("Rainforest, Forests")
    expect(find_field("user_twitter").value).to eq("tester33-twitter")
    expect(find_field("user_reviewer")).to be_checked
    expect(find_field("Python")).to_not be_checked
    expect(find_field("Julia")).to be_checked
    expect(find_field("Ruby")).to be_checked
  end

  scenario "Users can add ORCID" do
    login_as @user

    visit profile_path

    expect(page).to have_button("Add your ORCID")

    @user.orcid = "0000-0000-0000-0001"
    @user.save

    visit profile_path

    expect(page).to_not have_button("Add your ORCID")
    expect(page).to have_content("GitHub: tester-user-33")
    expect(page).to have_content("Orcid: 0000-0000-0000-0001")
  end
end
