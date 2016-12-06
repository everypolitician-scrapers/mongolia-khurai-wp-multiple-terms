require_relative 'nokogiri_document'
require_relative 'unspanned_table'
require_relative 'khural_member'

class MemberTable < NokogiriDocument

  private

  def table
    UnspannedTable.new(noko).transformed
  end
end
