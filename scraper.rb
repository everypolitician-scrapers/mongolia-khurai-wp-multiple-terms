#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri/cached'

require 'pry'

class Table
  def initialize(node)
    @table = node
  end

  def rows
    constituency = nil
    table.xpath('.//tr[td]').map do |tr|
      tds = tr.xpath('./td')
      constituency = tds.first.text.strip.gsub("\n",' — ') if tds.first[:rowspan]
      Row.new(tds, constituency).to_h
    end
  end

  private

  attr_reader :table
end

class Row
  def initialize(tds, constituency)
    @tds = tds
    @constituency = constituency
    @cells = tr_with_district || tr_without_district
  end

  def to_h
    {
      name: name,
      name__mn: name_mn,
      party: party,
      term: term,
      wikiname: wikiname,
      constituency: constituency,
    }
  end

  private

  attr_reader :tds, :cells, :constituency

  def name
    tds[cells[:name]].xpath('.//a').text.strip
  end

  def name_mn
    tds[cells[:name__mn]].text.strip
  end

  def party
    tds[cells[:party]].text.strip
  end

  def term
    '2016'
  end

  def wikiname
    tds[cells[:name]].xpath('.//a[not(@class="new")]/@title').text.strip
  end

  def tr_with_district
    if tds.first[:rowspan]
      {
        name: 2,
        name__mn: 3,
        party: 5,
      }
    end
  end

  def tr_without_district
    unless tds.first[:rowspan]
      {
        name: 1,
        name__mn: 2,
        party: 4,
      }
    end
  end
end

class Khurai
  def initialize(url)
    @url = url
  end

  def members
    Table.new(table).rows
  end

  private

  attr_reader :url

  def page
    Nokogiri::HTML(open(url).read)
  end

  def table
    page.xpath('.//h2/span[text()[contains(.,"Constituency")]]/following::table[1]')
  end
end

url = 'https://en.wikipedia.org/wiki/'\
      'List_of_MPs_elected_in_the_Mongolian_legislative_election,_2016'

Khurai.new(url).members.each do |mem|
  ScraperWiki.save_sqlite([:name, :term], mem)
end