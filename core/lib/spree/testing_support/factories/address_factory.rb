# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/state_factory'
  require 'spree/testing_support/factories/country_factory'
end
FactoryBot.define do
  factory :address, class: 'Spree::Address' do
    transient do
      # There's `Spree::Address#country_iso=`, prohibiting me from using `country_iso` here
      country_iso_code { 'US' }
      state_code { 'AL' }
    end

    name { 'John Von Doe' }
    company { 'Company' }
    address1 { '10 Lovely Street' }
    address2 { 'Northwest' }
    city { 'Herndon' }
    sequence(:zipcode, 10001) { |i| i.to_s }
    phone { '555-555-0199' }
    alternative_phone { '555-555-0199' }

    state do |address|
      Spree::State.joins(:country).where('spree_countries.iso = (?)', country_iso_code).find_by(abbr: state_code) ||
        address.association(
          :state,
          strategy: :create,
          country_iso: country_iso_code,
          state_code: state_code
        )
    end

    country do |address|
      if address.state
        address.state.country
      else
        address.association(:country, strategy: :create, iso: country_iso_code)
      end
    end
  end

  factory :ship_address, parent: :address do
    address1 { 'A Different Road' }
  end

  factory :bill_address, parent: :address do
    address1 { 'PO Box 1337' }
  end
end
