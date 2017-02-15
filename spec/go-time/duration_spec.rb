require "spec_helper"

module GoTime
  describe Duration do

    let(:all_duration) { "1h1m1s1ms1µs1ns" }

    let(:all_nano) {
      Duration::HOUR +
      Duration::MINUTE +
      Duration::SECOND +
      Duration::MILLISECOND +
      Duration::MICROSECOND +
      Duration::NANOSECOND
    }

    describe "#new" do
      it "creates from seconds by default" do
        d = Duration.new(13)
        expect(d.nanoseconds).to eq(13 * Duration::SECOND)
      end

      it "creates with the provided unit" do
        d = Duration.new(13, unit: Duration::MILLISECOND)
        expect(d.nanoseconds).to eq(13*Duration::MILLISECOND)
      end
    end

    describe "#parse" do
      it "parses a time.Duration string" do
        d = Duration.parse("1h")
        expect(d.nanoseconds).to eq(Duration::HOUR)
      end

      it "recognizes either form of microseconds" do
        a = Duration.parse("99us").microseconds
        b = Duration.parse("99µs").microseconds
        expect(a).to eq(b)
      end

      context "when multiple units are present" do
        it "converts and adds them up" do
          d = Duration.parse("1h43m")
          expect(d.nanoseconds).to eq(Duration::HOUR + (43 * Duration::MINUTE))
        end

        it "recognizes all of the units" do
          d = Duration.parse(all_duration)
          expect(d.nanoseconds).to eq(all_nano)
        end

        it "raises an error if an invalid unit is found" do
          expect { Duration.parse("1h2x") }.to raise_error(InvalidUnitError)
        end
      end
    end

    describe "#to_s" do
      context "when all units are present" do
        it "renders all of the units" do
          expect(Duration.new(all_nano, unit: Duration::NANOSECOND).to_s)
            .to eq(all_duration)
        end
      end

      context "when a unit overflows" do
        it "reduces into a larger unit" do
          expect(Duration.parse("63s").to_s).to eq("1m3s")
        end
      end
    end
  end
end
