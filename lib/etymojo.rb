require "rubygems"
require "bundler/setup"
Bundler.require(:default)
# require "wordnik-ruby"
# require "trollop"

class Etymojo
    
  def initialize
    api_key = File.open("#{ENV['HOME']}/.wordnik_api_key").read
    @wordnik = Wordnik::Wordnik.new({:api_key=>api_key})
  end
  
  def search(query, *args)
    options = args.last.is_a?(Hash) ? args.last : {}
    options[:lookup_count] ||= Etymojo.default_lookup_count
    options[:result_count] ||= Etymojo.default_result_count
    
    results = @wordnik.search(query, :limit => options[:lookup_count])
    counts = Hash.new(0)

    puts "\n\nLooking up words that match '#{query}'"
    results.each do |result|
      puts "\n#{result['wordstring']}"  
      word = Wordnik::Word.find(result['wordstring'])
      word.definitions.each_with_index do |definition, index|
        next unless definition.text
        puts Etymojo.wrap_text("  #{index+1}. #{definition.text}")
        definition.text.downcase.scan(/\w+/) do |w|
          counts[w] += 1 unless Etymojo.stopwords.include?(w)
        end
      end
    end

    puts "\n\nCommon words among the definitions of words containing '#{query}'"
    sorted_counts = counts.sort {|a,b| b[1] <=> a[1]}
    sorted_counts[0,options[:result_count]].each do |pair|
      puts pair.join(": ")
    end

  end

  # Class variables

  @@stopwords = %w(a an and are as at by for form from in is it of on one or participle plural that the to which with) + ['--']
  @@default_lookup_count = 50
  @@default_result_count = 20
  
  def self.stopwords; @@stopwords; end
  def self.default_lookup_count; @@default_lookup_count; end
  def self.default_result_count; @@default_result_count; end
  
  # Helper functions
  
  def self.wrap_text(s, col=80)
    s.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n     ")
  end

end