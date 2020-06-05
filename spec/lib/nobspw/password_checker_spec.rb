require_relative '../../../lib/nobspw'

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
    context 'password is nil' do
      let(:password) { nil }

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons.length).to eq 1
        expect(pc.reasons).to include(:password_empty)
      end
    end

    context 'password is empty string' do
      let(:password) { '' }

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons.length).to eq 1
        expect(pc.reasons).to include(:password_empty)
      end
    end

    context 'password is too short' do
      let(:password) do
        length = NOBSPW.configuration.min_password_length - 1
        rand(36**length).to_s(36)
      end

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons).to include(:password_too_short)
      end
    end

    context 'password is too long' do
      let(:password) do
        alphabet = ('0'..'9').to_a + ('a'..'z').to_a
        length = NOBSPW.configuration.max_password_length + 1
        length.times.map { alphabet.sample }.join
      end

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons).to include(:password_too_long)
      end
    end

    context 'name is included in password' do
      let(:password) { 'iamjohnthegreat' }
      let(:name)     { 'John Draper'}

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons).to include(:name_included_in_password)
      end
    end

    context 'username is included in password' do
      let(:password) { 'iamjohnthegreat' }
      let(:username) { 'johnthegreat'}

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons).to include(:username_included_in_password)
      end
    end

    context 'email username is included in password' do
      let(:password) { 'iamjohnthegreat' }
      let(:email)    { 'john.draper@microsoft.com'}

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons).to include(:email_included_in_password)
      end
    end

    context 'email domain is included in password' do
      context 'domain has word separator' do
        let(:password) { 'iamjohnthegreat' }
        let(:email)    { 'mark.draper@john-deere.com'}

        it 'fails as it should' do
          expect(pc).to be_weak
          expect(pc.reasons).to include(:email_included_in_password)
        end
      end

      context 'domain does not have a word separator' do
        let(:password) { 'iloveteslamotors' }
        let(:email)    { 'elon.musk@teslamotors.com'}

        it 'fails as it should' do
          expect(pc).to be_weak
          expect(pc.reasons).to include(:email_included_in_password)
        end
      end
    end

    context 'email is not valid' do
      context 'email is nil' do
        let(:email) { nil }

        it 'ignores the malformed email address' do
          expect(pc).to be_strong
          expect(pc.reasons).to be_empty
        end
      end

      context 'email is missing @' do
        let(:email) { 'johndoeatexample.com' }

        it 'ignores the malformed email address' do
          expect(pc).to be_strong
          expect(pc.reasons).to be_empty
        end
      end

      context 'email is a random email-like string' do
        let(:email) { 'johndoe at example.com' }

        it 'ignores the malformed email address' do
          expect(pc).to be_strong
          expect(pc.reasons).to be_empty
        end
      end

      context 'email is gibberish' do
        let(:email) { ',jbsi7tyhbd8ygudsudsig8t6yugwe,.cx3' }

        it 'ignores the malformed email address' do
          expect(pc).to be_strong
          expect(pc.reasons).to be_empty
        end
      end

    end

    context 'password is blacklisted' do
      before(:each) do
        NOBSPW.configure do |config|
          config.blacklist = ['thispasswordisblacklisted', /middle/i]
        end
      end

      context 'match against string' do
        let(:password) { 'thispasswordisblacklisted' }

        it 'fails as it should' do
          expect(pc).to be_weak
          expect(pc.reasons).to include(:password_not_allowed)
        end
      end

      context 'match against regex' do
        let(:password) { 'SomewhereInTheMiddleOfMyPassword' }

        it 'fails as it should' do
          expect(pc).to be_weak
          expect(pc.reasons).to include(:password_not_allowed)
        end
      end
    end

    context 'password is in common password dictionary' do
      let(:password) { 'password123' }

      context 'use shell grep' do
        it 'fails as it should' do
          expect(pc).to be_weak
          expect(pc.reasons).to include(:password_too_common)
        end
      end

      context 'use Ruby grep' do
        before {
          NOBSPW.configure do |config|
            config.use_ruby_grep = true
          end
        }

        it 'fails as it should' do
          expect(pc).to be_weak
          expect(pc.reasons).to include(:password_too_common)
        end
      end
    end

    context 'password contains strong password with illegal shell characters' do
      let(:password) { '^password123\./$%!@#!^^$$'}

      it 'is reported as strong' do
        expect(pc).to be_strong
        expect(pc.reasons).to be_empty
      end
    end

    context "password doesn't have enough unique characters" do
      let(:password) { '123xxxxxxx'}

      it 'fails as it should' do
        expect(pc).to be_weak
        expect(pc.reasons).to include(:not_enough_unique_characters)
      end
    end

    context 'perfectly fine password' do
      let(:password) { 'this-is-a-valid-password' }

      it 'is reported as strong' do
        expect(pc).to be_strong
        expect(pc.reasons).to be_empty
      end
    end
  end
end
