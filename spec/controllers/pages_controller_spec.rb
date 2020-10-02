# frozen_string_literal: true

describe PagesController do
  render_views

  describe "#index" do
    it "renders the index file" do
      get(:index)
      expect(response.body).to eq(IO.read("#{Rails.root}/public/index.html"))
    end
  end

  describe "#success" do
    it "renders the success file" do
      get(:success)
      expect(response.body).to eq(IO.read("#{Rails.root}/public/success.html"))
    end
  end
end
