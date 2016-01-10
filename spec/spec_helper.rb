$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'toon_api'

class FakeHttp
  class Response
    attr_accessor :code, :body

    def initialize(code, body)
      @code = code.to_s
      @body = body.to_s
    end
  end

  class << self
    attr_accessor :next_responses
  end

  def self.reset!
    self.next_responses = []
  end
  reset!

  def initialize(host, port)
  end

  def request(request)
    self.class.next_responses.shift
  end

  def add_response(code, body)
    self.class.next_responses << FakeHttp::Response.new(code, body)
  end
end


def login_agreement_response
  {
    'agreements' => [{
        'agreementId' => 'SOMEINTEGER',
        'agreementIdChecksum' => 'SOMECHECKSUM',
        'city' => 'SOMECITY',
        'displayCommonName' => 'eneco-xxx-yyyyyy',
        'displayHardwareVersion' => 'qb2/ene/2.6.24',
        'displaySoftwareVersion' => 'qb2/ene/2.6.24',
        'houseNumber' => 'xx',
        'postalCode' => 'xxxxAB',
        'street' => 'SOMESTREET'
    }],
    'clientId' => 'SOMEUUID',
    'clientIdChecksum' => 'SOMECHECKSUM',
    'passwordHash' => 'SOMEHASH',
    'sample' => false,
    'success' => true
  }
end

def success_response
  {
    'success' => true
  }
end

def valid_session_data
  {
    'clientId' => 'SOMEUUID',
    'clientIdChecksum' => 'SOMECHECKSUM'
  }
end

def toon_state_hash
  eval(File.read(File.join('spec/', "toonstate.rb")))
end