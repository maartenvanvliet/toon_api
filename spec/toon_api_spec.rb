require 'spec_helper'

describe ToonApi do
  it 'has a version number' do
    expect(ToonApi::VERSION).not_to be nil
  end

  describe "authentication" do
    let(:toon) { ToonApi.new('username', 'password') }

    before do
      toon.http = FakeHttp.new('host.com', 443)
    end

    context "logging in" do
      before do
        toon.http.add_response(200, JSON.dump(login_agreement_response))
        toon.http.add_response(200, JSON.dump(success_response))
      end

      it "logs in" do
        expect(toon.login).to eq true
        expect(toon.session_data).to include login_agreement_response
      end
    end

    context "logging out" do
      before do
        toon.session_data = valid_session_data
        toon.http.add_response(200, JSON.dump(success_response))
      end

      it "logs out" do
        expect(toon.logout).to eq true
        expect(toon.session_data).to be_nil
      end
    end

    context "retrieving toon status" do
      before do
        toon.session_data = valid_session_data
        toon.http.add_response(200, JSON.dump(toon_state_hash))
      end

      it "retrieves toon_state" do
        expect(toon.retrieve_toon_state).to eq toon_state_hash
      end
    end

    context "refreshing toon status" do
      before do
        toon.session_data = valid_session_data
        toon.http.add_response(200, JSON.dump(toon_state_hash))

        toon.toon_state = {'some state' => 1}
      end

      it "refreshes toon_state" do
        expect{toon.refresh_toon_state}.to change{toon.toon_state}
      end
    end

    context "retrieving toon attributes" do
      before do
        toon.toon_state = toon_state_hash
      end

      it "gets thermostat_info" do
        expect(toon.get_thermostat_info).to eq(toon_state_hash["thermostatInfo"])
      end

      it "gets gas usage" do
        expect(toon.get_gas_usage).to eq(toon_state_hash["gasUsage"])
      end

      it "gets power usage" do
        expect(toon.get_power_usage).to eq(toon_state_hash["powerUsage"])
      end

      it "gets thermostat states" do
        expect(toon.get_thermostat_states).to eq(toon_state_hash["thermostatStates"])
      end

      it "gets program state" do
        expect(toon.get_program_state).to eq(toon_state_hash["thermostatInfo"]["activeState"])
      end
    end
  end
end
