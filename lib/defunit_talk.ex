defmodule DefUnitTalk do
  @moduledoc """
  Talk given at Elixir Sydney Meetup.
  """
 
  use DefUnit
  
  @doc_to_operator "to core units"
  @doc_from_operator "from core units"
  
  DefUnit.core "kg",                :kg,    "SI mass"
  DefUnit.core "Nm<sup>-2</sup>",   :nm2,   "SI pressure"
  DefUnit.core "m<sup>2</sup>",     :m2,    "SI area"
  DefUnit.core "ms<sup>-1</sup>",   :ms,    "SI velocity"
  DefUnit.core "ms<sup>-2</sup>",   :ms2,   "SI acceleration"
  DefUnit.core "feet",              :feet,  "Pressure altitude"
  
  DefUnit.other "lbs",   :lbs,    0.453592, :kg, "FPS mass"
  DefUnit.other "knots", :knots,  0.514444, :ms, "Navigation velocity"

  @doc "Acceleration due to gravity on Earth"
  @spec g() :: ms2
  def g() do
    9.81
  end
  
  @doc "Pressure at altitude"
  @spec p(feet) :: nm2
  def p(alt) do
    8.0e-19 * :math.pow(alt, 4)  \
    - 4.0e-14 * :math.pow(alt, 3) \
    + 1.0e-09 * :math.pow(alt, 2) \
    - 4.0e-05 * alt \
    + 1.225
  end

  @doc "Stall speed"
  @spec stall_speed(kg, m2, float, feet) :: ms
  def stall_speed(mass, wing_area, lift_coefficient, altitude) do
    :math.sqrt((2.0 * mass * g()) /
    (p(altitude) * wing_area * lift_coefficient))
  end
  
  @doc "Piper Archer stall speed"
  @spec piper_archer_stall_speed_knots() :: knots
  def piper_archer_stall_speed_knots() do
    mass = 2545 <~ :lbs
    wing_area = 15.8 <~ :m2
    coefficient_of_lift = 2.1
    altitude = 0 <~ :feet
    stall_speed(mass, wing_area, coefficient_of_lift, altitude) ~> :knots
  end
  
end
