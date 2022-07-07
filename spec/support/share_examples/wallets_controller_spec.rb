RSpec.shared_examples "not logged for get method" do |action|
  context "when not login" do
    before do
      get action
    end
    it "returns a 302 response" do
      expect(response).to have_http_status "302"
    end
    it "redirects to the sign-in page"	do
      expect(response).to redirect_to "/users/sign_in"
    end
  end
end

RSpec.shared_examples "not logged for other method" do
  context "when not login" do
    it "returns a 302 response" do
      expect(response).to have_http_status "302"
    end
    it "redirects to the sign-in page" do
      expect(response).to redirect_to "/users/sign_in"
    end
  end
end

RSpec.shared_examples "not logged for methods" do
  context "when not login" do
    it "returns a 401 response" do
      expect(response).to have_http_status "401"
    end
  end
end
