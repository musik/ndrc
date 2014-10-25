require 'rails_helper'

RSpec.describe WordsController, :type => :controller do

  describe "GET dump" do
    it "returns http success" do
      get :dump
      expect(response).to have_http_status(:success)
    end
  end

end
