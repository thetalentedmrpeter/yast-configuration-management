#!/usr/bin/env rspec

require_relative "../../spec_helper"
require "y2configuration_management/configurations/salt"
require "tmpdir"

describe Y2ConfigurationManagement::Configurations::Salt do
  subject(:config) { described_class.new_from_hash(hash) }

  let(:master) { "puppet.suse.de" }
  let(:states_url) { "http://ftp.suse.de/modules.tgz" }

  let(:hash) do
    {
      "master"         => master,
      "states_url"     => URI(states_url),
      "formulas_sets"  => formulas_sets,
      "enabled_states" => ["motd"],
      "states_roots"   => ["/srv/custom_states"]
    }
  end

  let(:formulas_sets) do
    [
      { "metadata_root" => "/usr/share/susemanager/formulas/metadata",
        "states_root"   => "/usr/share/susemanager/formulas/states",
        "pillar_root"   => "/srv/susemanager/formulas_data" },
      { "metadata_root" => "/srv/custom_formulas" }
    ]
  end

  describe ".new_from_hash" do
    it "returns  a configuration from the given hash" do
      config = described_class.new_from_hash(hash)
      expect(config.master).to eq(master)
    end

    it "includes the formulas sets" do
      config = described_class.new_from_hash(hash)
      expect(config.formulas_sets).to contain_exactly(
        an_object_having_attributes(
          metadata_root: Pathname.new(formulas_sets[0]["metadata_root"]),
          states_root:   Pathname.new(formulas_sets[0]["states_root"]),
          pillar_root:   Pathname.new(formulas_sets[0]["pillar_root"])
        ),
        an_object_having_attributes(
          metadata_root: Pathname.new(formulas_sets[1]["metadata_root"])
        )
      )
    end
  end

  describe "#type" do
    it "returns 'salt'" do
      expect(config.type).to eq("salt")
    end
  end

  describe "#states_roots" do
    it "returns states roots (custom, formulas and work_dir + 'salt')" do
      expect(config.states_roots.map(&:to_s))
        .to contain_exactly("/srv/custom_states", formulas_sets[0]["states_root"], /var/)
    end
  end

  describe "#states_root" do
    it "returns work_dir + 'salt'" do
      expect(config.states_root).to eq(config.work_dir.join("salt"))
    end
  end

  describe "#pillar_roots" do
    it "returns states roots (custom, formulas and work_dir + 'salt')" do
      expect(config.states_roots.map(&:to_s))
        .to contain_exactly(
          "/srv/custom_states", formulas_sets[0]["states_root"], /#{config.work_dir}/
        )
    end
  end

  describe "#pillar_roots" do
    it "returns pillar roots (formulas and work_dir)" do
      expect(config.pillar_roots.map(&:to_s))
        .to contain_exactly("/srv/susemanager/formulas_data", /#{config.work_dir}/)
    end

    context "when the pillar_root is set" do
      let(:hash) do
        {
          "master"        => master,
          "formulas_sets" => formulas_sets,
          "pillar_root"   => "/srv/pillar"
        }
      end

      it "returns the pillar_root instead of the one in the work_dir" do
        expect(config.pillar_roots.map(&:to_s))
          .to contain_exactly("/srv/susemanager/formulas_data", "/srv/pillar")
      end
    end
  end

  describe "#enabled_states" do
    it "returns the list of enabled states" do
      expect(config.enabled_states).to eq(["motd"])
    end

    context "when on states have been enabled" do
      let(:hash) { {} }

      it "returns an empty array" do
        expect(config.enabled_states).to eq([])
      end
    end
  end
end
