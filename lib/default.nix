{ lib, ... }:
{
  mkIfNotNull = val: lib.mkIf (val != null);
}
