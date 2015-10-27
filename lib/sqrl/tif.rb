module SQRL
  TIF = {
    0x01 => :id_match,
    0x02 => :previous_id_match,
    0x04 => :ip_match,
    0x08 => :sqrl_disabled,
    0x10 => :function_not_supported,
    0x20 => :transient_error,
    0x40 => :command_failed,
    0x80 => :client_failure,
  }
end
