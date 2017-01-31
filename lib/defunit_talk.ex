defmodule DefUnitTalk do
  @moduledoc """
  Talk given at Elixir Sydney Meetup.
  """

  @typedoc "SI weight"
  @type kg :: float
  @typedoc "SI pressure"
  @type kgm2 :: float
  @typedoc "SI area"
  @type m2 :: float
  @typedoc "SI velocity"
  @type ms :: float
  @typedoc "SI acceleration"
  @type ms2 :: float
  @typedoc "pressure altitude"
  @type feet :: float
  
  @typedoc "FPS weight"
  @type lbs :: float
  @typedoc "Navigation velocity"
  @type knots :: float
  
  @doc "Convert to core unit"
  @spec number <~ :kg :: kg
  def value <~ :kg do
    value
  end
  
  @doc "Convert to core unit"
  @spec number <~ :m2 :: m2
  def value <~ :m2 do
    value
  end
  
  @doc "Convert to core unit"
  @spec number <~ :feet :: feet
  def value <~ :feet do
    value
  end
  
  @doc "Convert to core unit"
  @spec number <~ :lbs :: kg
  def value <~ :lbs do
    value / 2.20
  end
  
  @doc "Convert to other unit"
  @spec ms ~> :knots :: knots
  def value ~> :knots do
    value * 1.94
  end
  

  @doc "Acceleration due to gravity on Earth"
  @spec g() :: ms2
  def g() do
    9.81
  end
  
  @doc "Pressure at altitude"
  @spec p(feet) :: kgm2
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
