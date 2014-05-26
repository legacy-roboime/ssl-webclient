###
Copyright (C) 2013 RoboIME

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
###

# This was taken from rosettacode:
# - http://rosettacode.org/wiki/Averages/Simple_moving_average#JavaScript
# Originally available under [Gnu FDL](http://www.gnu.org/licenses/fdl-1.2.html) which is compatible with GNU AGPL.
exports.sma = (period) ->
  nums = []
  (num) ->
    nums.push(num)

    # remove the first element of the array
    nums.splice(0, 1) if nums.length > period

    sum = nums.reduce (a, b) -> a + b
    n = if nums.length < period then nums.length else period

    sum / n
