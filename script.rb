require "csv"
require "date"

class FindTemp

  def initialize(max_temps = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
    @max_temps = max_temps
  end
    
  def save_results(temp_wrong, header = nil, results = nil)
      Dir.mkdir('results') unless Dir.exist?('results')
      
      filename = "results/temp_#{Date.today}.csv"

      CSV.open(filename, 'w') do |csv|
          if temp_wrong == true
              csv << header
              results.each {|row| csv << row}
          else
              csv << ["All good", "no readings to report."]
          end
          csv << ["max:"]
          csv << @max_temps
      end
  end

  def temp_wrong?(array)
    ambient_temp = array[0].to_f
    temperatures = array.drop(1)
    if temperatures.any? {|temp| temp.to_f >= 105.0000}
      true
    elsif temperatures.any? {|temp| temp.to_f <= (ambient_temp + 2.0000)} 
      true
    else
      false
    end
  end

  def max_temp_calc(array)
    array.map! {|temp| temp.to_f}
    new_array = @max_temps.map.with_index {|temp, i| temp > array[i] ? temp : array[i]}
    @max_temps = new_array
  end

  def read_temp
      header = nil
      wrong_temps = []

      File.open("temp_readings.csv") do |f|
          7.times { f.gets }
          contents = CSV.new(f)

          contents.each_with_index do |row, i|
              if i == 0 
                  header = row
              else
                  temp_array = [row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9]]
                  wrong_temps.push(row) if temp_wrong?(temp_array) == true
                  max_temp_calc(temp_array)
              end
          end

      end
      wrong_temps.empty? ? save_results(false) : save_results(true, header, wrong_temps)

  end

end

class FindVolt

  def save_voltage(volt_wrong, header = nil, results = nil)
    Dir.mkdir('results') unless Dir.exist?('results')
    
    filename = "results/volt_#{Date.today}.csv"

    CSV.open(filename, 'w') do |csv|
        if volt_wrong == true
            csv << header
            results.each {|row| csv << row}
        else
            csv << ["All good", "no readings to report."]
        end
    end
  end

  def volt_wrong?(value)
    if value.to_f >= 253.0000
      true
    elsif value.to_f <= 216.0000
      true
    else
      false
    end
  end

  def read_voltage
    #converting txt to csv in a correct format that can be read from.
    #may need to add step to skip first few lines if needed.
    
    file_contents = File.read("volt_readings.txt").split(" ").map(&:strip)
    nested = file_contents.each_slice(6).to_a
    File.write("volt_readings.csv", nested.map(&:to_csv).join)

    header = nil
    wrong_volt = []
    File.open("volt_readings.csv") do |f|
        contents = CSV.new(f)
        contents.each_with_index do |row, i|
            if i == 0 
                header = row
            else
                voltage = row[3]
                wrong_volt.push(row) if volt_wrong?(voltage) == true
            end
        end

    end
    wrong_volt.empty? ? save_voltage(false) : save_voltage(true, header, wrong_volt)
  end
  
end

temp_results = FindTemp.new
temp_results.read_temp

volt_results = FindVolt.new
volt_results.read_voltage
