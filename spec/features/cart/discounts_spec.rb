require 'rails_helper'

RSpec.describe 'Merchant Discount New Page' do
  describe 'As a Merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.00, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      @naf = User.create!(name: 'Naftali Schaechter',  address: '190 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'nafnaf@naf.naf', password: 'iamnaf')
      @discount_1 = @merchant_1.discounts.create!(percentage: 10, required_amount: 5)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@naf)
    end

    it 'I can add an item to my car and receive a discount' do
      visit "/items/#{@ogre.id}"

      click_button 'Add to Cart'

      visit '/cart'

      within "#item-#{@ogre.id}" do
        expect(page).to have_content("Subtotal: $20.00")

        click_button 'More of This!'
        click_button 'More of This!'
        click_button 'More of This!'

        expect(page).to have_content("Subtotal: $80.00")

        click_button 'More of This!'

        expect(page).to have_content("Subtotal: $90.00")
        expect(page).to_not have_content("Subtotal: $100.00")
      end
    end

    it 'A discount will not be applied if I hit the minimum quantity but only with more than one item type' do
      visit "/items/#{@ogre.id}"

      click_button 'Add to Cart'

      visit "/items/#{@giant.id}"

      click_button 'Add to Cart'

      visit '/cart'

      within "#item-#{@ogre.id}" do
        expect(page).to have_content("Subtotal: $20.00")

        click_button 'More of This!'
        click_button 'More of This!'
        click_button 'More of This!'

        expect(page).to have_content("Subtotal: $80.00")
      end

      within "#item-#{@giant.id}" do
        expect(page).to have_content("Subtotal: $50.00")

        click_button 'More of This!'

        expect(page).to have_content("Subtotal: $100.00")
      end

      within "#item-#{@ogre.id}" do
        expect(page).to have_content("Subtotal: $80.00")
      end
    end
  end
end
