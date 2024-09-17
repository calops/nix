{ lib, ... }:
{
  mkIfNotNull = val: lib.mkIf (val != null);
  firstNotNull = vals: lib.findFirst (val: val != null) vals;

  asLua = value: lib.generators.toLua { } value;
}
