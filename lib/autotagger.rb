#!/usr/bin/env ruby
require "csv"
require "rails"
require "ankusa"
require "ankusa/memory_storage"
require "ankusa/naive_bayes"
require "colorize"

class AutoTagger

  def initialize(document_path)
    @document_path = document_path
  end

  def run
    # Read the CSV file at @document_path to get the training and test data
    puts "Reading CSV file at #{@document_path}"
    data = CSV.read(@document_path)

    # Split the data into 10 parts, and from each part, take 20% of the items
    # for testing and 80% for training
    number_of_items = data.count
    items_per_part = (number_of_items / 10).floor
    next_item_to_process = 0
    training_set = []
    test_set = []
    puts "Splitting #{number_of_items} items into 10 parts of #{items_per_part} items each"

    (1..10).each do |part|
      process_items_to = next_item_to_process + items_per_part
      puts "Splitting items #{next_item_to_process} to #{process_items_to - 1}"

      (next_item_to_process...process_items_to).each_with_index do |item, index|
        if index % 5 == 0
          test_set.push data[item]
        else
          training_set.push data[item]
        end
      end

      next_item_to_process = process_items_to
    end

    # Use in-memory storage for Ankusa
    storage = Ankusa::MemoryStorage.new

    # Set up the naive Bayes classifier
    classifier = Ankusa::NaiveBayesClassifier.new storage
    puts "Training naive Bayes classifier"

    # Train the classifier using items in the training set
    training_set.each do |item|
      classifier.train item[1], item[2]
    end

    # Classify items in the test set
    total_items = test_set.count
    total_items_tagged_correctly = 0
    puts "Classifying items"

    test_set.each do |item|
      likely_tags = classifier.log_likelihoods item[2]
      most_likely_tag = likely_tags.sort_by{|_key, value| value}.reverse[0][0]

      # Print the results of each classification
      if item[1] == most_likely_tag
        total_items_tagged_correctly += 1
        print "\u2714".encode("utf-8").green # Tick
      else
        print "\u2718".encode("utf-8").red # Cross
      end

      puts " Original tag was '#{item[1]}'; proposed tag is '#{most_likely_tag}'"
    end

    # Print overall stats
    percentage_of_items_tagged_correctly = (total_items_tagged_correctly.to_f / total_items) * 100
    puts "#{total_items_tagged_correctly} out of #{total_items} items (#{percentage_of_items_tagged_correctly}%) were correctly tagged"

    # Close the connection
    storage.close
  end
end
