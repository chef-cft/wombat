require "wombat/common"
require "yaml"

describe "Wombat::Common" do
  let(:common) do 
    klass = Class.new { include Wombat::Common }

    return klass.new
  end

  describe "#conf" do
    describe "when files_dir is set" do
      it "sets files_dir to default value" do

        content = common.conf

        expect(content["files_dir"]).to eq("files")
      end
    end
  end

  describe "#lock" do
    describe "when a lock does not exist" do
      it "warn and return 1" do

        expect(File).to receive(:exist?).
          with("wombat.lock").
          and_return(false)

        expect(common).to receive(:warn)

        lock = common.lock

        expect(lock).to be(1)
      end
    end

    describe "when a lock does exist" do
      it "load lock file" do

        expect(File).to receive(:exist?).
          with("wombat.lock").
          and_return(true)

        expect(File).to receive(:read).
          with("wombat.lock").
          and_return("{")
        
        expect(JSON).to receive(:parse).with("{")
        
        common.lock
      end
    end
  end

  describe "#wombat" do
    describe "when WOMBAT_YML is set" do
      it "loads a configuration file from WOMBAT_YML" do
        stub_const("ENV", {"WOMBAT_YML" => "aesthetics.yml"})

        expect(File).to receive(:exist?).
          with("aesthetics.yml").
          and_return(true)

        expect(File).to receive(:read).
          with("aesthetics.yml").
          and_return("---")

        expect(YAML).to receive(:load).with("---")

        common.wombat
      end
    end

    describe "when WOMBAT_YML is not set" do
      it "loads a configuration file from a default location" do
        stub_const("ENV", {})

        expect(File).to receive(:exist?).
          with("wombat.yml").
          and_return(true)

        expect(File).to receive(:read).
          with("wombat.yml").
          and_return("---")

        expect(YAML).to receive(:load).with("---")

        common.wombat
      end
    end

    describe "when a configuration file does not exist" do
      it "copies example configuration file to default location" do
        stub_const("ENV", {})

        expect(File).to receive(:exist?).
          with("wombat.yml").
          and_return(false)

        expect(common).to receive(:warn)

        expect(FileUtils).to receive(:cp_r).
          with(/generator_files\/wombat\.yml/, Dir.pwd)

        expect(File).to receive(:read).
          with("wombat.yml").
          and_return("---")

        expect(YAML).to receive(:load).with("---")

        common.wombat
      end
    end
  end
end
