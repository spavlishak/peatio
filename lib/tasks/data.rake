namespace :data do
  task feed: :environment do
    logger = Logger.new(STDOUT)

    ENV.fetch('n', 1).to_i.times do
      password = Faker::Internet.password
      email = Faker::Internet.email

      identity = Identity.find_or_create_by(email: email)
      identity.password = password
      identity.password_confirmation = password
      identity.is_active = true
      identity.save!

      member = Member.find_or_create_by(email: email)
      member.authentications.build(provider: 'identity', uid: identity.id)
      member.save!
      member.active!

      member.id_document.update(
        name: Faker::Name.name,
        address: Faker::Address.street_address,
        city: Faker::Address.city,
        country: Faker::Address.country,
        zipcode: Faker::Address.zip,
        id_document_type: :id_card,
        id_document_number: Faker::Number.number(15)
      )

      member.id_document.approve!

      member.update(phone_number: Faker::PhoneNumber.cell_phone)
      member.two_factors.each(&:active!)

      logger.info("Created #{member.id_document.name} <#{identity.email}> with password #{password}")
    end

    logger.info 'Database feed finished!'
  end
end
