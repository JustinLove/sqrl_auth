# Sqrl::Auth

A Ruby implementation of core SQRL alorithims used when challenging, signing, and verifying SQRL authentication requests

For a gentle introduction to SQRL, try http://sqrl.pl  For All the gritty technical detail, https://www.grc.com/sqrl/sqrl.htm

## Installation

Add this line to your application's Gemfile:

    gem 'sqrl_auth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqrl_auth

## Usage

### sqrl_auth

Though it's unlikely that Ruby will be on both sides of the conversation, it will server as a useful illustration.

Server: To create a SQRL login session, create a Nut

    server_key = SQRL::Key::Server.new

    nut = SQRL::ReversibleNut.new(server_key, client_ip)
    # convience and testing
    url = SQRL::URL.new('example.com/sqrl', {
      :nut => nut,
      :sfn => "My SQRL server"
    })
    # or use your framework
    url = sqrl_url(
      :nut => nut.to_s,
      :sfn => SQRL::Base64.encode('My SQRL server'))
    qr_code(url)

Server sessions:

    nut = SQRL::OpaqueNut.new
    session[:nut] = nut.to_s

Client: Once the code or link has been decoded

    # (obtain and decrypt the identity_master_key)
    session = SQRL::ClientSession.new(url, identity_master_key)

    request = SQRL::QueryGenerator.new(session, url)

    https_post(request.post_path, request.to_hash)
    # or request.post_body depending on what your library wants

Server: The server receives a request and verifies it

    req = SQRL::QueryParser.new(request.body)
    invalid = !req.valid?
    req_nut = SQRL::ReversibleNut.reverse(server_key, params[:nut])
    user = find_user(req.idk)

    res_nut = req_nut.response_nut
    response = SQRL::ResponseGenerator.new(res_nut, {
      :id_match => req.idk == user.idk,
      :previous_id_match => req.pidk == user.idk,
      :ip_match => request.ip == req_nut.ip,
      :sqrl_disabled => !user.sqrl_enabled?,
      :command_failed => invalid,
      :client_failure => invalid,
    }, {
      :suk => user.suk,
      :sfn => 'CoolApp',
      :foo => 'bar',
    })
    send_response(response.response_body)

Client: The client may inspect the response

    res = SQRL::ResponseParser.new(session, response.body)
    res.command_failed?
    res.server_friendly_name

    # obtain user intent to login

    request = SQRL::QueryGenerator.new(session, response.body)
    # one of
    request.disable!
    request.enable!
      request.unlock(SQRL::Key::UnlockRequestSigning(suk, identity_unlock_key))
    request.ident!
      request.unlock(SQRL::Key::UnlockRequestSigning(suk, identity_unlock_key))
      request.setlock(identity_lock_key.unlock_pair)
    request.query!
    request.remove!

    https_post(request.post_path, request.to_hash)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
