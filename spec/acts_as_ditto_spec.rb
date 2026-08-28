# frozen_string_literal: true

RSpec.describe Ditto do
  it "has a version number" do
    expect(Ditto::VERSION).not_to be nil
  end
end

RSpec.describe "acts_as_ditto" do
  let(:user) do
    User.create!(
      name: "Cynthia",
      email: "cynthia@example.com",
      status: "active",
      api_token: "super-secret-token",
      confirmed_at: Time.current
    )
  end

  describe "#ditto" do
    context "when the model never called acts_as_ditto" do
      it "is not added to the model" do
        expect(Post.new).not_to respond_to(:ditto)
      end
    end

    context "when acts_as_ditto is called with no configuration" do
      configure_ditto(User) {}

      it "returns a new, unsaved record" do
        duplicate = user.ditto

        expect(duplicate).to be_a(User)
        expect(duplicate).to be_new_record
      end

      it "behaves like a plain dup" do
        expect(user.ditto.name).to eq("Cynthia")
      end
    end

    context "with prefix" do
      configure_ditto(User) { prefix :name, "Copy of " }

      it "prepends the given value to the attribute" do
        expect(user.ditto.name).to eq("Copy of Cynthia")
      end

      it "does not modify the original record" do
        user.ditto

        expect(user.name).to eq("Cynthia")
      end
    end

    context "with suffix" do
      configure_ditto(User) { suffix :name, " (copy)" }

      it "appends the given value to the attribute" do
        expect(user.ditto.name).to eq("Cynthia (copy)")
      end

      it "does not modify the original record" do
        user.ditto

        expect(user.name).to eq("Cynthia")
      end
    end

    context "with override" do
      configure_ditto(User) { override status: "pending" }

      it "overwrites the attribute with a static value" do
        expect(user.ditto.status).to eq("pending")
      end

      it "does not modify the original record" do
        user.ditto

        expect(user.status).to eq("active")
      end
    end

    context "with nullify" do
      configure_ditto(User) { nullify :confirmed_at }

      it "resets the attribute to nil" do
        expect(user.ditto.confirmed_at).to be_nil
      end

      it "does not modify the original record" do
        user.ditto

        expect(user.status).not_to be_nil
      end
    end

    context "with reset_to_default" do
      configure_ditto(User) { reset_to_default :status }

      it "resets the attribute to its column default" do
        expect(user.ditto.status).to eq("invited")
      end

      it "does not modify the original record" do
        user.ditto

        expect(user.status).to eq("active")
      end
    end

    context "with transform" do
      configure_ditto(User) do
        transform(:name) { |_record, old_value| old_value.reverse }
      end

      it "transforms the duplicates attribute to block configuration" do
        duplicate = user.ditto

        expect(duplicate.name).to eq("aihtnyC")
      end

      it "does not modify the original record" do
        user.ditto

        expect(user.name).to eq("Cynthia")
      end
    end

    context "with clone_associations" do
      configure_ditto(User) { clone_associations :posts, :address }

      let!(:first_post) { user.posts.create!(title: "First post", body: "Hello world") }
      let!(:second_post) { user.posts.create!(title: "Second post", body: "Another post") }
      let!(:address) do
        user.create_address!(
          street: "Main Street",
          house_number: "12",
          zip_code: "8000",
          city: "Zurich",
          country: "Switzerland"
        )
      end

      it "recursively duplicates has_many associations" do
        duplicate = user.ditto

        expect(duplicate.posts.size).to eq(2)
        expect(duplicate.posts.map(&:title)).to contain_exactly(first_post.title, second_post.title)
        expect(duplicate.posts).to all(be_new_record)
      end

      it "recursively duplicates has_one associations" do
        duplicate = user.ditto

        expect(duplicate.address).to be_new_record
        expect(duplicate.address.street).to eq(address.street)
        expect(duplicate.address.house_number).to eq(address.house_number)
        expect(duplicate.address.zip_code).to eq(address.zip_code)
        expect(duplicate.address.city).to eq(address.city)
        expect(duplicate.address.country).to eq(address.country)
      end

      it "does not touch the original record's associations" do
        user.ditto

        expect(user.posts.reload.size).to eq(2)
      end
    end
  end

  describe "#ditto!" do
    configure_ditto(User) {}

    context "with override" do
      configure_ditto(User) { override status: "pending" }

      it "persists the duplicate" do
        duplicate = user.ditto!

        expect(duplicate).to be_persisted
        expect(duplicate.reload.status).to eq("pending")
      end
    end

    it "raises when the duplicate is invalid" do
      allow_any_instance_of(User).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

      expect { user.ditto! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
