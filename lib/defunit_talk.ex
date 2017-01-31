defmodule DefUnitTalk do

  @type kg :: float
  @type kgm3 :: float
  @type m3 :: float
  @type ms :: float
  @type ms2 :: float
  @type feet :: float
  
  @spec g() :: ms2
  def g() do
    9.81
  end
  
  @spec p(feet) :: kgm3
  def p(alt) do
    8.0e-19 * :math.pow(alt, 4)  \
    - 4.0e-14 * :math.pow(alt, 3) \
    + 1.0e-09 * :math.pow(alt, 2) \
    - 4.0e-05 * alt \
    + 1.225
  end

  @spec stall_speed(kg, m3, float, feet) :: ms
  def stall_speed(mass, wing_area, lift_coefficient, altitude) do
    :math.sqrt((2.0 * mass * g()) /
    (p(altitude) * wing_area * lift_coefficient))
  end
  
  @spec piper_archer_stall_speed() :: ms
  def piper_archer_stall_speed() do
    mass = 1157
    wing_area = 15.8
    coefficient_of_lift = 2.1
    altitude = 0
    stall_speed(mass, wing_area, coefficient_of_lift, altitude)
  end
  
end
