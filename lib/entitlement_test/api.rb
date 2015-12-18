require 'date'

module EntitlementTest

  class EntitlementPlugin < Killbill::Plugin::EntitlementPluginApi

    def initialize
      super
      puts "EntitlementTest::EntitlementPlugin initialize..."
    end


    def prior_call(entitlement_context, properties)

      puts "EntitlementTest::EntitlementPlugin prior_call : #{entitlement_context_to_s(entitlement_context)}"

      result = ::Killbill::Plugin::Model::PriorEntitlementResult.new

      result.is_aborted = property_to_bool(properties, 'TEST_ABORT_ENTITLEMENT')
      result.adjusted_effective_date = property_to_float(properties, 'TEST_ADJUSTED_EFFECTIVE_DATE')
      result
    end

    def on_success_call(entitlement_context, properties)
      puts "EntitlementTest::EntitlementPlugin on_success_call : #{entitlement_context_to_s(entitlement_context)}"
      ::Killbill::Plugin::Model::OnSuccessEntitlementResult.new
    end

    def on_failure_call(entitlement_context, properties)
      puts "EntitlementTest::EntitlementPlugin on_failure_call : #{entitlement_context_to_s(entitlement_context)}"
      result = ::Killbill::Plugin::Model::OnFailureEntitlementResult.new
      result.next_retry_date = property_to_date(properties, 'TEST_RETRY_FAILED_PAYMENT')
      result
    end

    private

    def entitlement_context_to_s(rc)
    "tenant = #{rc.tenant_id}, operation_type = #{rc.operation_type}, effective_date = #{rc.effective_date}"
    end

    def property_to_str(properties, key_name)
      res = (properties || []).select { |e| e.key == key_name }
      res[0].value if res && res.length > 0
    end

    def property_to_bool(properties, key_name)
      res = (properties || []).select { |e| e.key == key_name }
      res && res.length > 0 && res[0].value.downcase == 'true'
    end

    def property_to_float(properties, key_name)
      res = (properties || []).select { |e| e.key == key_name }
      Float(res[0].value) if res && res.length > 0
    end

    def property_to_date(properties, key_name)
      # for e.g "2012-01-20T07:30:42.000Z"
      res = (properties || []).select { |e| e.key == key_name }
      DateTime.parse(res[0].value).iso8601(3) if res && res.length > 0
    end

  end
end
