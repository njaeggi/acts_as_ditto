# frozen_string_literal: true

RSpec.describe "#ditto!" do
  let(:user) do
    User.create!(
      name: "Cynthia",
      email: "cynthia@example.com",
      status: "active",
      api_token: "super-secret-token",
      confirmed_at: Time.current
    )
  end

  configure_ditto(User) {}

  context "with override" do
    configure_ditto(User) { override status: "pending" }

    it "persists the duplicate" do
      duplicate = user.ditto!

      expect(duplicate).to be_persisted
      expect(duplicate.reload.status).to eq("pending")
    end
  end

  context "with clone_associations" do
    configure_ditto(User) { clone_associations :posts }

    let!(:first_post) { user.posts.create!(title: "First post", body: "Hello world") }
    let!(:second_post) { user.posts.create!(title: "Second post", body: "Another post") }

    it "persists the whole duplicate graph, not just the root record" do
      duplicate = user.ditto!

      expect(duplicate.posts).to all(be_persisted)
      expect(Post.where(user_id: duplicate.id).count).to eq(2)
    end
  end

  context "with cyclic clone_associations" do
    configure_ditto(User) { clone_associations :posts }
    configure_ditto(Post) { clone_associations :user }

    let!(:first_post) { user.posts.create!(title: "First post", body: "Hello world") }
    let!(:second_post) { user.posts.create!(title: "Second post", body: "Another post") }

    it "does not recurse infinitely" do
      expect { user.ditto! }.not_to raise_error
    end

    it "persists the whole cyclic graph, reusing the same duplicate on both sides" do
      duplicate = user.ditto!

      expect(duplicate).to be_persisted
      expect(duplicate.posts).to all(be_persisted)
      expect(duplicate.posts.map(&:user)).to all(equal(duplicate))
    end
  end

  context "when the root record fails validation" do
    with_validation(User, :email, presence: true)

    configure_ditto(User) { nullify :email }

    it "raises" do
      expect { user.ditto! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "persists nothing" do
      expect { user.ditto! }.to raise_error(ActiveRecord::RecordInvalid)

      expect(User.count).to eq(1)
    end
  end

  context "when a nested cloned association fails validation" do
    configure_ditto(User) { clone_associations :posts }
    configure_ditto(Post) { nullify :title }

    with_validation(Post, :title, presence: true)

    let!(:post) { user.posts.create!(title: "Valid title", body: "Body") }

    it "raises" do
      expect { user.ditto! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "persists nothing, including the valid root record" do
      expect { user.ditto! }.to raise_error(ActiveRecord::RecordInvalid)

      expect(User.count).to eq(1)
      expect(Post.count).to eq(1)
    end
  end
end
