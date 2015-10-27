module SQRL
  TIF = {
    0x001 => :id_match,
    0x002 => :previous_id_match,
    0x004 => :ip_match,
    0x008 => :sqrl_disabled,
    0x010 => :function_not_supported,
    0x020 => :transient_error,
    0x040 => :command_failed,
    0x080 => :client_failure,
    0x100 => :bad_association_id,
    0x200 => :invalid_link_origin,
    0x400 => :suppress_sfn_confirmation,
  }
end
