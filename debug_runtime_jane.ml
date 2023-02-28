open Base

module Printf(File_name: sig val v : string end) = struct
  let debug_ch =
    let debug_ch =
      Stdio.Out_channel.create ~binary:false ~append:true File_name.v in
    Stdio.Out_channel.fprintf debug_ch "\nBEGIN DEBUG SESSION at time UTC %s\n%!"
      (Core.Time_ns.to_string_utc @@ Core.Time_ns.now());
    debug_ch
  let ppf =
    let ppf = Caml.Format.formatter_of_out_channel debug_ch in
    Caml.Format.pp_set_geometry ppf ~max_indent:50 ~margin:100;
    ppf
  let pp_printf () (type a): (a, Caml.Format.formatter, unit) format -> a =
    Caml.Format.fprintf ppf
  let open_box() = Caml.Format.pp_open_hovbox ppf 2
  let close_box ~toplevel () =
    Caml.Format.pp_close_box ppf ();
    (if toplevel then Caml.Format.pp_print_newline ppf ())
  let timestamp_now() = "UTC "^Core.Time_ns.to_string_utc @@ Core.Time_ns.now()
end
