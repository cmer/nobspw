require_relative '../../../../lib/nobspw'
require_relative '../../../helpers/models/user'

RSpec.describe ActiveModel::Validations::PasswordValidator do
  before(:each) {
    NOBSPW.configure do |config|
      config.domain_name = 'example.org'
      config.blacklist = %w(thispasswordisblacklisted)
      config.banned_words = %w(banana)
    end
  }

  describe '#valid?' do
    let(:user) do
      User.new first_name: "Richard",
               last_name: "Smith",
               email: "richard.smith@microsoft.com",
               username: "coolboy13"
    end

    context 'not enough characters' do
      it 'is a weak password' do
        user.password = '1111111111'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'does not have enough unique characters'
      end
    end

    context 'too short' do
      it 'is a weak password' do
        user.password = 'abcd'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too short'
      end
    end

    context 'too long' do
      it 'is a weak password' do
        user.password = rand(36**5000).to_s(36)
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too long'
      end
    end

    context 'too common' do
      it 'is a weak password' do
        user.password = 'password123'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too common'
      end
    end

    context "similar to user's name" do
      it 'is a weak password' do
        user.password = 'iamrichard'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too similar to your name'

        user.password = 'iammrsmith'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too similar to your name'
      end
    end

    context "similar to user's username" do
      it 'is a weak password' do
        user.password = 'iamcoolboy13'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too similar to your username'
      end
    end

    context "similar to user's email" do
      it 'is a weak password' do
        user.password = 'microsoftworld'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too similar to your email'
      end
    end

    context 'similar to this domain name' do
      it 'is a weak password' do
        user.password = 'example123'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is too similar to this domain name'
      end
    end

    context 'blacklisted' do
      it 'is a weak password' do
        user.password = 'thispasswordisblacklisted'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'is not allowed'
      end
    end

    context 'banned word' do
      it 'is a weak password' do
        user.password = 'thispasswordisbanana'
        expect(user).to_not be_valid
        expect(user.errors[:password]).to include 'contains a banned word'
      end
    end

    context 'a great password' do
      it 'is strong and valid' do
        user.password = 'ilikestrongpasswords'
        expect(user).to be_valid
        expect(user.errors[:password]).to be_empty
      end
    end

  end

end
