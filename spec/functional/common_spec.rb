require "wombat/common"
require "yaml"

describe "Common" do
  let(:common) do
    klass = Class.new { include Wombat::Common }

    return klass.new
  end

  describe "#wombat" do
    it "reads a configuration file" do
      wombat_yml = File.join(
        File.expand_path("../..", File.dirname(__FILE__)),
        "generator_files",
        "wombat.yml"
      )

      stub_const("ENV", {"WOMBAT_YML" => wombat_yml})

      content = common.wombat

      expect(content["name"]).to eq("wombat")
    end
  end
end
