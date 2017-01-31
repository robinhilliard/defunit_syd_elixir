defmodule DefUnitTalkTest do
  use ExUnit.Case
  import DefUnitTalk

  test "Piper Archer stall speed" do
    assert_in_delta piper_archer_stall_speed(), 23.6, 0.1
  end
  
end
