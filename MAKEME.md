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
    url = SQRL::URL.new('example.com/sqrl', nut) # convience and testing
    url = sqrl_url(:nut => nut.to_s) # or use your framework
    qr_code(url)

Server sessions:

    nut = SQRL::OpaqueNut.new
    session[:nut] = nut.to_s

Client: Once the code or link has been decoded

    # (obtain and decrypt the identity_master_key)
    session = SQRL::ClientSession.new(url, identity_master_key)
    #session.pidk = 

    request = SQRL::AuthenticationQueryGenerator.new(session, url)

    https_post(request.post_path, request.to_hash)
    # or request.post_body depending on what your library wants

Server: The server receives a request and verifies it

    req = SQRL::AuthenticationQueryParser.new(request.body)
    invalid = !req.valid?
    req_nut = SQRL::ReversibleNut.reverse(server_key, params[:nut])
    user = find_user(req.idk)

    req.login? #etc, on the second loop

    res_nut = req_nut.response_nut
    response = SQRL::AuthenticationResponseGenerator.new(res_nut, {
      :id_match => req.idk == user.idk,
      :previous_id_match => req.pidk == user.idk,
      :ip_match => request.ip == req_nut.ip,
      :login_enabled => user.sqrl_enabled?,
      :logged_in => session.logged_in?(user),
      :command_failed => invalid,
      :sqrl_failure => invalid,
    }, {
      :sfn => 'CoolApp',
      :foo => 'bar',
    })
    send_response(response.response_body)

Client: The client may inspect the response

    res = SQRL::AuthenticationResponseParser.new(session, response.body)
    res.command_failed?
    res.logged_in?
    res.server_friendly_name

    # obtain user intent to login

    res.update_session!

    request = SQRL::AuthenticationQueryGenerator.new(session, response.body)
    # one or more:
    request.setkey!
    request.setlock!(identity_lock_key.unlock_pair)
    request.disable!
    request.enable!
    request.delete!
    request.create!
    request.login!
    request.logme!
    request.logout!
    request.logoff! # depreciated

    https_post(request.post_path, request.to_hash)

    session.wipe_keys!

### sqrl_client

    iuk = SQRL::Key::IdentityUnlock.generate(large_quantity_of_random_noise)

    storage = SQRL::SSF.new(
      :identity_unlock_key => iuk,
      :rescue_code => rescue_code,
      :identity_master_key => iuk.identity_master_key,
      :password => password)
    File.open('filename.sqrl', 'w') {|f| f.write(storage.serialize)}


    contents = File.read('filename.sqrl')
    storage = SQRL::SSF.deserialize(contents, :password => password)
    storage.encrypted_key
    id = SQRL::Hole.new(password, salt).dig(factor, count).dig_up(encrypted_key, tag)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
