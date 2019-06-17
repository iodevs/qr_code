defmodule DataMaskingTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias QRCode.{DataMasking, Placement, QR}

  # Version 1, ECC Level Q
  # message: <<0x20, 0x5B, 0x0B, 0x78, 0xD1, 0x72, 0xDC, 0x4D, 0x43, 0x40, 0xEC, 0x11, 0xEC>>
  # msg: <<0x20, 0x5B, 0x0B, 0x78, 0xD1, 0x72, 0xDC, 0x4D, 0x43, 0x40, 0xEC, 0x11, 0xEC, 0xA8, 0x48, 0x16, 0x52, 0xD9, 0x36, 0x9C, 0x00, 0x2E, 0x0F, 0xB4, 0x7A, 0x10>>

  @mask_patterns %{
    0 => %{
      penalty_1: 180,
      penalty_2: 90,
      penalty_3: 80,
      penalty_4: 0,
      total: 350
    },
    1 => %{
      penalty_1: 172,
      penalty_2: 129,
      penalty_3: 120,
      penalty_4: 0,
      total: 421
    },
    2 => %{
      penalty_1: 206,
      penalty_2: 141,
      penalty_3: 160,
      penalty_4: 0,
      total: 507
    },
    3 => %{
      penalty_1: 180,
      penalty_2: 141,
      penalty_3: 120,
      penalty_4: 2,
      total: 443
    },
    4 => %{
      penalty_1: 195,
      penalty_2: 138,
      penalty_3: 200,
      penalty_4: 0,
      total: 553
    },
    5 => %{
      penalty_1: 189,
      penalty_2: 156,
      penalty_3: 200,
      penalty_4: 2,
      total: 547
    },
    6 => %{
      penalty_1: 171,
      penalty_2: 102,
      penalty_3: 80,
      penalty_4: 4,
      total: 357
    },
    7 => %{
      penalty_1: 197,
      penalty_2: 123,
      penalty_3: 200,
      penalty_4: 0,
      total: 520
    }
  }
end
