# frozen_string_literal: true

RSpec.describe Grumlin do
  it "has a version number" do
    expect(Grumlin::VERSION).not_to be nil
  end

  describe Grumlin::UnknownResponseStatus do
    it "properly assigns message" do
      exception = described_class.new({ code: 999 })
      expect(exception.message).to eq("unknown response status code 999")
      expect(exception.status).to eq({ code: 999 })
    end
  end

  describe Grumlin::ServerSideError do
    it "properly assigns message" do
      exception = described_class.new({ code: 999, message: "error message" }, {})
      expect(exception.message).to eq("error message")
      expect(exception.status).to eq({ code: 999, message: "error message" })
    end
  end

  describe "#definitions" do
    # if these tests fail try running `rake definitions:format`
    describe "[:steps]" do
      subject { described_class.definitions[:steps] }

      it "consists of sorted lists which do not have duplicates" do
        subject.each_value do |list|
          expect(list).to eq(list.sort)
          expect(list).to eq(list.uniq)
        end
      end
    end

    describe "[:expressions]" do
      subject { described_class.definitions[:expressions] }

      it "consists of sorted lists which do not have duplicates" do
        subject.except(:with_options).each_value do |list|
          expect(list).to eq(list.sort)
          expect(list).to eq(list.uniq)
        end
      end
    end
  end

  describe "performance profile" do
    it "profiles" do
      require "ruby-prof"

      test = SerializationPerformanceTest.new(File.read("spec/fixtures/air_routes/air-routes.graphml"))
      test.import!

      result = RubyProf.profile do
        100.times do
          test.import!
        end
      end

      printer = RubyProf::CallTreePrinter.new(result)
      # printer = RubyProf::MultiPrinter.new(result)
      printer.print(path: ".", profile: "profile")
    end
  end

  describe "memory profile" do
    it "profiles" do
      require "memory_profiler"
      test = SerializationPerformanceTest.new(File.read("spec/fixtures/air_routes/air-routes.graphml"))
      test.import!

      report = MemoryProfiler.report do
        test.import!
      end

      report.pretty_print
    end
  end

  describe "benchmark" do
    it "benchmarks" do
      require "benchmark/ips"

      test = SerializationPerformanceTest.new(File.read("spec/fixtures/air_routes/air-routes.graphml"))
      test.import!

      Benchmark.ips do |x|
        x.time = 10
        x.report { test.import! }
      end
    end
  end
end
