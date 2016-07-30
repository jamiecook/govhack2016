#!/usr/bin/env ruby
require 'date'

PedRow = Struct.new(:date, :hour, :sensor_id, :count) do
  WEEKDAYS=[:monday, :tuesday, :wednesday, :thursday, :friday]
  def initialize(d,h,sid,count)
    super(d, h.to_i, sid, count.to_i)
  end
  def is_lunch?; hour == 12 || hour == 13; end
  def is_weekday?
    dow = date.strftime('%A').downcase.to_sym
    WEEKDAYS.include?(dow)
  end
  def we_want_it?
    is_lunch? && is_weekday? && (date.year == 2016 && date.month == 6)
  end
end

PedCount = Struct.new(:sensor_id,:lat,:long,:count)
def read_file(ped_file, sensors)
  IO.readlines(ped_file).drop(1).
    map {|l| l.strip.split(",") }.
    map { |a|
      y,m,d,h,sid,count = a.values_at(2,3,4,6,7,9)
      begin 
        date = Date.strptime("#{y}-#{m}-#{d}", "%Y-%B-%d")
      rescue
        p [y,m,d]
        raise 'joo'
      end
      PedRow.new(date, h, sid, count)
    }.
    select(&:we_want_it?).first(100).
    group_by(&:sensor_id).
    map { |sid,arr|
      lat,long = sensors.fetch(sid.to_i)
      count = arr.map(&:count).inject(&:+).fdiv(arr.size)
      PedCount.new(sid,lat,long,count)
    }
end

def read_sensors(file)
  headers,*data = IO.readlines(file).map { |r| r.strip.split(',').values_at(0,9,10) }
  data.map { |id,lat,long| [id.to_i, [lat,long]] }.to_h
end

sensors = read_sensors('Pedestrian_Sensor_Locations.csv')
data = read_file('Pedestrian_Counts.csv', sensors)
File.open('ped_counts.csv', 'w') { |f|
  f.puts('sensor_id,latitude,longitude,weekday_count')
  data.each { |c| f.puts("#{c.sensor_id},#{c.lat},#{c.long},#{c.count}") }
}

