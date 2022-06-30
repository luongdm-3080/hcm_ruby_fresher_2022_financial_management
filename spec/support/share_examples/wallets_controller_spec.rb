RSpec.shared_examples "not logged for get method" do |action|
  context "when not login" do
    before do
      get action
    end
    it "redirect login page"do
      expect(response).to redirect_to login_url
    end
  end
end

RSpec.shared_examples "not logged for other method" do
  context "when not login" do
    it "redirect login page"do
      expect(response).to redirect_to login_path
    end
  end
end
