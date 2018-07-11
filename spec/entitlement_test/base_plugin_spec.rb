require 'spec_helper'
require 'logger'

require 'entitlement_test'

describe EntitlementTest::EntitlementPlugin do
  before(:each) do

    kb_apis = Killbill::Plugin::KillbillApi.new("killbill-entitlement-test", {})
    @plugin = EntitlementTest::EntitlementPlugin.new
    @plugin.logger = Logger.new(STDOUT)
    @plugin.kb_apis = kb_apis

    @entitlement_context = ::Killbill::Plugin::Model::EntitlementContext.new
    @entitlement_context.tenant_id = '12345'
  end

  it "should start and stop correctly" do
    @plugin.start_plugin
    @plugin.stop_plugin
  end


  it "should abort payment " do
    properties = []
    add_plugin_property('TEST_ABORT_ENTITLEMENT',"true", properties)

    output = @plugin.prior_call(@entitlement_context, properties)

    expect(output.is_aborted).to be_truthy
    expect(output.adjusted_plugin_properties).to be_nil
  end

  private

  def add_plugin_property(key, value, props)
    p = Killbill::Plugin::Model::PluginProperty.new
    p.key = key
    p.value = value
    p.is_updatable = false
    props << p
  end
end
