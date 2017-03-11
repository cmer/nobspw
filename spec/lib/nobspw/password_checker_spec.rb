require_relative '../../../lib/nobspw'

NOBSPW.configure do |config|
  config.blacklist = %w(thispasswordisblacklisted)
end

RSpec.describe NOBSPW::PasswordChecker do
  let(:pc) do
    NOBSPW::PasswordChecker.new password: password,
                                name: name,
                                username: username,
                                email: email
  end
  let(:password) { 'my-very-very-strong-password!' }
  let(:name)     { 'James R. Smith' }
  let(:username) { 'funnydog13' }
  let(:email)    { 'james.smith@microsoft.co.uk' }

  describe "determine if password is strong or weak" do
    context 'password is too short' do
      let(:password) do
        length = NOBSPW.configuration.min_password_length - 1
        rand(36**length).to_s(36)
      end

      it 'fails as it should' do
        expect(pc).to_not be_strong
        expect(pc.weak_password_reasons).to include(:password_too_short)
      end
    end

    context 'password is too long' do
      let(:password) do
        length = NOBSPW.configuration.max_password_length + 1
        rand(36**length).to_s(36)
      end

      it 'fails as it should' do
        expect(pc).to_not be_strong
        expect(pc.weak_password_reasons).to include(:password_too_long)
      end
    end

    context 'name is included in password' do
      let(:password) { 'iamjohnthegreat' }
      let(:name)     { 'John Draper'}

      it 'fails as it should' do
        expect(pc).to_not be_strong
        expect(pc.weak_password_reasons).to include(:name_included_in_password)
      end
    end

    context 'email username is included in password' do
      let(:password) { 'iamjohnthegreat' }
      let(:email)    { 'john.draper@microsoft.com'}

      it 'fails as it should' do
        expect(pc).to_not be_strong
        expect(pc.weak_password_reasons).to include(:email_included_in_password)
      end
    end

    context 'email domain is included in password' do
      context 'domain has word separator' do
        let(:password) { 'iamjohnthegreat' }
        let(:email)    { 'mark.draper@john-deere.com'}

        it 'fails as it should' do
          expect(pc).to_not be_strong
          expect(pc.weak_password_reasons).to include(:email_included_in_password)
        end
      end

      context 'domain does not have a word separator' do
        let(:password) { 'iloveteslamotors' }
        let(:email)    { 'elon.musk@teslamotors.com'}

        it 'fails as it should' do
          expect(pc).to_not be_strong
          expect(pc.weak_password_reasons).to include(:email_included_in_password)
        end
      end
    end

    context 'password is blacklisted' do
      let(:password) { 'thispasswordisblacklisted' }

      it 'fails as it should' do
        expect(pc).to_not be_strong
        expect(pc.weak_password_reasons).to include(:password_blacklisted)
      end
    end

    context 'password is in common password dictionary' do
      let(:password) { 'password123' }

      it 'fails as it should' do
        expect(pc).to_not be_strong
        expect(pc.weak_password_reasons).to include(:password_too_common)
      end
    end

    context "password doesn't have enough unique characters" do
      let(:password) { '123xxxxxxx'}

      it 'fails as it should' do
        expect(pc).to_not be_strong
        expect(pc.weak_password_reasons).to include(:not_enough_unique_characters)
      end
    end

    context 'perfectly fine password' do
      let(:password) { 'this-is-a-valid-password' }

      it 'is reported as strong' do
        expect(pc).to be_strong
        expect(pc.weak_password_reasons).to be_empty
      end
    end
  end
end
