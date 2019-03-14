# frozen_string_literal: true

describe PagesController do
  describe "#index" do
    it "renders the index file" do
      get(:index)
      expect(response).to render_template(file: "#{Rails.root}/public/index.html")
    end
  end

  describe "#success" do
    it "renders the success file" do
      get(:success)
      expect(response).to render_template(file: "#{Rails.root}/public/success.html")
    end
  end
end
