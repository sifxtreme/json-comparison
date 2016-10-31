require 'json'
require 'pry'
require 'httparty'

class JSONCompareTool

  def compare_json(obj1, obj2, greedy_failure = true)
    if obj1.class != obj2.class
      puts "Class MISMATCH"
      return false if greedy_failure
    end

    if [Hash].include?(obj1.class)
      if(obj1.keys.size != obj2.keys.size)
        puts "Key MISMATCH"
        mismatch1 = (obj1.keys - obj2.keys)
        mismatch2 = (obj2.keys - obj1.keys)

        if mismatch1.any?
          puts "1 has additional keys"
          puts mismatch1
        else
          puts "2 has additional keys"
          puts mismatch2
        end

        return false if greedy_failure
      end

      union = obj1.keys | obj2.keys
      union.each do |key|
        result = compare_json(obj1[key], obj2[key])

        if !result
          puts "Hash MISMATCH"
          print_data(obj1, obj2)
          return false if greedy_failure
        end
      end
    end

    if [Array].include?(obj1.class)
      begin
        obj1.sort!
        obj2.sort!
      rescue ArgumentError => e
        obj1.sort! { |a,b| a['id'] <=> b['id'] }
        obj2.sort! { |a,b| a['id'] <=> b['id'] }
      end


      if(obj1.size != obj2.size)
        puts "Array Size MISMATCH"
        mismatch1 = (obj1.size - obj2.size)
        mismatch2 = (obj2.size - obj1.size)
        if mismatch1 > 0
          puts "1 has additional item"
          print_data(obj1, obj2)
        else
          puts "2 has additional item"
          print_data(obj1, obj2)
        end

        return false if greedy_failure
      end

      array_size = obj1.size
      for i in 0..array_size
        result = compare_json(obj1[i], obj2[i])

        if !result
          puts "Array MISMATCH"
          print_data(obj1, obj2)
          return false if greedy_failure
        end
      end
    end

    if [Fixnum, Float].include?(obj1.class)
      if obj1 != obj2
        puts "Number MISMATCH"
        print_data(obj1, obj2)
        return false if greedy_failure
      end

      return true
    end

    if [String].include?(obj1.class)
      if obj1 != obj2
        puts "String MISMATCH"
        print_data(obj1, obj2)
        return false if greedy_failure
      end

      return true
    end

    return true
  end

  private

  def print_data(obj1, obj2, type = nil)
    string_size_limit = 125

    if obj1.to_s.size < string_size_limit
      if [Array, Hash].include?(obj1.class)
        puts JSON.pretty_generate(obj1)
        puts JSON.pretty_generate(obj2)
      else
        puts obj1
        puts obj2
      end  
    end

  end

end




url1 = 'https://json'
url2 = 'https://json'
response1 = HTTParty.get(url1, verify: false)
response2 = HTTParty.get(url2, verify: false)
json1 = JSON.parse(response1.body)
json2 = JSON.parse(response2.body)

JSONCompareTool.new.compare_json(json1,json2, false)
