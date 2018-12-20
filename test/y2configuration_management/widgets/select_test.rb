# Copyright (c) [2018] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require_relative "../../spec_helper"
require "y2configuration_management/widgets/select"
require "y2configuration_management/salt/form"
require "y2configuration_management/salt/form_controller"
require "cwm/rspec"

describe Y2ConfigurationManagement::Widgets::Select do
  subject(:selector) { described_class.new(spec, controller) }

  include_examples "CWM::ComboBox"

  let(:form_spec) do
    Y2ConfigurationManagement::Salt::Form.from_file(FIXTURES_PATH.join("form.yml"))
  end
  let(:spec) { form_spec.find_element_by(path: path) }
  let(:path) { ".root.person.address.country" }
  let(:controller) { instance_double(Y2ConfigurationManagement::Salt::FormController) }

  describe ".new" do
    it "instantiates a new widget according to the spec" do
      selector = described_class.new(spec, controller)
      expect(selector.path).to eq(path)
      expect(selector.items)
        .to eq([["Czech Republic", "Czech Republic"], ["Germany", "Germany"], ["Spain", "Spain"]])
      expect(selector.default).to eq("Czech Republic")
    end
  end

  describe "#init" do
    it "initializes the current value to the default one" do
      expect(selector).to receive(:value=).with("Czech Republic")
      selector.init
    end

    context "when no default value was given" do
      let(:spec) do
        sp = form_spec.find_element_by(path: path)
        sp.instance_variable_set(:@default, nil)
        sp
      end

      it "does not initializes the current value" do
        expect(selector).to_not receive(:value=)
        selector.init
      end
    end
  end

  describe "#value=" do
    it "modifies the default value with the value given" do
      expect(selector.default).to_not eql("Spain")
      selector.value = "Spain"
      expect(selector.default).to eql("Spain")
    end
  end
end
