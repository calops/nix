{ lib, ... }:
{
  mkIfNotNull = val: lib.mkIf (val != null);
  firstNotNull = vals: lib.findFirst (val: val != null) vals;

  asLua = value: lib.generators.toLua { } value;

  enumerateList = list: lib.listToAttrs (lib.imap1 (x: y: lib.nameValuePair (toString x) y) list);
}
