require "toon_api/version"
require 'json'
require 'securerandom'
class ToonApi
  attr_accessor :username, :password, :session_data, :toonstate
  attr_reader :_last_response

  def initialize(username, password)
    self.username = username
    self.password = password
    self.toonstate = {}
  end

  def base_url
    "https://toonopafstand.eneco.nl"
  end

  def http
    @http ||= begin
      uri = uri_for_path(base_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http
    end
  end

  def uri_for_path(path)
    URI.parse(File.join(base_url, path))
  end

  def get(path, params = {}, headers={})
    uri = uri_for_path("#{path}?#{URI.encode_www_form(params)}")
    request = Net::HTTP::Get.new(uri.request_uri, {})
    perform(request)
  end

  def login
    response = get("/toonMobileBackendWeb/client/login", { username: username, password: password })

    self.session_data = JSON.parse(response.body)

    params = client_params.merge({
      agreementId: session_data["agreements"][0]["agreementId"],
      agreementIdChecksum: session_data["agreements"][0]["agreementIdChecksum"],
    })

    response = get("/toonMobileBackendWeb/client/auth/start", params)

    JSON.parse(response.body)['success'] ==  true
  end

  def logout
    get("/toonMobileBackendWeb/client/auth/logout", client_params)
    self.toonstate = nil
    self.session_data = nil
  end

  def client_params
    {
      clientId: self.session_data["clientId"],
      clientIdChecksum: self.session_data["clientIdChecksum"],
      random: SecureRandom.uuid
    }
  end

  def retrieve_toonstate
    return toonstate unless toonstate.empty?

    self.toonstate ||= begin
      response = get("/toonMobileBackendWeb/client/auth/retrieveToonState", client_params)
      JSON.parse(response.body)
    end
  end

  def refresh_toon_state
    self.toonstate = nil
    retrieve_toonstate
  end

  def get_thermostat_info
    retrieve_toonstate
    toonstate["thermostatInfo"]
  end

  def get_gas_usage
    retrieve_toon_state
    toonstate["gasUsage"]
  end

  def get_power_usage
    retrieve_toon_state
    toonstate["powerUsage"]
  end

  def get_thermostat_info
    retrieve_toon_state
    toonstate["thermostatInfo"]
  end

  def get_thermostat_states
    retrieve_toon_state
    toonstate["thermostatStates"]
  end

  def get_program_state
    retrieve_toon_state
    toonstate["thermostatInfo"]["activeState"]
  end

  private
    def perform(request)
      @_last_response = http.request(request)
    end
end
