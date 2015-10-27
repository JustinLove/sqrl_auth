module SQRL
  TIF = {
    0x01 => :id_match,
    0x02 => :previous_id_match,
    0x04 => :ip_match,
    0x08 => :sqrl_disabled,
    0x10 => :logged_in,
    0x20 => :creation_allowed,
    0x40 => :command_failed,
    0x80 => :sqrl_failure,
  }
end
