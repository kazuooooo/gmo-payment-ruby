require "spec_helper"

describe "GMO::Payment::ShopAndSiteAPI" do

  before(:each) do
    @service ||= GMO::Payment::ShopAndSiteAPI.new({
      :shop_id   => SPEC_CONF["shop_id"],
      :shop_pass => SPEC_CONF["shop_pass"],
      :site_id   => SPEC_CONF["site_id"],
      :site_pass => SPEC_CONF["site_pass"],
      :host      => SPEC_CONF["host"]
    })
    @shop_api ||= GMO::Payment::ShopAPI.new({
      :shop_id   => SPEC_CONF["shop_id"],
      :shop_pass => SPEC_CONF["shop_pass"],
      :host      => SPEC_CONF["host"]
    })
    @site_api ||= GMO::Payment::SiteAPI.new({
      :site_id   => SPEC_CONF["site_id"],
      :site_pass => SPEC_CONF["site_pass"],
      :host      => SPEC_CONF["host"]
    })
  end

  it "should raise an ArgumentError if no options passed" do
    lambda {
      service = GMO::Payment::ShopAndSiteAPI.new()
    }.should raise_error(ArgumentError)
  end

  it "has an attr_reader for shop_id" do
    @service.shop_id.should == SPEC_CONF["shop_id"]
  end

  it "has an attr_reader for shop_pass" do
    @service.shop_pass.should == SPEC_CONF["shop_pass"]
  end

  it "has an attr_reader for site_id" do
    @service.site_id.should == SPEC_CONF["site_id"]
  end

  it "has an attr_reader for site_pass" do
    @service.site_pass.should == SPEC_CONF["site_pass"]
  end

  it "has an attr_reader for host" do
    @service.host.should == SPEC_CONF["host"]
  end

  describe "#trade_card" do

    it "got data", :vcr do
      order_id = generate_id
      result = @shop_api.entry_tran({
        :order_id => order_id,
        :job_cd => "AUTH",
        :amount => 100
      })
      access_id = result["AccessID"]
      access_pass = result["AccessPass"]
      card_no = "4111111111111111"
      result = @shop_api.exec_tran({
        :order_id      => order_id,
        :access_id     => access_id,
        :access_pass   => access_pass,
        :method        => 1,
        :pay_times     => 1,
        :card_no       => card_no,
        :expire        => "1405"
      })
      member_id = generate_id
      member_name = "John Smith"
      result = @site_api.save_member({
        :member_id   => member_id,
        :member_name => member_name
      })
      result = @service.trade_card({
        :order_id      => order_id,
        :member_id     => member_id
      })
      result["CardSeq"].nil?.should_not be_true
      result["CardNo"].nil?.should_not be_true
      result["Forward"].nil?.should_not be_true
    end

    it "got error if missing options", :vcr do
      lambda {
        result = @service.trade_card()
      }.should raise_error
    end
  end

end