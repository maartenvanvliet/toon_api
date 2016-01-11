require "toon_api/version"
require 'json'
require 'securerandom'
class ToonApi
  attr_accessor :username, :password, :session_data, :toon_state, :http
  attr_reader :_last_response

  def initialize(username, password)
    self.username = username
    self.password = password
    clear_toon_state
  end

  def base_url
    "https://toonopafstand.eneco.nl"
  end

  def clear_toon_state
    self.toon_state = {}
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

    successful_response?(response)
  end

  def logout
    return unless session_data
    response = get("/toonMobileBackendWeb/client/auth/logout", client_params)
    clear_toon_state
    self.session_data = nil
    successful_response?(response)
  end

  def client_params
    {
      clientId: self.session_data["clientId"],
      clientIdChecksum: self.session_data["clientIdChecksum"],
      random: SecureRandom.uuid
    }
  end

  def retrieve_toon_state
    return unless session_data
    return toon_state unless toon_state.empty?

    self.toon_state = begin
      response = get("/toonMobileBackendWeb/client/auth/retrieveToonState", client_params)
      JSON.parse(response.body)
    end
  end

  def refresh_toon_state
    clear_toon_state
    retrieve_toon_state
  end

  def get_thermostat_info
    retrieve_toon_state
    toon_state["thermostatInfo"]
  end

  def get_gas_usage
    retrieve_toon_state
    toon_state["gasUsage"]
  end

  def get_power_usage
    retrieve_toon_state
    toon_state["powerUsage"]
  end

  def get_thermostat_states
    retrieve_toon_state
    toon_state["thermostatStates"]
  end

  def get_program_state
    retrieve_toon_state
    toon_state["thermostatInfo"]["activeState"]
  end

  private
    def successful_response?(response)
      JSON.parse(response.body)['success'] ==  true
    end

    def perform(request)
      @_last_response = http.request(request)
    end
end
